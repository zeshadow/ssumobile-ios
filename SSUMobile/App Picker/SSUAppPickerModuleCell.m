//
//  SSUAppPickerModuleCell.m
//  SSUMobile
//
//  Created by Eric Amorde on 9/17/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUAppPickerModuleCell.h"
#import "SSUMobile-Swift.h"
#import <Masonry/Masonry.h>

@interface SSUAppPickerModuleCell()

@property (nonatomic, strong) IBOutlet UIButton * button;
@property (nonatomic, strong) IBOutlet UILabel * moduleLabel;

@end

@implementation SSUAppPickerModuleCell

- (void) setModule:(id<SSUModuleUI>)module {
    if (_module == module) return;
    
    _module = module;
    
    [self updateDisplay];
}

- (void) updateDisplay {
    [self.button setImage:[self.module imageForHomeScreen] forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.button.contentMode = UIViewContentModeScaleAspectFit;
    self.button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.button.accessibilityLabel = self.module.title;
    self.moduleLabel.text = self.module.title;
    
    const CGFloat offset = 8.0;
    
    [self.button mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.button.superview);
        make.left.equalTo(self.button.superview).offset(offset);
        make.right.equalTo(self.button.superview).offset(-offset);
        make.bottom.equalTo(self.moduleLabel.mas_top).offset(-offset);
    }];
    
    [self.moduleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.button.mas_bottom);
        make.left.equalTo(self.moduleLabel.superview).offset(offset);
        make.right.equalTo(self.moduleLabel.superview).offset(offset);
        make.bottom.equalTo(self.moduleLabel.superview).offset(-offset/2.0);
    }];
    
    [self.moduleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
}

- (void) buttonPressed:(UIButton *)button {
    [self.delegate moduleCellWasSelected:self];
}

@end
