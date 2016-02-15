//
//  SSULogging.m
//  SSUMobile
//
//  Created by Eric Amorde on 10/28/15.
//  Copyright © 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSULogging.h"

@implementation SSULogging

+ (void) setupLogging {
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
}

@end
