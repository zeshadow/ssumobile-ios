//
//  SSUFeedbackViewController.h
//  SSUMobile
//
//  Created by Eric Amorde on 11/27/14.
//  Copyright (c) 2014 Computer Science. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * SSUUserDefaultsLastFeedbackDate;

@interface SSUFeedbackViewController : UITableViewController <UITextViewDelegate>

@property (nonatomic,weak) IBOutlet UITextView * textView;
@property (nonatomic,weak) IBOutlet UITextField * emailTextField;

@end
