//
//  SSULogging.h
//  SSUMobile
//
//  Created by Eric Amorde on 10/28/15.
//  Copyright © 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

//Note: this value must be named 'ddLogLevel', as the macros search for this symbol
#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
static const DDLogLevel ddLogLevel = DDLogLevelError;
#endif

@interface SSULogging : NSObject

+ (void) setupLogging;

#define SSULogError(frmt, ...)   DDLogError(frmt, ##__VA_ARGS__)
#define SSULogWarn(frmt, ...)    DDLogWarn(frmt, ##__VA_ARGS__)
#define SSULogInfo(frmt, ...)    DDLogInfo(frmt, ##__VA_ARGS__)
#define SSULogDebug(frmt, ...)   DDLogDebug(frmt, ##__VA_ARGS__)
#define SSULogVerbose(frmt, ...) DDLogVerbose(frmt, ##__VA_ARGS__)

@end
