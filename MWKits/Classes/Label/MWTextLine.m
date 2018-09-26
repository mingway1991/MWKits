//
//  MWTextLine.m
//  MWLabel
//
//  Created by 石茗伟 on 2018/9/17.
//

#import "MWTextLine.h"

#ifndef MWTEXT_SWAP // swap two value
#define MWTEXT_SWAP(_a_, _b_)  do { __typeof__(_a_) _tmp_ = (_a_); (_a_) = (_b_); (_b_) = _tmp_; } while (0)
#endif

@implementation MWTextLine {
    CGFloat _firstGlyphPos; // first glyph position for baseline, typically 0.
}

#pragma mark - Copying
- (instancetype)copyWithZone:(NSZone *)zone {
    MWTextLine *line = [MWTextLine new];
    line->_index = _index;
    line->_row = _row;
    line->_CTLine = _CTLine;
    line->_range = _range;
    line->_position = _position;
    line->_ascent = _ascent;
    line->_descent = _descent;
    line->_leading = _leading;
    line->_lineWidth = _lineWidth;
    line->_trailingWhitespaceWidth = _trailingWhitespaceWidth;
    line->_bounds = _bounds;
    return line;
}

#pragma mark - NSCoding
- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    if (self = [super init]) {
        _index = [aDecoder decodeIntegerForKey:@"index"];
        _row = [aDecoder decodeIntegerForKey:@"row"];
        _CTLine = (__bridge CTLineRef _Nonnull)([aDecoder decodeObjectForKey:@"CTLine"]);
        _range = [[aDecoder decodeObjectForKey:@"range"] rangeValue];
        _position = [[aDecoder decodeObjectForKey:@"position"] CGPointValue];
        _ascent = [aDecoder decodeDoubleForKey:@"ascent"];
        _descent = [aDecoder decodeDoubleForKey:@"descent"];
        _leading = [aDecoder decodeDoubleForKey:@"leading"];
        _lineWidth = [aDecoder decodeDoubleForKey:@"lineWidth"];
        _trailingWhitespaceWidth = [aDecoder decodeDoubleForKey:@"trailingWhitespaceWidth"];
        _bounds = [[aDecoder decodeObjectForKey:@"bounds"] CGRectValue];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeInteger:_index forKey:@"index"];
    [aCoder encodeInteger:_row forKey:@"row"];
    [aCoder encodeObject:(__bridge id _Nullable)(_CTLine) forKey:@"CTLine"];
    [aCoder encodeObject:[NSValue valueWithRange:_range] forKey:@"_range"];
    [aCoder encodeObject:@(_position) forKey:@"position"];
    [aCoder encodeDouble:_ascent forKey:@"ascent"];
    [aCoder encodeDouble:_descent forKey:@"descent"];
    [aCoder encodeDouble:_leading forKey:@"leading"];
    [aCoder encodeDouble:_lineWidth forKey:@"lineWidth"];
    [aCoder encodeDouble:_trailingWhitespaceWidth forKey:@"trailingWhitespaceWidth"];
    [aCoder encodeObject:@(_bounds) forKey:@"bounds"];
}

#pragma mark - Init
+ (instancetype)lineWithCTLine:(CTLineRef)CTLine position:(CGPoint)position {
    if (!CTLine) return nil;
    MWTextLine *line = [self new];
    line->_position = position;
    [line setCTLine:CTLine];
    return line;
}

- (void)dealloc {
    if (_CTLine) CFRelease(_CTLine);
}

- (void)setCTLine:(_Nonnull CTLineRef)CTLine {
    if (_CTLine != CTLine) {
        if (CTLine) CFRetain(CTLine);
        if (_CTLine) CFRelease(_CTLine);
        _CTLine = CTLine;
        if (_CTLine) {
            _lineWidth = CTLineGetTypographicBounds(_CTLine, &_ascent, &_descent, &_leading);
            CFRange range = CTLineGetStringRange(_CTLine);
            _range = NSMakeRange(range.location, range.length);
            if (CTLineGetGlyphCount(_CTLine) > 0) {
                CFArrayRef runs = CTLineGetGlyphRuns(_CTLine);
                CTRunRef run = CFArrayGetValueAtIndex(runs, 0);
                CGPoint pos;
                CTRunGetPositions(run, CFRangeMake(0, 1), &pos);
                _firstGlyphPos = pos.x;
            } else {
                _firstGlyphPos = 0;
            }
            _trailingWhitespaceWidth = CTLineGetTrailingWhitespaceWidth(_CTLine);
        } else {
            _lineWidth = _ascent = _descent = _leading = _firstGlyphPos = _trailingWhitespaceWidth = 0;
            _range = NSMakeRange(0, 0);
        }
        [self reloadBounds];
    }
}

- (void)setPosition:(CGPoint)position {
    _position = position;
    [self reloadBounds];
}

- (void)reloadBounds {
    _bounds = CGRectMake(_position.x, _position.y - _ascent, _lineWidth, _ascent + _descent);
    _bounds.origin.x += _firstGlyphPos;
    
    if (!_CTLine) return;
    CFArrayRef runs = CTLineGetGlyphRuns(_CTLine);
    NSUInteger runCount = CFArrayGetCount(runs);
    if (runCount == 0) return;
    
    for (NSUInteger r = 0; r < runCount; r++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, r);
        CFIndex glyphCount = CTRunGetGlyphCount(run);
        if (glyphCount == 0) continue;
    }
}

- (CGSize)size {
    return _bounds.size;
}

- (CGFloat)width {
    return CGRectGetWidth(_bounds);
}

- (CGFloat)height {
    return CGRectGetHeight(_bounds);
}

- (CGFloat)top {
    return CGRectGetMinY(_bounds);
}

- (CGFloat)bottom {
    return CGRectGetMaxY(_bounds);
}

- (CGFloat)left {
    return CGRectGetMinX(_bounds);
}

- (CGFloat)right {
    return CGRectGetMaxX(_bounds);
}

@end
