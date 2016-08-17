//
//  SSUEmailModule.m
//  SSUMobile
//
//  Created by Eric Amorde on 9/9/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUEmailModule.h"
#import "SSUEmailConstants.h"
#import "SSUConfiguration.h"

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

- (nonnull NSString *) title {
    return NSLocalizedString(@"Email",
                             @"Provides access to campus email accounts");
}

- (nonnull NSString *) identifier {
    return @"email";
}

- (UIView *) viewForHomeScreen {
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"email_icon"]];
}

- (UIImage *) imageForHomeScreen {
    return [UIImage imageNamed:@"email_icon"];
}

- (BOOL) shouldNavigateToModule {
    if (![[SSUConfiguration sharedInstance] boolForKey:SSUEmailLoginEnabledKey]) {
        // The custom login must be broken (ex. something changed on Sonoma's website)
        // so we will show the user the webpage instead
        NSURL * loginURL = [NSURL URLWithString:[[SSUConfiguration sharedInstance] stringForKey:SSUEmailLDAPURLKey]];
        [[UIApplication sharedApplication] openURL:loginURL];
        return NO;
    }
    return YES;
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
