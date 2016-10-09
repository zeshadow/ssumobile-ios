//
//  SSUFeedbackViewController.m
//  SSUMobile
//
//  Created by Eric Amorde on 11/27/14.
//  Copyright (c) 2014 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUFeedbackViewController.h"
#import "SSULogging.h"
#import "SSUMoonlightCommunicator.h"
#import <MBProgressHUD/MBProgressHUD.h>

static NSString * SSUUserDefaultsLastFeedbackDate = @"LastFeedbackDate";
static NSTimeInterval WAIT_PERIOD = 60.0;

@interface SSUFeedbackViewController ()

@property (nonatomic) BOOL hasBegunEditing;
@property (nonatomic) BOOL submitting;
@property (nonatomic,strong) NSString * placeholderText;
@property (nonatomic,strong) UIBarButtonItem * sendButton;

@end

@implementation SSUFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hasBegunEditing = NO;
    self.placeholderText = self.textView.text;
    
    self.sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(sendButtonPressed)];
    self.navigationItem.rightBarButtonItem = self.sendButton;
    self.sendButton.enabled = NO;
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
                                                              SSUUserDefaultsLastFeedbackDate : @([[NSDate distantPast] timeIntervalSinceReferenceDate])
                                                              }];
}

#pragma mark - UITextViewDelegate

- (void) textViewDidBeginEditing:(UITextView *)textView {
    if (!self.hasBegunEditing) {
        // The first time the user begins editing, clear the placeholder text.
        textView.text = @"";
        self.hasBegunEditing = YES;
    }
}

- (void) textViewDidChange:(UITextView *)textView {
    NSString * text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.sendButton.enabled = ![text isEqualToString:@""];
}

- (void) textViewDidEndEditing:(UITextView *)textView {
    NSString * text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([text isEqualToString:@""]) {
        // If the user didn't enter anything, reset to the original state
        textView.text = self.placeholderText;
        self.hasBegunEditing = NO;
    }
}

#pragma mark - Button Actions

- (void) sendButtonPressed {
    NSString * content = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString * email = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([content isEqualToString:@""]) {
        return;
    }
    [self sendFeedbackWithContent:content email:email];
    
}

#pragma mark - Other

/**
 Send feedback to moonlight
 
 @param content The text of the feedback/suggestion
 @param email The email of the user, or an empty string
 */
- (void) sendFeedbackWithContent:(NSString *)content email:(NSString *)email {
    if (self.submitting) {
        return;
    }
    if (![self canSubmitFeedback]) {
        [self alertWithTitle:@"Unable to Send feedback"
                     message:@"You recently submitted some feedback to us. Please wait a few minutes before sending another submission"];
        return;
    }
    self.submitting = YES;
    NSString * baseURL = [SSUMoonlightBaseURL stringByAppendingPathComponent:@"createFeedback"];
    NSString * version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    id params = @{
                  @"content" : content,
                  @"email" : email,
                  @"version" : version,
                  };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [SSUMoonlightCommunicator postURL:[NSURL URLWithString:baseURL]
                           parameters:params
                           completion:^(NSURLResponse * response, NSData * data, NSError * error) {
                         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                         self.submitting = NO;
                         if (error) {
                             [self alertWithTitle:@"Error" message:@"Sorry, something went wrong. Try again later."];
                             SSULogError(@"Error during feedback submission: %@",error);
                         }
                         else {
                             [self alertWithTitle:@"Success" message:@"Thank you for your feedback!"];
                             self.emailTextField.text = @"";
                             self.textView.text = @"";
                             [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSinceReferenceDate] forKey:SSUUserDefaultsLastFeedbackDate];
                         }
                     }];
}

/**
 Only allow the user to submit multiple entries after waiting for a
 defined time period
 */
- (BOOL) canSubmitFeedback {
    NSTimeInterval lastSubmission = [[NSUserDefaults standardUserDefaults] doubleForKey:SSUUserDefaultsLastFeedbackDate];
    NSDate * date = [NSDate dateWithTimeIntervalSinceReferenceDate:lastSubmission];
    NSTimeInterval sinceLastSubmission = ABS([date timeIntervalSinceNow]);
    return sinceLastSubmission >= WAIT_PERIOD;
}

- (void) alertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [alert show];
}

@end
