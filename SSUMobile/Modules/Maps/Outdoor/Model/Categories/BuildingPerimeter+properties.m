//
//  BuildingPerimeter+properties.m
//  SSUMobile
//
//  Created by Andrew Huss on 3/5/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "BuildingPerimeter+properties.h"
#import "SSUDirectoryBuilder.h"
#import "SSUMobile-Swift.h"

@implementation SSUMapBuildingPerimeter (properties)

- (CLLocationCoordinate2D) coordinate {
    return MKCoordinateRegionForMapRect(self.boundingMapRect).center;
}

- (NSString*) title {
    NSManagedObjectContext * context = [[SSUDirectoryModule sharedInstance] context];
    SSUBuilding* building = [SSUDirectoryBuilder buildingWithID:self.buildingID inContext:context];
    return building.name;
}

- (MKMapRect) boundingMapRect {
    return self.polygon.boundingMapRect;
}

@end
