//
//  SSUOutdoorMapViewController.h
//  SSUMobile
//
//  Created by Andrew Huss on 2/17/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

@import UIKit;
@import MapKit;
#import "SSUMapBuilder.h"
#import "SSUDirectoryBuilder.h"

@interface SSUOutdoorMapSuperViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, getter=isShowingDirections) BOOL showingDirections;

/// This returns any map point (path, building perimeter, or building entrance)
- (SSUMapPoint*) closestMapPointToCoordinate:(CLLocationCoordinate2D)coordinate;
- (void) loadObject:(NSManagedObject*)object inContext:(NSManagedObjectContext*)context;

- (void) selectBuildingId:(NSInteger)buildingId;

- (BOOL) locationIsOnCampus:(CLLocationCoordinate2D)location;

+ (BOOL) canDisplayBuilding:(SSUBuilding *)building;

@end
