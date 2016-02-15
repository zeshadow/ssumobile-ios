//
//  SSUCalendarEventDetail.h
//  SSUMobile
//
//  Created by Eric Amorde on 9/28/14.
//  Copyright (c) 2014 Computer Science. All rights reserved.
//

#import "SSUEvent.h"

@interface SSUCalendarEventDetail : UITableViewController

@property(nonatomic) SSUEvent *event;

@property (nonatomic) IBOutlet UILabel * titleLabel;
@property (nonatomic) IBOutlet UILabel * categoryLabel;
@property (nonatomic) IBOutlet UILabel * dateLabel;
@property (nonatomic) IBOutlet UILabel * locationLabel;
@property (nonatomic) IBOutlet UIWebView * descriptionWebView;

@end
