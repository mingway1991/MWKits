//
//  MWTextData.m
//  MWKits
//
//  Created by 石茗伟 on 2018/9/19.
//

#import "MWTextData.h"

@interface MWTextData ()

@property (nonatomic, readwrite) NSMutableAttributedString *innerText;
@property (nonatomic, readwrite) MWTextContainer *container;
@property (nonatomic, readwrite) MWTextLayout *layout;
@property (nonatomic, readwrite) CGSize textBoundingSize;

@end

@implementation MWTextData

#pragma mark - NSCopying
- (instancetype)copyWithZone:(NSZone *)zone {
    MWTextData *data = [[MWTextData alloc] init];
    data.text = [_text copy];
    data.attrText = [_attrText copy];
    data.font = [_font copy];
    data.textColor = [_textColor copy];
    data.textContainerInset = _textContainerInset;
    data.numberOfLines = _numberOfLines;
    data.textAlignment = _textAlignment;
    data.textVerticalAlignment = _textVerticalAlignment;
    data.maxSize = _maxSize;
    data.innerText = [_innerText copy];
    data.container = [_container copy];
    data.layout = [_layout copy];
    data.textBoundingSize = _textBoundingSize;
    return data;
}

#pragma mark - NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _text = [aDecoder decodeObjectForKey:@"text"];
        _attrText = [aDecoder decodeObjectForKey:@"attrText"];
        _font = [aDecoder decodeObjectForKey:@"font"];
        _textColor = [aDecoder decodeObjectForKey:@"textColor"];
        _textContainerInset = [[aDecoder decodeObjectForKey:@"textContainerInset"] UIEdgeInsetsValue];
        _numberOfLines = [aDecoder decodeIntegerForKey:@"numberOfLines"];
        _textAlignment = [aDecoder decodeIntegerForKey:@"textAlignment"];
        _textVerticalAlignment = [aDecoder decodeIntegerForKey:@"textVerticalAlignment"];
        _maxSize = [[aDecoder decodeObjectForKey:@"maxSize"] CGSizeValue];
        _innerText = [aDecoder decodeObjectForKey:@"innerText"];
        _container = [aDecoder decodeObjectForKey:@"container"];
        _layout = [aDecoder decodeObjectForKey:@"layout"];
        _textBoundingSize = [[aDecoder decodeObjectForKey:@"textBoundingSize"] CGSizeValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_text forKey:@"text"];
    [aCoder encodeObject:_attrText forKey:@"attrText"];
    [aCoder encodeObject:_font forKey:@"font"];
    [aCoder encodeObject:[NSValue valueWithUIEdgeInsets:_textContainerInset] forKey:@"textContainerInset"];
    [aCoder encodeInteger:_numberOfLines forKey:@"numberOfLines"];
    [aCoder encodeInteger:_textAlignment forKey:@"textAlignment"];
    [aCoder encodeInteger:_textVerticalAlignment forKey:@"textVerticalAlignment"];
    [aCoder encodeObject:@(_maxSize) forKey:@"maxSize"];
    [aCoder encodeObject:_innerText forKey:@"innerText"];
    [aCoder encodeObject:_container forKey:@"container"];
    [aCoder encodeObject:_layout forKey:@"layout"];
    [aCoder encodeObject:@(_textBoundingSize) forKey:@"textBoundingSize"];
}

#pragma mark - Init
- (instancetype)init {
    self = [super init];
    if (self) {
        _maxSize = CGSizeZero;
        _textContainerInset = UIEdgeInsetsZero;
    }
    return self;
}

- (void)_calculateTextBoundingSize {
    if (!_innerText) return;
    if (CGSizeEqualToSize(_maxSize, CGSizeZero)) return;
    
    _container = [MWTextContainer containerWithSize:_maxSize];
    _container.insets = _textContainerInset;
    _container.maximumNumberOfRows = _numberOfLines;
    _layout = [MWTextLayout layoutWithContainer:_container text:_innerText];
    _textBoundingSize = _layout.textBoundingSize;
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

#pragma mark - Setter
- (void)setText:(NSString *)text {
    _text = text;
    _innerText = [self _convertInnerText];
    [self _calculateTextBoundingSize];
}

- (void)setAttrText:(NSAttributedString *)attrText {
    _attrText = attrText;
    _innerText = [attrText mutableCopy];
    [self _calculateTextBoundingSize];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    if (!_text) return;
    _innerText = [self _convertInnerText];
    [self _calculateTextBoundingSize];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    if (!_text) return;
    _innerText = [self _convertInnerText];
    [self _calculateTextBoundingSize];
}

- (void)setNumberOfLines:(NSUInteger)numberOfLines {
    if (_numberOfLines == numberOfLines) return;
    _numberOfLines = numberOfLines;
    [self _calculateTextBoundingSize];
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset {
    if (UIEdgeInsetsEqualToEdgeInsets(_textContainerInset, textContainerInset)) return;
    _textContainerInset = textContainerInset;
    [self _calculateTextBoundingSize];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    if (_textAlignment == textAlignment) return;
    _textAlignment = textAlignment;
    [self _calculateTextBoundingSize];
}

- (void)setTextVerticalAlignment:(MWTextVerticalAlignment)textVerticalAlignment {
    if (_textVerticalAlignment == textVerticalAlignment) return;
    _textVerticalAlignment = textVerticalAlignment;
    [self _calculateTextBoundingSize];
}

- (void)setMaxSize:(CGSize)maxSize {
    if (CGSizeEqualToSize(_maxSize, maxSize)) return;
    _maxSize = maxSize;
    [self _calculateTextBoundingSize];
}

@end
