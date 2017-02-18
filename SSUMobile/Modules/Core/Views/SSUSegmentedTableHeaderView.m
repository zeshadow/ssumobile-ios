//
//  SSUSegmentedTableHeaderView.m
//  SSUMobile
//
//  Created by Eric Amorde on 10/12/15.
//  Copyright © 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUSegmentedTableHeaderView.h"

#import <Masonry/Masonry.h>

@interface SSUSegmentedTableHeaderView()

@end

@implementation SSUSegmentedTableHeaderView

- (void) layoutSubviews {
    [super layoutSubviews];
    
    if (self.contentView.frame.size.height == 0 || self.contentView.frame.size.width == 0) {
        return;
    }
    
    [self.segmentedControl mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segmentedControl.superview.mas_top);
        make.left.equalTo(self.segmentedControl.superview.mas_left);
        make.right.equalTo(self.segmentedControl.superview.mas_right);
    }];
}

- (void) setSegmentedControl:(UISegmentedControl *)segmentedControl {
    _segmentedControl = segmentedControl;
    [self.contentView addSubview:_segmentedControl];
    [self setNeedsLayout];
}

@end
