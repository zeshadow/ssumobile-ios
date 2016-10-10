//
//  SSUConnectionsBuilder.m
//  SSUMobile
//
//  Created by Andrew Huss on 4/14/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUConnectionsBuilder.h"
#import "SSULogging.h"

NSString * const SSUConnectionPointAKey = @"point_a";
NSString * const SSUConnectionPointBKey = @"point_b";

@implementation SSUConnectionsBuilder

- (void) build:(NSArray*)connections {
    SSULogDebug(@"Building Connections: %lu", (unsigned long)connections.count);
    if (connections.count > 0) {
        NSArray * mapPoints = [SSUMapBuilder allObjectsWithEntityName:SSUOutdoorMapEntityMapPoint
                                                              context:self.context];
        for (SSUMapPoint * point in mapPoints) {
            [point removeConnections:point.connections];
        }
        for (NSDictionary* connectionData in connections) {
            SSUMapPoint * a = [SSUConnectionsBuilder mapPointWithID:connectionData[SSUConnectionPointAKey] inContext:self.context];
            SSUMapPoint * b = [SSUConnectionsBuilder mapPointWithID:connectionData[SSUConnectionPointBKey] inContext:self.context];
            
            [a addConnectionsObject:b];
            [b addConnectionsObject:a];
        }
        [self saveContext];
    }
    
}

@end
