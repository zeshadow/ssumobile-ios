//
//  SSUCollectionViewCellSeparatorView.m
//  SSUMobile
//
//  Created by Eric Amorde on 8/31/15.
//  Copyright (c) 2015 Computer Science. All rights reserved.
//

#import "SSUCollectionViewCellSeparatorView.h"

@interface SSUCollectionViewCellSeparatorView()

@property (nonatomic) CAShapeLayer * separatorLayer;

@end

@implementation SSUCollectionViewCellSeparatorView

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.separatorLayer = [CAShapeLayer layer];
        [self.layer addSublayer:self.separatorLayer];
        
        self.backgroundColor = [UIColor clearColor];
        self.separatorColor = [UIColor lightGrayColor];
        self.separatorLineWidth = 1.0;
        self.separator = SSUCellSeparatorNone;
    }
    
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    [self resetPath];
}

- (void) resetPath {
    UIBezierPath * path = [UIBezierPath bezierPath];
    if (self.separator == SSUCellSeparatorNone) {
        self.separatorLayer.path = path.CGPath;
        return;
    }
    
    const CGPoint origin = self.bounds.origin;
    const CGFloat width = self.bounds.size.width + 1;
    const CGFloat height = self.bounds.size.height;
    
    if ((self.separator & SSUCellSeparatorTop) != 0) {
        const CGPoint start = CGPointMake(origin.x, origin.y);
        const CGPoint end = CGPointMake(width, origin.y);
        [path moveToPoint:start];
        [path addLineToPoint:end];
    }
    if ((self.separator & SSUCellSeparatorRight) != 0) {
        const CGPoint start = CGPointMake(width, origin.y);
        const CGPoint end = CGPointMake(width, height);
        [path moveToPoint:start];
        [path addLineToPoint:end];
    }
    if ((self.separator & SSUCellSeparatorBottom) != 0) {
        const CGPoint start = CGPointMake(origin.x, height);
        const CGPoint end = CGPointMake(width, height);
        [path moveToPoint:start];
        [path addLineToPoint:end];
    }
    if ((self.separator & SSUCellSeparatorLeft) != 0) {
        const CGPoint start = CGPointMake(origin.x, origin.y);
        const CGPoint end = CGPointMake(origin.x, height);
        [path moveToPoint:start];
        [path addLineToPoint:end];
    }
    
    self.separatorLayer.path = path.CGPath;
}

- (void) setSeparatorColor:(UIColor *)separatorColor {
    _separatorColor = separatorColor;
    self.separatorLayer.strokeColor = _separatorColor.CGColor;
}

- (void) setSeparatorLineWidth:(CGFloat)separatorLineWidth {
    _separatorLineWidth = separatorLineWidth;
    self.separatorLayer.lineWidth = separatorLineWidth;
}

- (void) setSeparator:(SSUCellSeparator)separator {
    if (_separator != separator) {
        _separator = separator;
        [self resetPath];
    }
}

@end
