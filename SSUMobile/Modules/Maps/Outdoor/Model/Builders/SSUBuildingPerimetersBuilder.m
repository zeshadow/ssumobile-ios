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

NSString * const SSUPerimeterPointIdKey = @"point";
NSString * const SSUPerimeterBuildingIdKey = @"building";

@implementation SSUBuildingPerimetersBuilder

- (void) build:(NSArray *)perimeters {
    SSULogDebug(@"Building Perimeters: %lu", (unsigned long)perimeters.count);
    NSManagedObjectContext* directoryContext = [[SSUDirectoryModule sharedInstance] backgroundContext];
    
    NSMutableDictionary <NSString *, NSMutableArray *> * perimetersByBuilding = [NSMutableDictionary new];
    
    NSMutableArray * ids = [NSMutableArray new];
    for (NSDictionary * perimeterData in perimeters) {
        [ids addObject:perimeterData[SSUMoonlightManagerKeyID]];
        NSString * buildingId = SSUMoonlightBuilderStringify(perimeterData[SSUMoonlightManagerKeyID]);
        if (perimetersByBuilding[buildingId] == nil) {
            perimetersByBuilding[buildingId] = [NSMutableArray new];
        }
        [perimetersByBuilding[buildingId] addObject:perimeterData];
    }
    
    for (NSString* buildingID in perimetersByBuilding) {
        [directoryContext performBlock:^{
            SSUBuilding* building = [SSUDirectoryBuilder buildingWithID:buildingID inContext:directoryContext];
            NSString * buildingName = building.displayName;
            [self.context performBlockAndWait:^{
                SSUMapBuildingPerimeter* perimeter = [self perimeterForBuilding:building];
                [perimeter removeLocations:perimeter.locations];
                for (NSDictionary* pointData in perimetersByBuilding[buildingID]) {
                    NSNumber* pID = pointData[SSUPerimeterPointIdKey];
                    SSUMapPoint* point = [SSUBuildingPerimetersBuilder mapPointWithID:pID.stringValue inContext:self.context];
                    [perimeter addLocationsObject:point];
                }
                perimeter.buildingName = buildingName;
            }];
        }];
    }
    NSPredicate * deletePredicate = [NSPredicate predicateWithFormat:@"NOT (id  IN %@)", ids];
    [SSUMoonlightBuilder deleteObjectsWithEntityName:SSUOutdoorMapEntityBuildingPerimeter matchingPredicate:deletePredicate context:self.context];
    SSULogDebug(@"Finished building perimeters");
    [self saveContext];
}

@end
