//
//  MWTextData.m
//  MWKits
//
//  Created by 石茗伟 on 2018/9/19.
//

#import "MWTextData.h"

@interface MWTextData ()
{
    MWTextContainer *_container;
    MWTextLayout *_layout;
}
@property (nonatomic, readwrite) CGSize textBoundingSize;

@end

@implementation MWTextData

- (instancetype)init {
    self = [super init];
    if (self) {
        _size = CGSizeZero;
        _insets = UIEdgeInsetsZero;
    }
    return self;
}

- (void)_calculateTextBoundingSize {
    if (!_text) return;
    if (CGSizeEqualToSize(_size, CGSizeZero)) return;
    
    _container = [MWTextContainer containerWithSize:_size];
    _container.insets = _insets;
    _layout = [MWTextLayout layoutWithContainer:_container text:_text];
    _textBoundingSize = _layout.textBoundingSize;
}

#pragma mark - Setter
- (void)setText:(NSAttributedString *)text {
    _text = text;
    [self _calculateTextBoundingSize];
}

- (void)setNumberOfLines:(NSUInteger)numberOfLines {
    _numberOfLines = numberOfLines;
    [self _calculateTextBoundingSize];
}

- (void)setSize:(CGSize)size {
    _size = size;
    [self _calculateTextBoundingSize];
}

- (void)setInsets:(UIEdgeInsets)insets {
    _insets = insets;
    [self _calculateTextBoundingSize];
}

@end
