//
//  SSUBuildingPerimetersBuilder.m
//  SSUMobile
//
//  Created by Andrew Huss on 4/14/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUBuildingPerimetersBuilder.h"
#import "SSUDirectoryBuilder.h"
#import "SSULogging.h"
#import "SSUMobile-Swift.h"


NSString * const SSUPerimeterPointIdKey = @"point";
NSString * const SSUPerimeterBuildingIdKey = @"building";
NSString * const SSUPerimeterIndexKey = @"index";

@implementation SSUBuildingPerimetersBuilder

- (void) build:(NSArray *)perimeters {
    SSULogDebug(@"Building Perimeters: %lu", (unsigned long)perimeters.count);
    if (perimeters.count == 0) {
        SSULogDebug(@"Finished building perimeters");
        return;
    }
    NSManagedObjectContext* directoryContext = [[SSUDirectoryModule sharedInstance] backgroundContext];
    
    NSMutableDictionary <NSString *, NSMutableArray *> * perimetersByBuilding = [NSMutableDictionary new];
    
    for (NSDictionary * perimeterData in perimeters) {
        NSString * buildingId = SSUMoonlightBuilderStringify(perimeterData[SSUPerimeterBuildingIdKey]);
        if (perimetersByBuilding[buildingId] == nil) {
            perimetersByBuilding[buildingId] = [NSMutableArray new];
        }
        [perimetersByBuilding[buildingId] addObject:perimeterData];
    }
    // Now sort the perimeters by their respective indices
    for (NSString* buildingID in [perimetersByBuilding allKeys]) {
        NSArray * perimeters = perimetersByBuilding[buildingID];
        perimeters = [perimeters sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1[SSUPerimeterIndexKey] compare:obj2[SSUPerimeterIndexKey]];
        }];
        perimetersByBuilding[buildingID] = [perimeters mutableCopy];
    }
    
    for (NSString* buildingID in perimetersByBuilding) {
        [directoryContext performBlockAndWait:^{
            SSUBuilding* building = [SSUDirectoryBuilder buildingWithID:buildingID inContext:directoryContext];
            NSString * buildingName = building.displayName;
            [self.context performBlockAndWait:^{
                SSUMapBuildingPerimeter* perimeter = [self perimeterForBuilding:building];
                [perimeter removeLocations:perimeter.locations];
                NSMutableOrderedSet * locations = [NSMutableOrderedSet new];
                for (NSDictionary* pointData in perimetersByBuilding[buildingID]) {
                    NSNumber* pID = pointData[SSUPerimeterPointIdKey];
                    SSUMapPoint* point = [SSUBuildingPerimetersBuilder mapPointWithID:pID.stringValue inContext:self.context];
                    [locations addObject:point];
                }
                [perimeter setLocations:locations];
                perimeter.buildingName = buildingName;
            }];
        }];
    }
    
    // If a building has been deleted, we need to delete the perimeters for it
    NSPredicate * deletePredicate = [NSPredicate predicateWithFormat:@"NOT (buildingID IN %@)", perimetersByBuilding.allKeys];
    [SSUMoonlightBuilder deleteObjectsWithEntityName:SSUOutdoorMapEntityBuildingPerimeter matchingPredicate:deletePredicate context:self.context];
    SSULogDebug(@"Finished building perimeters");
    [self saveContext];
}

@end
