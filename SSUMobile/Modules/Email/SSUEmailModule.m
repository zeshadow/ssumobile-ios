//
//  SSUEmailModule.m
//  SSUMobile
//
//  Created by Eric Amorde on 9/9/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUEmailModule.h"
#import "SSUEmailConstants.h"

@implementation SSUEmailModule

+ (instancetype) sharedInstance {
    static SSUEmailModule * instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - SSUModule

- (NSString *) title {
    return NSLocalizedString(@"Email",
                             @"Provides access to campus email accounts");
}

- (UIView *) viewForHomeScreen {
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"email_icon"]];
}

- (UIImage *) imageForHomeScreen {
    return [UIImage imageNamed:@"email_icon"];
}

- (BOOL) shouldNavigateToModule {
    // Email login isn't working since the backend has changed.
    // Since this can happen at any time in the future, for now we
    // are just going to open the login in Safari
    NSURL * loginURL = [NSURL URLWithString:SSUEmailLDAPURL];
    [[UIApplication sharedApplication] openURL:loginURL];
    return NO;
}

- (UIViewController *) initialViewController {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Email"
                                                          bundle:[NSBundle bundleForClass:[self class]]];
    return [storyboard instantiateInitialViewController];
}

- (BOOL) showModuleInNavigationBar {
    return NO;
}

@end
