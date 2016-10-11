//
//  SSUPointsBuilder.m
//  SSUMobile
//
//  Created by Andrew Huss on 4/14/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUPointsBuilder.h"
#import "SSULogging.h"

NSString * const SSUPointKeyLatitude = @"latitude";
NSString * const SSUPointKeyLongitude = @"longitude";

@implementation SSUPointsBuilder

- (void) build:(NSArray*)points {
    SSULogDebug(@"Building Points: %lu", (unsigned long)points.count);
    for (NSDictionary* raw in points) {
        NSDictionary * pointData = [self cleanJSON:raw];
        SSUMoonlightDataMode mode = [self modeFromJSONData:pointData];
        NSString * pointID = SSUMoonlightBuilderStringify(pointData[SSUMoonlightManagerKeyID]);
        SSUMapPoint* point = [SSUPointsBuilder mapPointWithID:pointID inContext:self.context];
        if (mode == SSUMoonlightDataModeDeleted) {
            [self.context deleteObject:point];
            continue;
        }

        point.latitude = pointData[SSUPointKeyLatitude];
        point.longitude = pointData[SSUPointKeyLongitude];
    }
    [self saveContext];
}

@end
