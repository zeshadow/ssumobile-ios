//
//  SSUCalendarMonthViewController.h
//  SSUMobile
//
//  Created by Eric Amorde on 9/28/14.
//  Copyright (c) 2014 Computer Science. All rights reserved.
//

@import UIKit;

#import <PDTSimpleCalendar/PDTSimpleCalendar.h>

@interface SSUCalendarViewController : PDTSimpleCalendarViewController

@property (nonatomic) IBOutlet UITableView * tableView;

@end
