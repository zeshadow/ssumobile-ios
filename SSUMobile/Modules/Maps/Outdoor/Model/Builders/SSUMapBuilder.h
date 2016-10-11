//
//  SSUMapBuilder.h
//  SSUMobile
//
//  Created by Eric Amorde on 7/6/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUMoonlightBuilder.h"
#import "SSUOutdoorMapConstants.h"
#import "SSUMapModels.h"
#import "SSUDirectoryModels.h"

@interface SSUMapBuilder : SSUMoonlightBuilder

- (SSUMapPoint *) mapPointWithID:(NSString *)pointID;
+ (SSUMapPoint *) mapPointWithID:(NSString *)pointID
                       inContext:(NSManagedObjectContext *)context;

- (SSUMapBuildingPerimeter *) perimeterForBuilding:(SSUBuilding *)building;
+ (SSUMapBuildingPerimeter *) perimeterForBuilding:(SSUBuilding *)building
                                         inContext:(NSManagedObjectContext *)context;

- (SSUMapBuildingPerimeter *) perimeterForBuildingID:(NSString *)buildingId;
+ (SSUMapBuildingPerimeter *) perimeterForBuildingID:(NSString *)buildingId
                                           inContext:(NSManagedObjectContext *)context;

- (BOOL) perimeterExistsForBuilding:(SSUBuilding *)building;
+ (BOOL) perimeterExistsForBuilding:(SSUBuilding *)building
                          inContext:(NSManagedObjectContext *)context;

@end
