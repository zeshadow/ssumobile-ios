//
//  SSUTableHeaderView.m
//  SSUMobile
//
//  Created by Eric Amorde on 8/31/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUTableHeaderView.h"
#import <Masonry/Masonry.h>

@implementation SSUTableHeaderView

- (instancetype) initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = SSU_BLUE_COLOR;
        
        _headerTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        self.headerTextLabel.textColor = [UIColor whiteColor];
        self.headerTextLabel.font = self.textLabel.font;
        self.textLabel.hidden = YES;
        [self.contentView addSubview:self.headerTextLabel];
    }
    
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    self.headerTextLabel.font = self.textLabel.font;
    if (self.contentView.frame.size.height == 0 || self.contentView.frame.size.width == 0) {
        return;
    }
    CGSize textSize = [self.headerTextLabel.text sizeWithAttributes:@{NSFontAttributeName: self.headerTextLabel.font}];
    [self.headerTextLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.headerTextLabel.superview.mas_bottom).with.offset(-2.0);
        make.left.equalTo(self.headerTextLabel.superview.mas_left).with.offset(10.0);
        make.width.equalTo(self.contentView.mas_width).with.offset(-20.0);
        make.height.mas_equalTo(textSize.height);
    }];
}

- (void) prepareForReuse {
    [super prepareForReuse];
    self.headerTextLabel.text = nil;
}

@end
