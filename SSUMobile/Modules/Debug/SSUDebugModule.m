//
//  SSUDebugModule.m
//  SSUMobile
//
//  Created by Eric Amorde on 9/17/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUDebugModule.h"

@implementation SSUDebugModule

+ (instancetype) sharedInstance {
    static SSUDebugModule * instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - SSUModule

- (nonnull NSString *) title {
    return @"Debug";
}

- (nonnull NSString *) identifier {
    return @"debug";
}

- (UIView *) viewForHomeScreen {
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"debug_icon"]];
}

- (UIImage *) imageForHomeScreen {
    return [UIImage imageNamed:@"debug_icon"];
}

- (UIViewController *) initialViewController {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Debug"
                                                          bundle:[NSBundle bundleForClass:[self class]]];
    return [storyboard instantiateInitialViewController];
}

- (BOOL) showModuleInNavigationBar {
    return NO;
}

- (BOOL) shouldNavigateToModule {
    return YES;
}

@end
