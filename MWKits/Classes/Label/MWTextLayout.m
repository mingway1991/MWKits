//
//  MWTextLayout.m
//  MWKits
//
//  Created by 石茗伟 on 2018/9/18.
//

#import "MWTextLayout.h"
#import "MWTextUtil.h"

//默认截断字符串
NSString *const MWTextTruncationToken = @"\u2026";

typedef struct {
    CGFloat head;
    CGFloat foot;
} MWRowEdge;

static inline CFRange MWTextCFRangeFromNSRange(NSRange range) {
    return CFRangeMake(range.location, range.length);
}

static inline NSRange MWTextNSRangeFromCFRange(CFRange range) {
    return NSMakeRange(range.location, range.length);
}

static inline UIEdgeInsets MWTextUIEdgeInsetsInvert(UIEdgeInsets insets) {
    return UIEdgeInsetsMake(-insets.top, -insets.left, -insets.bottom, -insets.right);
}

static void MWTextDrawRun(MWTextLine *line, CTRunRef run, CGContextRef context, CGSize size) {
    CGAffineTransform runTextMatrix = CTRunGetTextMatrix(run);
    BOOL runTextMatrixIsID = CGAffineTransformIsIdentity(runTextMatrix);
    
    if (!runTextMatrixIsID) {
        CGContextSaveGState(context);
        CGAffineTransform trans = CGContextGetTextMatrix(context);
        CGContextSetTextMatrix(context, CGAffineTransformConcat(trans, runTextMatrix));
    }
    CTRunDraw(run, context, CFRangeMake(0, 0));
    if (!runTextMatrixIsID) {
        CGContextRestoreGState(context);
    }
}

static void MWTextDrawText(MWTextLayout *layout, CGContextRef context, CGSize size, CGPoint point, BOOL (^cancel)(void)) {
    CGContextSaveGState(context); {
        
        CGContextTranslateCTM(context, point.x, point.y);
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1, -1);
        
        NSArray *lines = layout.lines;
        for (NSUInteger l = 0, lMax = lines.count; l < lMax; l++) {
            MWTextLine *line = lines[l];
            if (layout.truncatedLine && layout.truncatedLine.index == line.index) line = layout.truncatedLine;
            CGFloat posX = line.position.x;
            CGFloat posY = size.height - line.position.y;
            CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
            for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
                CTRunRef run = CFArrayGetValueAtIndex(runs, r);
                CGContextSetTextMatrix(context, CGAffineTransformIdentity);
                CGContextSetTextPosition(context, posX, posY);
                MWTextDrawRun(line, run, context, size);
            }
            if (cancel && cancel()) break;
        }
        
    } CGContextRestoreGState(context);
}

@interface MWTextLayout ()

@property (nonatomic) MWTextContainer *container;
@property (nonatomic, strong) NSArray<MWTextLine *> *lines;
@property (nullable, nonatomic, strong) MWTextLine *truncatedLine;
@property (nonatomic) NSUInteger rowCount;
@property (nonatomic) CGRect textBoundingRect;
@property (nonatomic) CGSize textBoundingSize;

@end

@implementation MWTextLayout

#pragma mark - Copying
- (instancetype)copyWithZone:(NSZone *)zone {
    MWTextLayout *layout = [MWTextLayout new];
    layout.container = [_container copy];
    layout.lines = [_lines copy];
    layout.truncatedLine = [_truncatedLine copy];
    layout.rowCount = _rowCount;
    layout.textBoundingRect = _textBoundingRect;
    layout.textBoundingSize = _textBoundingSize;
    return layout;
}

#pragma mark - NSCoding
- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    if (self = [super init]) {
        _container = [aDecoder decodeObjectForKey:@"container"];
        _lines = [aDecoder decodeObjectForKey:@"lines"];
        _truncatedLine = [aDecoder decodeObjectForKey:@"truncatedLine"];
        _rowCount = [aDecoder decodeIntegerForKey:@"rowCount"];
        _textBoundingRect = [[aDecoder decodeObjectForKey:@"textBoundingRect"] CGRectValue];
        _textBoundingSize = [[aDecoder decodeObjectForKey:@"textBoundingSize"] CGSizeValue];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:_container forKey:@"container"];
    [aCoder encodeObject:_lines forKey:@"lines"];
    [aCoder encodeObject:_truncatedLine forKey:@"truncatedLine"];
    [aCoder encodeInteger:_rowCount forKey:@"rowCount"];
    [aCoder encodeObject:@(_textBoundingRect) forKey:@"textBoundingRect"];
    [aCoder encodeObject:@(_textBoundingSize) forKey:@"textBoundingSize"];
}

#pragma mark - Init
+ (MWTextLayout *)layoutWithContainerSize:(CGSize)size text:(NSAttributedString *)text {
    MWTextContainer *container = [[MWTextContainer alloc] init];
    container.size = size;
    return [self layoutWithContainer:container text:text];
}

+ (MWTextLayout *)layoutWithContainer:(MWTextContainer *)container text:(NSAttributedString *)text {
    return [self layoutWithContainer:container text:text range:NSMakeRange(0, text.length)];
}

+ (MWTextLayout *)layoutWithContainer:(MWTextContainer *)container text:(NSAttributedString *)text range:(NSRange)range {
    MWTextLayout *layout = [[MWTextLayout alloc] init];
    
    CGPathRef cgPath = nil;
    CGRect cgPathBox = {0};
    NSMutableDictionary *frameAttrs = nil;
    CTFramesetterRef ctSetter = NULL;
    CTFrameRef ctFrame = NULL;
    CFArrayRef ctLines = nil;
    CGPoint *lineOrigins = NULL;
    NSUInteger lineCount = 0;
    NSMutableArray *lines = nil;
    
    BOOL needTruncation = NO;
    NSAttributedString *truncationToken = nil;
    MWTextLine *truncatedLine = nil;
    MWRowEdge *lineRowsEdge = NULL;
    NSUInteger *lineRowsIndex = NULL;
    NSRange visibleRange;
    NSUInteger maximumNumberOfRows = 0;
    
    text = text.mutableCopy;
    container = container.copy;
    if (!text || !container) return nil;
    if (range.location + range.length > text.length) return nil;
    maximumNumberOfRows = container.maximumNumberOfRows;
    
    layout = [[MWTextLayout alloc] init];
    layout.container = container;
    
    // set cgPath and cgPathBox
    if (container.path == nil) {
        if (container.size.width <= 0 || container.size.height <= 0) goto fail;
        CGRect rect = (CGRect) {CGPointZero, container.size };
        rect = UIEdgeInsetsInsetRect(rect, container.insets);
        rect = CGRectStandardize(rect);
        cgPathBox = rect;
        rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(1, -1));
        cgPath = CGPathCreateWithRect(rect, NULL); // let CGPathIsRect() returns true
    } else if (container.path && CGPathIsRect(container.path.CGPath, &cgPathBox)) {
        CGRect rect = CGRectApplyAffineTransform(cgPathBox, CGAffineTransformMakeScale(1, -1));
        cgPath = CGPathCreateWithRect(rect, NULL); // let CGPathIsRect() returns true
    } else {
        CGMutablePathRef path = NULL;
        if (container.path) {
            path = CGPathCreateMutableCopy(container.path.CGPath);
        } else {
            CGRect rect = (CGRect) {CGPointZero, container.size };
            rect = UIEdgeInsetsInsetRect(rect, container.insets);
            CGPathRef rectPath = CGPathCreateWithRect(rect, NULL);
            if (rectPath) {
                path = CGPathCreateMutableCopy(rectPath);
                CGPathRelease(rectPath);
            }
        }
        if (path) {
            cgPathBox = CGPathGetPathBoundingBox(path);
            CGAffineTransform trans = CGAffineTransformMakeScale(1, -1);
            CGMutablePathRef transPath = CGPathCreateMutableCopyByTransformingPath(path, &trans);
            CGPathRelease(path);
            path = transPath;
        }
        cgPath = path;
    }
    if (!cgPath) goto fail;
    
    // frame setter config
    frameAttrs = [NSMutableDictionary dictionary];
    
    // create CoreText objects
    ctSetter = CTFramesetterCreateWithAttributedString((CFTypeRef)text);
    if (!ctSetter) goto fail;
    ctFrame = CTFramesetterCreateFrame(ctSetter, MWTextCFRangeFromNSRange(range), cgPath, (CFTypeRef)frameAttrs);
    if (!ctFrame) goto fail;
    lines = [NSMutableArray new];
    ctLines = CTFrameGetLines(ctFrame);
    lineCount = CFArrayGetCount(ctLines);
    if (lineCount > 0) {
        lineOrigins = malloc(lineCount * sizeof(CGPoint));
        if (lineOrigins == NULL) goto fail;
        CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, lineCount), lineOrigins);
    }
    
    CGRect textBoundingRect = CGRectZero;
    CGSize textBoundingSize = CGSizeZero;
    NSInteger rowIdx = -1;
    NSUInteger rowCount = 0;
    CGRect lastRect = CGRectMake(0, -FLT_MAX, 0, 0);
    CGPoint lastPosition = CGPointMake(0, -FLT_MAX);
    
    // calculate line frame
    NSUInteger lineCurrentIdx = 0;
    for (NSUInteger i = 0; i < lineCount; i++) {
        CTLineRef ctLine = CFArrayGetValueAtIndex(ctLines, i);
        CFArrayRef ctRuns = CTLineGetGlyphRuns(ctLine);
        if (!ctRuns || CFArrayGetCount(ctRuns) == 0) continue;
        
        // CoreText coordinate system
        CGPoint ctLineOrigin = lineOrigins[i];
        
        // UIKit coordinate system
        CGPoint position;
        position.x = cgPathBox.origin.x + ctLineOrigin.x;
        position.y = cgPathBox.size.height + cgPathBox.origin.y - ctLineOrigin.y;
        
        MWTextLine *line = [MWTextLine lineWithCTLine:ctLine position:position];
        CGRect rect = line.bounds;
        
        BOOL newRow = YES;
        if (position.x != lastPosition.x) {
            if (rect.size.height > lastRect.size.height) {
                if (rect.origin.y < lastPosition.y && lastPosition.y < rect.origin.y + rect.size.height) newRow = NO;
            } else {
                if (lastRect.origin.y < position.y && position.y < lastRect.origin.y + lastRect.size.height) newRow = NO;
            }
        }
        
        if (newRow) rowIdx++;
        lastRect = rect;
        lastPosition = position;
        
        line.index = lineCurrentIdx;
        line.row = rowIdx;
        [lines addObject:line];
        rowCount = rowIdx + 1;
        lineCurrentIdx ++;
        
        if (i == 0) textBoundingRect = rect;
        else {
            if (maximumNumberOfRows == 0 || rowIdx < maximumNumberOfRows) {
                textBoundingRect = CGRectUnion(textBoundingRect, rect);
            }
        }
    }
    
    if (rowCount > 0) {
        if (maximumNumberOfRows > 0) {
            if (rowCount > maximumNumberOfRows) {
                needTruncation = YES;
                rowCount = maximumNumberOfRows;
                do {
                    MWTextLine *line = lines.lastObject;
                    if (!line) break;
                    if (line.row < rowCount) break;
                    [lines removeLastObject];
                } while (1);
            }
        }
        MWTextLine *lastLine = lines.lastObject;
        if (!needTruncation && lastLine.range.location + lastLine.range.length < text.length) {
            needTruncation = YES;
        }
        
        lineRowsEdge = calloc(rowCount, sizeof(MWRowEdge));
        if (lineRowsEdge == NULL) goto fail;
        lineRowsIndex = calloc(rowCount, sizeof(NSUInteger));
        if (lineRowsIndex == NULL) goto fail;
        NSInteger lastRowIdx = -1;
        CGFloat lastHead = 0;
        CGFloat lastFoot = 0;
        for (NSUInteger i = 0, max = lines.count; i < max; i++) {
            MWTextLine *line = lines[i];
            CGRect rect = line.bounds;
            if ((NSInteger)line.row != lastRowIdx) {
                if (lastRowIdx >= 0) {
                    lineRowsEdge[lastRowIdx] = (MWRowEdge) {.head = lastHead, .foot = lastFoot };
                }
                lastRowIdx = line.row;
                lineRowsIndex[lastRowIdx] = i;
                lastHead = rect.origin.y;
                lastFoot = lastHead + rect.size.height;
            } else {
                lastHead = MIN(lastHead, rect.origin.y);
                lastFoot = MAX(lastFoot, rect.origin.y + rect.size.height);
            }
        }
        lineRowsEdge[lastRowIdx] = (MWRowEdge) {.head = lastHead, .foot = lastFoot };
        
        for (NSUInteger i = 1; i < rowCount; i++) {
            MWRowEdge v0 = lineRowsEdge[i - 1];
            MWRowEdge v1 = lineRowsEdge[i];
            lineRowsEdge[i - 1].foot = lineRowsEdge[i].head = (v0.foot + v1.head) * 0.5;
        }
    }
    
    { // calculate bounding size
        CGRect rect = textBoundingRect;
        rect = UIEdgeInsetsInsetRect(rect,MWTextUIEdgeInsetsInvert(container.insets));
        rect = CGRectStandardize(rect);
        CGSize size = rect.size;
        size.width += rect.origin.x;
        size.height += rect.origin.y;
        if (size.width < 0) size.width = 0;
        if (size.height < 0) size.height = 0;
        size.width = ceil(size.width);
        size.height = ceil(size.height);
        textBoundingSize = size;
    }
    
    visibleRange = MWTextNSRangeFromCFRange(CTFrameGetVisibleStringRange(ctFrame));
    if (needTruncation) {
        MWTextLine *lastLine = lines.lastObject;
        NSRange lastRange = lastLine.range;
        visibleRange.length = lastRange.location + lastRange.length - visibleRange.location;
        CTLineRef truncationTokenLine = NULL;
        if (container.truncationToken) {
            truncationToken = container.truncationToken;
            truncationTokenLine = CTLineCreateWithAttributedString((CFAttributedStringRef)truncationToken);
        } else {
            CFArrayRef runs = CTLineGetGlyphRuns(lastLine.CTLine);
            NSUInteger runCount = CFArrayGetCount(runs);
            NSMutableDictionary *attrs = nil;
            if (runCount > 0) {
                CTRunRef run = CFArrayGetValueAtIndex(runs, runCount - 1);
                attrs = (id)CTRunGetAttributes(run);
                attrs = attrs ? attrs.mutableCopy : [NSMutableArray new];
                CTFontRef font = (__bridge CFTypeRef)attrs[(id)kCTFontAttributeName];
                CGFloat fontSize = font ? CTFontGetSize(font) : 12.0;
                UIFont *uiFont = [UIFont systemFontOfSize:fontSize * 0.9];
                if (uiFont) {
                    font = CTFontCreateWithName((__bridge CFStringRef)uiFont.fontName, uiFont.pointSize, NULL);
                } else {
                    font = NULL;
                }
                if (font) {
                    attrs[(id)kCTFontAttributeName] = (__bridge id)(font);
                    uiFont = nil;
                    CFRelease(font);
                }
                CGColorRef color = (__bridge CGColorRef)(attrs[(id)kCTForegroundColorAttributeName]);
                if (color && CFGetTypeID(color) == CGColorGetTypeID() && CGColorGetAlpha(color) == 0) {
                    // ignore clear color
                    [attrs removeObjectForKey:(id)kCTForegroundColorAttributeName];
                }
                if (!attrs) attrs = [NSMutableDictionary new];
            }
            truncationToken = [[NSAttributedString alloc] initWithString:MWTextTruncationToken attributes:attrs];
            truncationTokenLine = CTLineCreateWithAttributedString((CFAttributedStringRef)truncationToken);
        }
        if (truncationTokenLine) {
            CTLineTruncationType type = kCTLineTruncationEnd;
            NSMutableAttributedString *lastLineText = [text attributedSubstringFromRange:lastLine.range].mutableCopy;
            [lastLineText appendAttributedString:truncationToken];
            CTLineRef ctLastLineExtend = CTLineCreateWithAttributedString((CFAttributedStringRef)lastLineText);
            if (ctLastLineExtend) {
                CGFloat truncatedWidth = lastLine.width;
                CGRect cgPathRect = CGRectZero;
                if (CGPathIsRect(cgPath, &cgPathRect)) {
                    truncatedWidth = cgPathRect.size.width;
                }
                CTLineRef ctTruncatedLine = CTLineCreateTruncatedLine(ctLastLineExtend, truncatedWidth, type, truncationTokenLine);
                CFRelease(ctLastLineExtend);
                if (ctTruncatedLine) {
                    truncatedLine = [MWTextLine lineWithCTLine:ctTruncatedLine position:lastLine.position];
                    truncatedLine.index = lastLine.index;
                    truncatedLine.row = lastLine.row;
                    CFRelease(ctTruncatedLine);
                }
            }
            CFRelease(truncationTokenLine);
        }
    }
    
    layout.lines = lines;
    layout.truncatedLine = truncatedLine;
    layout.rowCount = rowCount;
    layout.textBoundingRect = textBoundingRect;
    layout.textBoundingSize = textBoundingSize;
    CFRelease(cgPath);
    CFRelease(ctSetter);
    CFRelease(ctFrame);
    if (lineOrigins) free(lineOrigins);
    return layout;
    
fail:
    if (cgPath) CFRelease(cgPath);
    if (ctSetter) CFRelease(ctSetter);
    if (ctFrame) CFRelease(ctFrame);
    if (lineOrigins) free(lineOrigins);
    if (lineRowsEdge) free(lineRowsEdge);
    if (lineRowsIndex) free(lineRowsIndex);
    return nil;
    
    return layout;
}

- (void)drawInContext:(nullable CGContextRef)context
                 size:(CGSize)size
                point:(CGPoint)point
                 view:(nullable UIView *)view
                layer:(nullable CALayer *)layer
               cancel:(nullable BOOL(^)(void))cancel {
    if (context) {
        if (cancel && cancel()) return;
        MWTextDrawText(self, context, size, point, cancel);
    }
}

@end
