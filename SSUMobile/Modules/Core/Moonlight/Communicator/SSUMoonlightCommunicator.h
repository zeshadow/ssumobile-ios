//
//  SSUMoonlightCommunicator.h
//  SSUMobile
//
//  Created by Andrew Huss on 1/22/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

@import Foundation;

#import "SSUCommunicator.h"

/**
 Provides support for pulling from URLS specific to the Moonlight API
 */
@interface SSUMoonlightCommunicator : SSUCommunicator

+ (void) getJSONFromPath:(NSString *)path
              completion:(SSUCommunicatorJSONCompletion)completion;

+ (void) getJSONFromPath:(NSString *)path
               sinceDate:(NSDate *)date
              completion:(SSUCommunicatorJSONCompletion)completion;

+ (void) postPath:(NSString *)path
       parameters:(NSDictionary *)params
       completion:(SSUCommunicatorCompletion)completion;

/** Posts to the given path and parses the response as JSON */
+ (void) postJSONPath:(NSString *)path
           parameters:(NSDictionary *)params
           completion:(SSUCommunicatorJSONCompletion)completion;

+ (NSURL *) urlForPath:(NSString *)path;


@end
