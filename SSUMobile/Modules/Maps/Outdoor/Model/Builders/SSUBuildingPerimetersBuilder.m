//
//  SSUBuildingPerimetersBuilder.m
//  SSUMobile
//
//  Created by Andrew Huss on 4/14/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUBuildingPerimetersBuilder.h"
#import "SSUDirectoryBuilder.h"
#import "SSUDirectoryModule.h"
#import "SSULogging.h"

@implementation SSUBuildingPerimetersBuilder

- (void) build:(NSDictionary*)perimeters {
    SSULogDebug(@"Building Perimeters: %lu", (unsigned long)perimeters.count);
    NSManagedObjectContext* directoryContext = [[SSUDirectoryModule sharedInstance] backgroundContext];
    for (NSString* buildingID in perimeters) {
        [directoryContext performBlockAndWait:^{
            SSUBuilding* building = [SSUDirectoryBuilder buildingWithID:buildingID inContext:directoryContext];
            SSUMapBuildingPerimeter* perimeter = [SSUMapBuilder perimeterForBuilding:building inContext:self.context];
            while (perimeter.locations.count) {
                [perimeter removeLocationsObject:[perimeter.locations objectAtIndex:0]];
            }
            for (NSDictionary* pointData in perimeters[buildingID]) {
                NSNumber* pID = pointData[@"pID"];
                SSUMapPoint* point = [SSUBuildingPerimetersBuilder mapPointWithID:pID.stringValue inContext:self.context];
                [perimeter addLocationsObject:point];
            }
        }];
    }
    SSULogDebug(@"Finished building perimeters");
    [self saveContext];
}

@end
