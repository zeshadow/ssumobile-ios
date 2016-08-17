//
//  SSUAboutModule.m
//  SSUMobile
//
//  Created by Eric Amorde on 9/9/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
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

- (nonnull NSString *) title {
    return NSLocalizedString(@"About",
                             @"General information about the app. \'Info\'");
}

- (nonnull NSString *) identifier {
    return @"about";
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

- (BOOL) shouldNavigateToModule {
    return YES;
}

- (UIViewController *) initialViewController {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"About"
                                                          bundle:[NSBundle bundleForClass:[self class]]];
    return [storyboard instantiateInitialViewController];
}

@end
