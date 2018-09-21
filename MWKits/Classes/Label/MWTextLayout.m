//
//  MWTextLayout.m
//  MWKits
//
//  Created by 石茗伟 on 2018/9/18.
//

#import "MWTextLayout.h"
#import "MWTextUtil.h"

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

static inline BOOL MWTextCTFontContainsColorBitmapGlyphs(CTFontRef font) {
    return  (CTFontGetSymbolicTraits(font) & kCTFontTraitColorGlyphs) != 0;
}

static void MWTextDrawRun(MWTextLine *line, CTRunRef run, CGContextRef context, CGSize size, BOOL isVertical, CGFloat verticalOffset) {
    CGAffineTransform runTextMatrix = CTRunGetTextMatrix(run);
    BOOL runTextMatrixIsID = CGAffineTransformIsIdentity(runTextMatrix);
    
    CFDictionaryRef runAttrs = CTRunGetAttributes(run);
    if (!isVertical) { // draw run
        if (!runTextMatrixIsID) {
            CGContextSaveGState(context);
            CGAffineTransform trans = CGContextGetTextMatrix(context);
            CGContextSetTextMatrix(context, CGAffineTransformConcat(trans, runTextMatrix));
        }
        CTRunDraw(run, context, CFRangeMake(0, 0));
        if (!runTextMatrixIsID) {
            CGContextRestoreGState(context);
        }
    } else { // draw glyph
        CTFontRef runFont = CFDictionaryGetValue(runAttrs, kCTFontAttributeName);
        if (!runFont) return;
        NSUInteger glyphCount = CTRunGetGlyphCount(run);
        if (glyphCount <= 0) return;
        
        CGGlyph glyphs[glyphCount];
        CGPoint glyphPositions[glyphCount];
        CTRunGetGlyphs(run, CFRangeMake(0, 0), glyphs);
        CTRunGetPositions(run, CFRangeMake(0, 0), glyphPositions);
        
        CGColorRef fillColor = (CGColorRef)CFDictionaryGetValue(runAttrs, kCTForegroundColorAttributeName);
        fillColor = ((__bridge UIColor *)fillColor).CGColor;
        NSNumber *strokeWidth = CFDictionaryGetValue(runAttrs, kCTStrokeWidthAttributeName);
        
        CGContextSaveGState(context); {
            CGContextSetFillColorWithColor(context, fillColor);
            if (strokeWidth == nil || strokeWidth.floatValue == 0) {
                CGContextSetTextDrawingMode(context, kCGTextFill);
            } else {
                CGColorRef strokeColor = (CGColorRef)CFDictionaryGetValue(runAttrs, kCTStrokeColorAttributeName);
                if (!strokeColor) strokeColor = fillColor;
                CGContextSetStrokeColorWithColor(context, strokeColor);
                CGContextSetLineWidth(context, CTFontGetSize(runFont) * fabs(strokeWidth.floatValue * 0.01));
                if (strokeWidth.floatValue > 0) {
                    CGContextSetTextDrawingMode(context, kCGTextStroke);
                } else {
                    CGContextSetTextDrawingMode(context, kCGTextFillStroke);
                }
            }
            
            if (isVertical) {
                CFIndex runStrIdx[glyphCount + 1];
                CTRunGetStringIndices(run, CFRangeMake(0, 0), runStrIdx);
                CFRange runStrRange = CTRunGetStringRange(run);
                runStrIdx[glyphCount] = runStrRange.location + runStrRange.length;
                CGSize glyphAdvances[glyphCount];
                CTRunGetAdvances(run, CFRangeMake(0, 0), glyphAdvances);
            } else { // not vertical
                if (MWTextCTFontContainsColorBitmapGlyphs(runFont)) {
                    CTFontDrawGlyphs(runFont, glyphs, glyphPositions, glyphCount, context);
                } else {
                    CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
                    CGContextSetFont(context, cgFont);
                    CGContextSetFontSize(context, CTFontGetSize(runFont));
                    CGContextShowGlyphsAtPositions(context, glyphs, glyphPositions, glyphCount);
                    CGFontRelease(cgFont);
                }
            }
            
        } CGContextRestoreGState(context);
    }
}

static void MWTextDrawText(MWTextLayout *layout, CGContextRef context, CGSize size, CGPoint point, BOOL (^cancel)(void)) {
    CGContextSaveGState(context); {
        
        CGContextTranslateCTM(context, point.x, point.y);
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1, -1);
        
        BOOL isVertical = layout.container.isVertical;
        CGFloat verticalOffset = isVertical ? (size.width - layout.container.size.width) : 0;
        
        NSArray *lines = layout.lines;
        for (NSUInteger l = 0, lMax = lines.count; l < lMax; l++) {
            MWTextLine *line = lines[l];
            if (layout.truncatedLine && layout.truncatedLine.index == line.index) line = layout.truncatedLine;
            CGFloat posX = line.position.x + verticalOffset;
            CGFloat posY = size.height - line.position.y;
            CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
            for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
                CTRunRef run = CFArrayGetValueAtIndex(runs, r);
                CGContextSetTextMatrix(context, CGAffineTransformIdentity);
                CGContextSetTextPosition(context, posX, posY);
                MWTextDrawRun(line, run, context, size, isVertical, verticalOffset);
            }
            if (cancel && cancel()) break;
        }
        
    } CGContextRestoreGState(context);
}

@interface MWTextLayout ()

@property (nonatomic, readwrite) MWTextContainer *container;
@property (nonatomic, strong, readwrite) NSArray<MWTextLine *> *lines;
@property (nullable, nonatomic, strong, readwrite) MWTextLine *truncatedLine;
@property (nonatomic, readwrite) NSUInteger rowCount;
@property (nonatomic, readwrite) CGRect textBoundingRect;
@property (nonatomic, readwrite) CGSize textBoundingSize;

@end

@implementation MWTextLayout

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
    BOOL isVertical = NO;
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
    isVertical = container.isVertical;
    
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
    if (container.isVertical == YES) {
        frameAttrs[(id)kCTFrameProgressionAttributeName] = @(kCTFrameProgressionRightToLeft);
    }
    
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
    if (isVertical) {
        lastRect = CGRectMake(FLT_MAX, 0, 0, 0);
        lastPosition = CGPointMake(FLT_MAX, 0);
    }
    
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
        
        MWTextLine *line = [MWTextLine lineWithCTLine:ctLine position:position vertical:isVertical];
        CGRect rect = line.bounds;
        
        BOOL newRow = YES;
        if (position.x != lastPosition.x) {
            if (isVertical) {
                if (rect.size.width > lastRect.size.width) {
                    if (rect.origin.x > lastPosition.x && lastPosition.x > rect.origin.x - rect.size.width) newRow = NO;
                } else {
                    if (lastRect.origin.x > position.x && position.x > lastRect.origin.x - lastRect.size.width) newRow = NO;
                }
            } else {
                if (rect.size.height > lastRect.size.height) {
                    if (rect.origin.y < lastPosition.y && lastPosition.y < rect.origin.y + rect.size.height) newRow = NO;
                } else {
                    if (lastRect.origin.y < position.y && position.y < lastRect.origin.y + lastRect.size.height) newRow = NO;
                }
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
                if (isVertical) {
                    lastHead = rect.origin.x + rect.size.width;
                    lastFoot = lastHead - rect.size.width;
                } else {
                    lastHead = rect.origin.y;
                    lastFoot = lastHead + rect.size.height;
                }
            } else {
                if (isVertical) {
                    lastHead = MAX(lastHead, rect.origin.x + rect.size.width);
                    lastFoot = MIN(lastFoot, rect.origin.x);
                } else {
                    lastHead = MIN(lastHead, rect.origin.y);
                    lastFoot = MAX(lastFoot, rect.origin.y + rect.size.height);
                }
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
        if (container.isVertical) {
            size.width += container.size.width - (rect.origin.x + rect.size.width);
        } else {
            size.width += rect.origin.x;
        }
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
        
        //TODO:TruncationLine
    }
    
    if (isVertical) {
        NSCharacterSet *rotateCharset = MWTextVerticalFormRotateCharacterSet();
        NSCharacterSet *rotateMoveCharset = MWTextVerticalFormRotateAndMoveCharacterSet();
        
        void (^lineBlock)(MWTextLine *) = ^(MWTextLine *line){
            CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
            if (!runs) return;
            NSUInteger runCount = CFArrayGetCount(runs);
            if (runCount == 0) return;
            NSMutableArray *lineRunRanges = [NSMutableArray new];
            for (NSUInteger r = 0; r < runCount; r++) {
                CTRunRef run = CFArrayGetValueAtIndex(runs, r);
                NSMutableArray *runRanges = [NSMutableArray new];
                [lineRunRanges addObject:runRanges];
                NSUInteger glyphCount = CTRunGetGlyphCount(run);
                if (glyphCount == 0) continue;
                
                CFIndex runStrIdx[glyphCount + 1];
                CTRunGetStringIndices(run, CFRangeMake(0, 0), runStrIdx);
                CFRange runStrRange = CTRunGetStringRange(run);
                runStrIdx[glyphCount] = runStrRange.location + runStrRange.length;
                CFDictionaryRef runAttrs = CTRunGetAttributes(run);
                CTFontRef font = CFDictionaryGetValue(runAttrs, kCTFontAttributeName);
                BOOL isColorGlyph = MWTextCTFontContainsColorBitmapGlyphs(font);
                
                NSString *layoutStr = text.string;
                for (NSUInteger g = 0; g < glyphCount; g++) {
                    BOOL glyphRotate = 0, glyphRotateMove = NO;
                    CFIndex runStrLen = runStrIdx[g + 1] - runStrIdx[g];
                    if (isColorGlyph) {
                        glyphRotate = YES;
                    } else if (runStrLen == 1) {
                        unichar c = [layoutStr characterAtIndex:runStrIdx[g]];
                        glyphRotate = [rotateCharset characterIsMember:c];
                        if (glyphRotate) glyphRotateMove = [rotateMoveCharset characterIsMember:c];
                    } else if (runStrLen > 1){
                        NSString *glyphStr = [layoutStr substringWithRange:NSMakeRange(runStrIdx[g], runStrLen)];
                        BOOL glyphRotate = [glyphStr rangeOfCharacterFromSet:rotateCharset].location != NSNotFound;
                        if (glyphRotate) glyphRotateMove = [glyphStr rangeOfCharacterFromSet:rotateMoveCharset].location != NSNotFound;
                    }
                }
            }
        };
        for (MWTextLine *line in lines) {
            lineBlock(line);
        }
        if (truncatedLine) lineBlock(truncatedLine);
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
