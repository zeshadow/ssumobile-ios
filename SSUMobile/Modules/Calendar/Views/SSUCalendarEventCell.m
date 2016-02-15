//
//  SSUCalendarEventCell.m
//  SSUMobile
//
//  Created by Eric Amorde on 11/9/14.
//  Copyright (c) 2014 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUCalendarEventCell.h"

@implementation SSUCalendarEventCell

- (UIEdgeInsets) layoutMargins {
    return UIEdgeInsetsZero;
}

- (UIEdgeInsets) separatorInset {
    return UIEdgeInsetsZero;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.textColor = SSU_BLUE_COLOR;
}

- (void) setEvent:(SSUEvent *)event
{
    _event = event;
    self.titleLabel.text = event.title;
    NSString * startTime = [NSDateFormatter localizedStringFromDate:event.startDate
                                                          dateStyle:NSDateFormatterNoStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    if (SSUIsEmptyString(event.location)) {
        self.subtitleLabel.text = startTime;
    }
    else {
        self.subtitleLabel.text = [NSString stringWithFormat:@"%@ - %@",startTime, SSUTrimString(event.location)];
    }
}

@end
