//
//  SSURadioModule.m
//  SSUMobile
//
//  Created by Eric Amorde on 9/8/15.
//  Copyright (c) 2015 Computer Science. All rights reserved.
//

#import "SSURadioModule.h"

@implementation SSURadioModule

+ (instancetype) sharedInstance {
    static SSURadioModule * instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - SSUModule

- (NSString *) title {
    return NSLocalizedString(@"Radio",
                             @"The campus online radio status - KSUN Radio");
}

- (UIView *) viewForHomeScreen {
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"radio_icon"]];
}

- (UIImage *) imageForHomeScreen {
    return [UIImage imageNamed:@"radio_icon"];
}

- (UIViewController *) initialViewController {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Radio_iPhone"
                                                          bundle:[NSBundle bundleForClass:[self class]]];
    return [storyboard instantiateInitialViewController];
}

- (BOOL) showModuleInNavigationBar {
    return NO;
}

@end
