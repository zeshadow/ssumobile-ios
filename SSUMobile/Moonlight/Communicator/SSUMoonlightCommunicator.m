//
//  SSUMoonlightCommunicator.m
//  SSUMobile
//
//  Created by Andrew Huss on 1/22/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

@import UIKit;

#import "SSUMoonlightCommunicator.h"
#import "SSULogging.h"

@interface SSUMoonlightCommunicator()

@end

@implementation SSUMoonlightCommunicator

#pragma mark - Downloads

+ (void) getJSONFromPath:(NSString *)path completion:(SSUCommunicatorJSONCompletion)completion {
    [self getJSONFromPath:path sinceDate:nil completion:completion];
}

/**
 Downloads JSON from the given path, relative to the base moonlight URL.
 */
+ (void) getJSONFromPath:(NSString *)path
               sinceDate:(NSDate *)lastUpdate
              completion:(SSUCommunicatorJSONCompletion)completion {
    
    NSString * urlBase = [SSUMoonlightBaseURL stringByAppendingPathComponent:path];
    NSString * fullURL = urlBase;
    if (lastUpdate != nil) {
        NSString * dateString = [self.dateFormatter stringFromDate:lastUpdate];
        if (dateString != nil) {
            fullURL = [fullURL stringByAppendingFormat:@"?date=%@", [dateString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    NSURL* url = [NSURL URLWithString:fullURL];
    [self getJSONFromURL:url completion:completion];
}

@end
