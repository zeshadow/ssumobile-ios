//
//  SSUAppPickerModuleCell.h
//  SSUMobile
//
//  Created by Eric Amorde on 9/17/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

@import UIKit;
#import "SSUMobile-Swift.h"

@class SSUAppPickerModuleCell;

@protocol SSUModuleCellDelegate <NSObject>

- (void) moduleCellWasSelected:(SSUAppPickerModuleCell *)cell;

@end

@interface SSUAppPickerModuleCell : UICollectionViewCell

@property (nonatomic, weak) id<SSUModuleUI> module;
@property (nonatomic, weak) id<SSUModuleCellDelegate> delegate;

@end
