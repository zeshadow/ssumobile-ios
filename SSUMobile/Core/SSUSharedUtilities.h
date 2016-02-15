//
//  SSUSharedUtilities.h
//  SSUMobile
//
//  Created by Eric Amorde on 9/14/2015.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

/** Colors */
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define SSU_BLUE_COLOR RGBA(20, 59, 135, 1.0)

/** Strings */
#define SSUTrimString(str) ((id)str == [NSNull null] || str == nil) ? @"" : [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
#define SSUIsEmptyString(str) (str == nil || (id)str == [NSNull null] || [SSUTrimString(str) length] == 0)

/** Constants */
extern NSString * const kSSUErrorDomain;
extern const NSInteger kSSUGenericErrorCode;
extern NSString * const SSUAppIsFirstLaunchKey;

