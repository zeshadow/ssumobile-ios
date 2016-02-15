//
//  SSUMapBuilder.m
//  SSUMobile
//
//  Created by Eric Amorde on 7/6/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUMapBuilder.h"
#import "SSULogging.h"

@implementation SSUMapBuilder

- (SSUMapPoint *) mapPointWithID:(NSString *)pointID {
    return [[self class] mapPointWithID:pointID inContext:self.context];
}

+ (SSUMapPoint*) mapPointWithID:(NSString*)pointID inContext:(NSManagedObjectContext*)context {
    if ([self mapPointExistsWithID:pointID inContext:context]) {
        NSFetchRequest* request = [[NSFetchRequest alloc] init];
        request.includesPendingChanges = YES;
        request.entity = [NSEntityDescription entityForName:SSUOutdoorMapEntityMapPoint inManagedObjectContext:context];
        request.predicate = [NSPredicate predicateWithFormat:@"%K = %@", SSUMoonlightManagerKeyID, pointID];
        
        NSError* error = nil;
        NSArray* results = [context executeFetchRequest:request error:&error];
        
        if (!results) {
            SSULogError(@"Error: %@", error.debugDescription);
        }
        else if (results.count == 0) {
            SSULogError(@"Error: No map point found");
        }
        else if (results.count > 1) {
            SSULogError(@"Error: Multiple map points found");
            for (SSUMapPoint* point in results) {
                SSULogDebug(@"Point: %@", point);
            }
        }
        else {
            return results.lastObject;
        }
    }
    else {
        SSUMapPoint* point = [NSEntityDescription insertNewObjectForEntityForName:SSUOutdoorMapEntityMapPoint inManagedObjectContext:context];
        point.id = pointID;
        point.latitude = @"0";
        point.longitude = @"0";
        return point;
    }
    return nil;
}

+ (BOOL) mapPointExistsWithID:(NSString*)pointID inContext:(NSManagedObjectContext*)context {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    request.includesPendingChanges = YES;
    request.entity = [NSEntityDescription entityForName:SSUOutdoorMapEntityMapPoint inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"%K = %@", SSUMoonlightManagerKeyID, pointID];
    
    NSError* error = nil;
    NSInteger count = [context countForFetchRequest:request error:&error];
    return count != NSNotFound && count > 0;
}


- (SSUMapBuildingPerimeter *) perimeterForBuilding:(SSUBuilding *)building {
    return [[self class] perimeterForBuilding:building inContext:self.context];
}

+ (SSUMapBuildingPerimeter *) perimeterForBuilding:(SSUBuilding *)building
                                        inContext:(NSManagedObjectContext *)context {
    SSUMapBuildingPerimeter* perimeter = nil;
    if ([self perimeterExistsForBuilding:building inContext:context]) {
        NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:SSUOutdoorMapEntityBuildingPerimeter];
        request.includesPendingChanges = YES;
        request.predicate = [NSPredicate predicateWithFormat:@"buildingID = %@", building.id];
        
        NSError* error = nil;
        NSArray* results = [context executeFetchRequest:request error:&error];
        
        if (!results) {
            SSULogError(@"Error: %@", error.debugDescription);
        }
        else if (!results.count) {
            SSULogError(@"Error: No map point found");
        }
        else if (results.count > 1) {
            SSULogError(@"Error: Multiple map points found");
        }
        else {
            perimeter = results.lastObject;
        }
    }
    else {
        perimeter = [NSEntityDescription insertNewObjectForEntityForName:SSUOutdoorMapEntityBuildingPerimeter inManagedObjectContext:context];
        perimeter.buildingID = building.id;
    }
    perimeter.buildingName = building.name;
    return perimeter;
}

- (BOOL) perimeterExistsForBuilding:(SSUBuilding *)building {
    return [[self class] perimeterForBuilding:building inContext:self.context];
}

+ (BOOL) perimeterExistsForBuilding:(SSUBuilding*)building inContext:(NSManagedObjectContext*)context {
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:SSUOutdoorMapEntityBuildingPerimeter];
    request.includesPendingChanges = YES;
    request.predicate = [NSPredicate predicateWithFormat:@"buildingID = %@", building.id];
    
    NSError* error = nil;
    NSInteger count = [context countForFetchRequest:request error:&error];
    return count != NSNotFound && count > 0;
}


@end
