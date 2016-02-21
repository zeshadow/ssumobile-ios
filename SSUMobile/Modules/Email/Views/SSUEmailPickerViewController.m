//
//  SSUEmailPickerViewController.m
//  SSUMobile
//
//  Created by Eric Amorde on 7/26/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUEmailPickerViewController.h"
#import "SSUEmailViewController.h"
#import "SSUEmailConstants.h"

static NSString * const kExchangeSegue = @"exchange";
static NSString * const kGoogleDocsSegue = @"gdocs";

@interface SSUEmailPickerViewController ()

@end

@implementation SSUEmailPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Email login isn't working since the backend has changed.
    // Since this can happen at any time in the future, for now we
    // are just going to open the login in Safari
    
    NSArray * subviews = self.view.subviews;
    for (UIView * subview in subviews) {
        [subview removeFromSuperview];
    }
    NSURL * loginURL = [NSURL URLWithString:SSUEmailLDAPURL];
    [[UIApplication sharedApplication] openURL:loginURL];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SSUEmailViewController * emailViewController = segue.destinationViewController;
    if ([segue.identifier isEqualToString:kExchangeSegue]) {
        emailViewController.mode = SSUEmailViewControllerModeEmail;
    }
    else if ([segue.identifier isEqualToString:kGoogleDocsSegue]) {
        emailViewController.mode = SSUEmailViewControllerModeGoogleDocs;
    }
}

@end
