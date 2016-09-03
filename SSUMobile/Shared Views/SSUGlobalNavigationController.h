//
//  SSUGlobalNavigationController.h
//  SSUMobile
//
//  Created by Eric Amorde on 01/09/2016.
//  Copyright © 2016 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUNavigationController.h"

@interface SSUGlobalNavigationController : SSUNavigationController

/** The main navigation controller for the entire application */
+ (instancetype) sharedInstance;

@end
