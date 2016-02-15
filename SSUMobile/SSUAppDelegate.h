//
//  SSUAppDelegate.h
//  SSUMobile
//
//  Created by Andrew Huss on 1/24/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSUModuleBase.h"

#define AppDelegate ((SSUAppDelegate*)[[UIApplication sharedApplication] delegate])

@interface SSUAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow * window;

/** All SSUModule(UI) instances that were loaded on launch */
@property (nonatomic, readonly) NSArray<SSUModule> * modules;
/** All SSUModuleUI instances */
@property (nonatomic, readonly) NSArray<SSUModuleUI> * modulesUI;

- (void) updateAll;

- (NSURL *)applicationDocumentsDirectory;

@end
