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
    pointID = SSUMoonlightBuilderStringify(pointID);
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K = %@", SSUMoonlightManagerKeyID, pointID];
    
    
    BOOL created = NO;
    SSUMapPoint* point = (id)[self objectWithEntityName:SSUOutdoorMapEntityMapPoint predicate:predicate context:context entityWasCreated:&created];
    if (created) {
        point.id = pointID;
        point.latitude = @"0";
        point.longitude = @"0";
    }
    return point;
}

+ (BOOL) mapPointExistsWithID:(NSString*)pointID inContext:(NSManagedObjectContext*)context {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:SSUOutdoorMapEntityMapPoint];
    request.includesPendingChanges = YES;
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
    return [self perimeterForBuildingID:building.id inContext:context];
}

- (SSUMapBuildingPerimeter *) perimeterForBuildingID:(NSString *)buildingId {
    return [[self class] perimeterForBuildingID:buildingId inContext:self.context];
}

+ (SSUMapBuildingPerimeter *) perimeterForBuildingID:(NSString *)buildingId
                                           inContext:(NSManagedObjectContext *)context {
    BOOL created = NO;
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"buildingID = %@", buildingId];
    SSUMapBuildingPerimeter* perimeter = (id)[self objectWithEntityName:SSUOutdoorMapEntityBuildingPerimeter predicate:predicate context:context entityWasCreated:&created];
    
    if (created) {
        perimeter.buildingID = buildingId;
    }
    
    return perimeter;

}

- (BOOL) perimeterExistsForBuilding:(SSUBuilding *)building {
    return [[self class] perimeterForBuilding:building inContext:self.context];
}

+ (BOOL) perimeterExistsForBuilding:(SSUBuilding*)building inContext:(NSManagedObjectContext*)context {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:SSUOutdoorMapEntityBuildingPerimeter];
    request.includesPendingChanges = YES;
    request.predicate = [NSPredicate predicateWithFormat:@"buildingID = %@", building.id];
    
    NSError* error = nil;
    NSInteger count = [context countForFetchRequest:request error:&error];
    return count != NSNotFound && count > 0;
}


@end
