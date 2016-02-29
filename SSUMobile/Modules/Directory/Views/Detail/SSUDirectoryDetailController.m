//
//  SSUDirectoryDetailController.m
//  SSUMobile
//
//  Created by Eric Amorde on 1/9/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUDirectoryDetailController.h"
#import "SSUDirectoryConstants.h"
#import "SSULogging.h"

@interface SSUDirectoryDetailController () <UIAlertViewDelegate>

@end

@implementation SSUDirectoryDetailController

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.navigationItem.rightBarButtonItem == nil) {
        UIImage * buttonImage = [UIImage imageNamed:@"directory_home"];
        UIBarButtonItem * homeButton = [[UIBarButtonItem alloc] initWithImage:buttonImage style:UIBarButtonItemStylePlain target:self action:@selector(homeButtonPressed:)];
        self.navigationItem.rightBarButtonItem = homeButton;
    }
}

- (void) homeButtonPressed:(UIBarButtonItem *)button {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/**
 So we don't have to maintain segues between all of the directory detail views
 and to avoid having to add 4-5 segues if we add a new entity, load and push
 the view controllers from the storyboard instead. Or just use segues.
 */
- (void) showDetailForObject:(SSUDirectoryObject *)object animated:(BOOL)animated {
    if (object == nil) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(detailTableView:didSelectObject:)]) {
        [self.delegate detailTableView:self didSelectObject:object];
        return;
    }
    
    UIStoryboard * storyBoard;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        storyBoard = [UIStoryboard storyboardWithName:SSUDirectoryStoryboardiPhone bundle:nil];
    } else {
        storyBoard = [UIStoryboard storyboardWithName:SSUDirectoryStoryboardiPad bundle:nil];
    }
    NSString * identifier = NSStringFromClass([object class]);
    SSUDirectoryDetailController * detail = [storyBoard instantiateViewControllerWithIdentifier:identifier];
    [detail loadObject:object inContext:object.managedObjectContext];
    if (self.navigationController) {
        [self.navigationController pushViewController:detail animated:animated];
    } else {
        [self presentViewController:detail animated:animated completion:NULL];
    }
}

#pragma mark - Cell Actions

static const NSInteger kConfirmCallTag = 100;
static const NSInteger kConfirmWebsiteTag = 200;
static const NSInteger kConfirmEmailTag = 300;

- (void) confirmCallPhoneNumber {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Call this number"
                                                     message:@"Would you like to make a phone call to the selected number?"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Call", nil];
    alert.tag = kConfirmCallTag;
    [alert show];
}

- (void) confirmNavigateToWebsite {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Load webpage?"
                                                     message:@"Would you like to load this webpage in Safari?"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Confirm", nil];
    alert.tag = kConfirmWebsiteTag;
    [alert show];
}

- (void) confirmShowEmailComposer {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Compose email?"
                                                     message:@"Would you like to compose an email message to this address?"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Confirm", nil];
    alert.tag = kConfirmWebsiteTag;
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    if (alertView.tag == kConfirmCallTag) {
        [self callPhoneNumber];
    }
    else if (alertView.tag == kConfirmWebsiteTag) {
        [self navigateToWebsite];
    }
    else if (alertView.tag == kConfirmEmailTag) {
        [self showEmailComposer];
    }
}

- (void) callPhoneNumber {
    SSULogError(@"User requested phone call but detail did not implement `callPhoneNumber`");
}

- (void) navigateToWebsite {
    SSULogError(@"User requested website navigation but detail did not implement `navigateToWebsite`");
}

- (void) showEmailComposer {
    SSULogError(@"User requested email composer but detail did not implement `showEmailComposer`");
}

@end
