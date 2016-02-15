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
- (SSUMapBuildingPerimeter *) perimeterForBuilding:(SSUBuilding *)building;
- (BOOL) perimeterExistsForBuilding:(SSUBuilding *)building;

+ (SSUMapPoint *) mapPointWithID:(NSString *)pointID
                       inContext:(NSManagedObjectContext *)context;
+ (SSUMapBuildingPerimeter *) perimeterForBuilding:(SSUBuilding *)building
                                         inContext:(NSManagedObjectContext *)context;
+ (BOOL) perimeterExistsForBuilding:(SSUBuilding *)building
                          inContext:(NSManagedObjectContext *)context;

@end
