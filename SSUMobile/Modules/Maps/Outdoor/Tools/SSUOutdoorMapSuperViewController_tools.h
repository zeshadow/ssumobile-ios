//
//  SSUOutdoorMapSuperViewController_tools.h
//  SSUMobile
//
//  Created by Andrew Huss on 3/1/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUOutdoorMapSuperViewController.h"

#import "BuildingPerimeter+properties.h"

// Note: this file makes many of the private methods of SSUOutdoorMapViewController
//       available to the SSUOutdoorMapViewController+Tools category

@interface SSUOutdoorMapSuperViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) SSUDirectoryObject* selectedObject;
@property (weak, nonatomic) SSUMapBuildingPerimeter* loadedObject;
@property (strong, nonatomic) SSUMapBuildingPerimeter *navigationDestination;
@property (nonatomic) CLLocationCoordinate2D navigationStart;
@property (nonatomic) BOOL showDrivingDirections;

@property (strong, nonatomic) NSArray *mapPoints;

- (MKCoordinateRegion) campusRegion;
- (void) makeBuildingPerimeter:(SSUMapBuildingPerimeter*)buildingPerimeter visibleAnimated:(BOOL)animated;
- (void) setBuildingPerimeter:(SSUMapBuildingPerimeter*)buildingPerimeter highlighted:(BOOL)highlighted;
- (void) shortestPathFromStart:(CLLocationCoordinate2D)start toBuilding:(SSUMapBuildingPerimeter*)buildingPerimeter completionHandler:(void(^)(MKPolyline* line, NSError *error))completionBlock;

- (void)stopNavigating;
- (void)startNavigatingToCampusWithCompletion:(void (^)(BOOL successful))completion;
- (void)startNavigatingTo:(SSUMapBuildingPerimeter *)navigationDestination completionHandler:(void(^)(BOOL successful))completionBlock;
- (void)startNavigatingTo:(SSUMapBuildingPerimeter *)navigationDestination from:(CLLocationCoordinate2D)start completionHandler:(void (^)(BOOL))completionBlock;

@end