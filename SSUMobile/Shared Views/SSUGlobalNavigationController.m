//
//  SSUGlobalNavigationController.m
//  SSUMobile
//
//  Created by Eric Amorde on 01/09/2016.
//  Copyright © 2016 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUGlobalNavigationController.h"

static SSUGlobalNavigationController * instance = nil;

@interface SSUGlobalNavigationController ()

@end

@implementation SSUGlobalNavigationController

+ (instancetype) sharedInstance {
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (instance == nil) {
        instance = self;
    }
}

@end
