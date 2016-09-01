//
//  SSUAppDelegate.h
//  SSUMobile
//
//  Created by Andrew Huss on 1/24/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

@import UIKit;
#import "SSUModuleBase.h"

#define AppDelegate ((SSUAppDelegate*)[[UIApplication sharedApplication] delegate])

@interface SSUAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow * window;

@end
