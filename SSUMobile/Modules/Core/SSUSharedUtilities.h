//
//  SSUSharedUtilities.h
//  SSUMobile
//
//  Created by Eric Amorde on 9/14/2015.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

@import Foundation;

#define AppDelegate ((SSUAppDelegate*)[[UIApplication sharedApplication] delegate])

/** Colors */
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define SSU_BLUE_COLOR RGBA(20, 59, 135, 1.0)

/** Strings */
#define SSUTrimString(str) ((id)str == [NSNull null] || str == nil) ? @"" : [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
#define SSUIsEmptyString(str) (str == nil || (id)str == [NSNull null] || [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)

/// Returns an NSURL object for the specified search path
extern NSURL * SSUURLForDirectory(NSSearchPathDirectory directory);
/// The URL of the application's cache directory, for files which should persist but can be recreated
extern NSURL * SSUCachesDirectory();
/// The URL of the application's documents directory, where user files should be stored
extern NSURL * SSUDocumentsDirectory();
/// The URL for app-created files which are needed to function properly but should be hidden from the user
extern NSURL * SSUApplicationSupportDirectory();

/** Constants */
extern NSString * const kSSUErrorDomain;
extern const NSInteger kSSUGenericErrorCode;
extern NSString * const SSUAppIsFirstLaunchKey;
extern NSString * const SSUMoonlightBaseURL;

