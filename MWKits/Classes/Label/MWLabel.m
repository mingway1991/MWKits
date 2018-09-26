//
//  MWLabel.m
//  MWKits
//
//  Created by 石茗伟 on 2018/9/18.
//

#import "MWLabel.h"
#import "MWTextLayer.h"
#import "MWTextLayout.h"
#import "MWTextContainer.h"
#import "MWTextUtil.h"
#import "MWTextData.h"

static inline CGPoint MWTextCGPointPixelRound(CGPoint point) {
    CGFloat scale = MWTextScreenScale();
    return CGPointMake(round(point.x * scale) / scale,
                       round(point.y * scale) / scale);
}

@interface MWLabel () <MWTextLayerDelegate> {
    MWTextLayout *_innerLayout;
    MWTextContainer *_innerContainer;
    NSMutableAttributedString *_innerText;      //text和attrText最终都会转化成_innerText进行绘制
    
    BOOL _layoutNeedUpdate;                     //textLayout是否需要更新，默认YES
}

@end

@implementation MWLabel

#pragma mark - Init
- (instancetype)init {
    self = [super init];
    if (self) {
        [self _setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self _setup];
        self.frame = frame;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _setup];
        MWTextContainer *innerContainer = [aDecoder decodeObjectForKey:@"innerContainer"];
        if (innerContainer) {
            _innerContainer = innerContainer;
        } else {
            _innerContainer.size = self.bounds.size;
        }
        _innerText = [aDecoder decodeObjectForKey:@"innerText"];
        [self  _setLayoutNeedUpdate];
    }
    return self;
}

+ (Class)layerClass{
    return [MWTextLayer class];
}

#pragma mark - 初始化
/** 初始设置 **/
- (void)_setup {
    self.backgroundColor = [UIColor clearColor];
    self.layer.contentsScale = MWTextScreenScale();
    self.contentMode = UIViewContentModeRedraw;
    self.isAccessibilityElement = YES;
    self.opaque = NO;
    
    _text = @"";
    _font = [UIFont systemFontOfSize:14.f];
    _textColor = [UIColor blackColor];
    _innerContainer = [MWTextContainer new];
    _innerContainer.maximumNumberOfRows = _numberOfLines;
    
    _layoutNeedUpdate = YES;
}

#pragma mark - Private
- (void)_setLayoutNeedUpdate {
    _layoutNeedUpdate = YES;
    [self _clearLayout];
}

- (void)_clearLayout {
    if (!_innerLayout) return;
    _innerLayout = nil;
}

- (void)_updateIfNeeded {
    if (_layoutNeedUpdate) {
        _layoutNeedUpdate = NO;
        [self _updateLayout];
        [self _setLayoutNeedRedraw];
    }
}

- (void)_setLayoutNeedRedraw {
    [self.layer setNeedsDisplay];
}

- (void)_updateLayout {
    _innerLayout = [MWTextLayout layoutWithContainer:_innerContainer text:_innerText];
}

- (NSMutableAttributedString *)_convertInnerText {
    if (_text.length == 0) {
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
    
    NSMutableAttributedString *innerText = [[NSMutableAttributedString alloc] initWithString:_text];
    NSRange range = NSMakeRange(0, _text.length);
    [innerText addAttribute:NSFontAttributeName value:_font range:range];
    [innerText addAttribute:NSForegroundColorAttributeName value:_textColor range:range];
    return innerText;
}

- (void)_updateTextAlignment {
    [_innerText enumerateAttribute:NSParagraphStyleAttributeName inRange:NSMakeRange(0, _innerText.length) options:kNilOptions usingBlock:^(NSParagraphStyle *value, NSRange subRange, BOOL * _Nonnull stop) {
        NSMutableParagraphStyle *style = nil;
        if (value) {
            if (CFGetTypeID((__bridge CFTypeRef)(value)) == CTParagraphStyleGetTypeID()) {
                NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                CTTextAlignment alignment;
                if (CTParagraphStyleGetValueForSpecifier((__bridge CTParagraphStyleRef)(value), kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &alignment)) {
                    style.alignment = NSTextAlignmentFromCTTextAlignment(alignment);
                }
                value = style;
            }
            if (value.alignment == _textAlignment) return;
            if ([value isKindOfClass:[NSMutableParagraphStyle class]]) {
                style = (id)value;
            } else {
                style = value.mutableCopy;
            }
        } else {
            if ([NSParagraphStyle defaultParagraphStyle].alignment == _textAlignment) return;
            style = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
        }
        style.alignment = _textAlignment;
        [_innerText addAttribute:NSParagraphStyleAttributeName value:style range:subRange];
    }];
}

#pragma mark - MWTextLayerDelegate
- (MWTextLayerDisplayTask *)newDisplayTask {
    
    NSAttributedString *text = _innerText;
    MWTextContainer *container = _innerContainer;
    BOOL layoutNeedUpdate = _layoutNeedUpdate;
    __block MWTextLayout *layout = _innerLayout;
    __block BOOL layoutUpdated = NO;
    if (layoutNeedUpdate) {
        text = text.copy;
        container = container.copy;
    }
    
    MWTextLayerDisplayTask *task = [MWTextLayerDisplayTask new];
    
    task.willDisplay = ^(CALayer *layer) {
        [layer removeAnimationForKey:@"contents"];
    };
    
    task.display = ^(CGContextRef context, CGSize size, BOOL (^isCancelled)(void)) {
        if (isCancelled()) return;
        if (text.length == 0) return;
        
        MWTextLayout *drawLayout = layout;
        if (layoutNeedUpdate) {
            layout = [MWTextLayout layoutWithContainer:container text:text];
            if (isCancelled()) return;
            layoutUpdated = YES;
            drawLayout = layout;
        }
        
        CGSize boundingSize = drawLayout.textBoundingSize;
        CGPoint point = CGPointZero;
        if (_textVerticalAlignment == MWTextVerticalAlignmentCenter) {
            point.y = (size.height - boundingSize.height) * 0.5;
        } else if (_textVerticalAlignment == MWTextVerticalAlignmentBottom) {
            point.y = (size.height - boundingSize.height);
        }
        point = MWTextCGPointPixelRound(point);
        [drawLayout drawInContext:context size:size point:point view:nil layer:nil cancel:isCancelled];
    };
    
    task.didDisplay = ^(CALayer *layer, BOOL finished) {
        MWTextLayout *drawLayout = layout;
        
        [layer removeAnimationForKey:@"contents"];
        
        __strong MWLabel *view = (MWLabel *)layer.delegate;
        if (!view) return;
        if (view->_layoutNeedUpdate && layoutUpdated) {
            view->_innerLayout = layout;
            view->_layoutNeedUpdate = NO;
        }
        
        CGSize size = layer.bounds.size;
        CGSize boundingSize = drawLayout.textBoundingSize;
        CGPoint point = CGPointZero;
        if (_textVerticalAlignment == MWTextVerticalAlignmentCenter) {
            point.y = (size.height - boundingSize.height) * 0.5;
        } else if (_textVerticalAlignment == MWTextVerticalAlignmentBottom) {
            point.y = (size.height - boundingSize.height);
        }
        point = MWTextCGPointPixelRound(point);
        [drawLayout drawInContext:nil size:size point:point view:view layer:layer cancel:NULL];
    };
    
    return task;
}

#pragma mark - Setter
- (void)setText:(NSString *)text {
    _text = text;
    _innerText = [self _convertInnerText];
    [self _setLayoutNeedUpdate];
    [self _updateIfNeeded];
}

- (void)setAttrText:(NSAttributedString *)attrText {
    _attrText = attrText;
    _innerText = [attrText mutableCopy];
    [self _setLayoutNeedUpdate];
    [self _updateIfNeeded];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    if (!_text) return;
    _innerText = [self _convertInnerText];
    [self _setLayoutNeedUpdate];
    [self _updateIfNeeded];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    if (!_text) return;
    _innerText = [self _convertInnerText];
    [self _setLayoutNeedUpdate];
    [self _updateIfNeeded];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.layer.backgroundColor = backgroundColor.CGColor;
}

- (void)setFrame:(CGRect)frame {
    CGSize oldSize = self.bounds.size;
    [super setFrame:frame];
    CGSize newSize = self.bounds.size;
    if (!CGSizeEqualToSize(oldSize, newSize)) {
        _innerContainer.size = self.bounds.size;
        [self _setLayoutNeedUpdate];
        [self _updateIfNeeded];
    }
}

- (void)setBounds:(CGRect)bounds {
    CGSize oldSize = self.bounds.size;
    [super setBounds:bounds];
    CGSize newSize = self.bounds.size;
    if (!CGSizeEqualToSize(oldSize, newSize)) {
        _innerContainer.size = self.bounds.size;
        [self _setLayoutNeedUpdate];
        [self _updateIfNeeded];
    }
}

- (void)setNumberOfLines:(NSUInteger)numberOfLines {
    if (_numberOfLines == numberOfLines) return;
    _numberOfLines = numberOfLines;
    _innerContainer.maximumNumberOfRows = numberOfLines;
    if (_innerText.length) {
        [self _setLayoutNeedUpdate];
        [self _updateIfNeeded];
    }
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset {
    if (UIEdgeInsetsEqualToEdgeInsets(_textContainerInset, textContainerInset)) return;
    _textContainerInset = textContainerInset;
    _innerContainer.insets = textContainerInset;
    if (_innerText.length) {
        [self _setLayoutNeedUpdate];
        [self _updateIfNeeded];
    }
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    if (_textAlignment == textAlignment) return;
    _textAlignment = textAlignment;
    if (_innerText.length) {
        [self _updateTextAlignment];
        [self _setLayoutNeedUpdate];
        [self _updateIfNeeded];
    }
}

- (void)setTextVerticalAlignment:(MWTextVerticalAlignment)textVerticalAlignment {
    if (_textVerticalAlignment == textVerticalAlignment) return;
    _textVerticalAlignment = textVerticalAlignment;
    if (_innerText.length) {
        [self _setLayoutNeedUpdate];
        [self _updateIfNeeded];
    }
}

- (void)setData:(MWTextData *)data {
    if (_data == data) return;
    _data = data;
    _innerText = data.innerText;
    _innerContainer = data.container;
    _innerLayout = data.layout;
    _numberOfLines = data.numberOfLines;
    _textAlignment = data.textAlignment;
    if (_innerText.length) {
        [self _updateTextAlignment];
        [self _setLayoutNeedUpdate];
        [self _updateIfNeeded];
    }
}

#pragma mark - Public
- (void)updateWithData:(MWTextData *)data {
    _data = nil;
    self.data = data;
}

@end
