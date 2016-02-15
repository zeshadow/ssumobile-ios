//
//  SSUAboutModule.m
//  SSUMobile
//
//  Created by Eric Amorde on 9/9/15.
//  Copyright (c) 2015 Computer Science. All rights reserved.
//

#import "SSUAboutModule.h"

@implementation SSUAboutModule

+ (instancetype) sharedInstance {
    static SSUAboutModule * instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - SSUModule

- (NSString *) title {
    return NSLocalizedString(@"About",
                             @"General information about the app. \'Info\'");
}

- (UIView *) viewForHomeScreen {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeInfoLight];
    return button;
}

- (UIImage *) imageForHomeScreen {
    return nil;
}

- (BOOL) showModuleInNavigationBar {
    return YES;
}

- (UIViewController *) initialViewController {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"About"
                                                          bundle:[NSBundle bundleForClass:[self class]]];
    return [storyboard instantiateInitialViewController];
}

@end
