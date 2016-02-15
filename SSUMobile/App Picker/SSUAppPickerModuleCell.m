//
//  SSUAppPickerModuleCell.m
//  SSUMobile
//
//  Created by Eric Amorde on 9/17/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUAppPickerModuleCell.h"
#import <Masonry/Masonry.h>

@interface SSUAppPickerModuleCell()

@property (nonatomic, strong) IBOutlet UIButton * button;
@property (nonatomic, strong) IBOutlet UILabel * moduleLabel;

@end

@implementation SSUAppPickerModuleCell

- (void) setModule:(id<SSUModuleUI>)module {
    if (_module == module) return;
    
    _module = module;
    [self.button setImage:[_module imageForHomeScreen] forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.button.contentMode = UIViewContentModeScaleAspectFit;
    self.button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.button.accessibilityLabel = [_module title];
    self.moduleLabel.text = [_module title];
}

- (void) buttonPressed:(UIButton *)button {
    [self.delegate moduleCellWasSelected:self];
}

@end
