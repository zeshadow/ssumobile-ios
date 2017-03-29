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

+ (NSURL * _Nullable) baseURLStringForPath:(NSString *)path {
    NSURL * baseURL = [NSURL URLWithString:SSUMoonlightBaseURL];
    return [baseURL URLByAppendingPathComponent:path];
}

#pragma mark - Downloads

+ (void) getJSONFromPath:(NSString *)path completion:(SSUCommunicatorJSONCompletion _Nullable)completion {
    [self getJSONFromPath:path sinceDate:nil completion:completion];
}

/**
 Downloads JSON from the given path, relative to the base moonlight URL.
 */
+ (void) getJSONFromPath:(NSString *)path
               sinceDate:(NSDate * _Nullable)lastUpdate
              completion:(SSUCommunicatorJSONCompletion _Nullable)completion {
    
    NSURL * urlBase = [self baseURLStringForPath:path];
    NSURL * fullURL = urlBase;
    if (lastUpdate != nil) {
        NSString * dateString = [self.dateFormatter stringFromDate:lastUpdate];
        if (dateString != nil) {
            NSString * dateParam = [NSString stringWithFormat:@"?date=%@", [dateString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            fullURL = [NSURL URLWithString:[fullURL.absoluteString stringByAppendingString:dateParam]];
        }
    }
    
    [self getJSONFromURL:fullURL completion:completion];
}

+ (void) postPath:(NSString *)path parameters:(NSDictionary * _Nullable)params completion:(SSUCommunicatorCompletion _Nullable)completion {
    NSURL * url = [self baseURLStringForPath:path];
    [self postURL:url parameters:params completion:completion];
}

+ (void) postJSONPath:(NSString *)path parameters:(NSDictionary * _Nullable)params completion:(SSUCommunicatorJSONCompletion _Nullable)completion {
    NSURL * url = [self baseURLStringForPath:path];
    [self postJSONURL:url parameters:params completion:completion];
}

+ (NSURL * _Nullable)urlForPath:(NSString *)path {
    return [self baseURLStringForPath:path];
}

@end
