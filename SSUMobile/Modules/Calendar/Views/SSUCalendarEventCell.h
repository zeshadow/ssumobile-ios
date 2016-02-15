//
//  SSUCalendarEventCell.h
//  SSUMobile
//
//  Created by Eric Amorde on 11/9/14.
//  Copyright (c) 2014 Sonoma State University Department of Computer Science. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSUEvent.h"

@interface SSUCalendarEventCell : UITableViewCell

@property (nonatomic) IBOutlet UILabel * subtitleLabel;
@property (nonatomic) IBOutlet UILabel * titleLabel;

@property (nonatomic) SSUEvent * event;

@end
