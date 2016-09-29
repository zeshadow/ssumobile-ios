//
//  SSUSharedUtilities.m
//  SSUMobile
//
//  Created by Eric Amorde on 9/14/2015.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

NSString * const kSSUErrorDomain = @"edu.sonoma.cs.ssumobile";
const NSInteger kSSUGenericErrorCode = 100;
NSString * const SSUAppIsFirstLaunchKey = @"SSUAppIsFirstLaunch";
NSString * const SSUMoonlightBaseURL = @"https://moonlight.cs.sonoma.edu/api/v1/";

NSURL * URLForDirectory(NSSearchPathDirectory directory) {
    return [[[NSFileManager defaultManager] URLsForDirectory:directory
                                                   inDomains:NSUserDomainMask] firstObject];
}

NSURL * SSUDocumentsDirectory() {
    return URLForDirectory(NSDocumentDirectory);
}

NSURL * SSUCachesDirectory() {
    return URLForDirectory(NSCachesDirectory);
}

NSURL * SSUApplicationSupportDirectory() {
    return URLForDirectory(NSApplicationSupportDirectory);
}
