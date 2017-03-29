//
//  SSUMoonlightCommunicator.h
//  SSUMobile
//
//  Created by Andrew Huss on 1/22/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

@import Foundation;

#import "SSUCommunicator.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Provides support for pulling from URLS specific to the Moonlight API
 */
@interface SSUMoonlightCommunicator : SSUCommunicator

+ (void) getJSONFromPath:(NSString *)path
              completion:(SSUCommunicatorJSONCompletion _Nullable)completion;

+ (void) getJSONFromPath:(NSString *)path
               sinceDate:(NSDate * _Nullable)date
              completion:(SSUCommunicatorJSONCompletion _Nullable)completion;

+ (void) postPath:(NSString *)path
       parameters:(NSDictionary * _Nullable)params
       completion:(SSUCommunicatorCompletion _Nullable)completion;

/** Posts to the given path and parses the response as JSON */
+ (void) postJSONPath:(NSString *)path
           parameters:(NSDictionary * _Nullable)params
           completion:(SSUCommunicatorJSONCompletion _Nullable)completion;

+ (NSURL * _Nullable) urlForPath:(NSString * _Nullable)path;

@end

NS_ASSUME_NONNULL_END
