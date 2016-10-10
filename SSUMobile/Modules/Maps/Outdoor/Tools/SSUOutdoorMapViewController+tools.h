//
//  SSUOutdoorMapViewController+tools.h
//  SSUMobile
//
//  Created by Andrew Huss on 3/2/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUOutdoorMapSuperViewController_tools.h"

@interface SSUOutdoorMapSuperViewController (tools) <MKMapViewDelegate>

- (void) connectMapPoints;

- (CLLocationCoordinate2D*) coordsFromAnnotations:(NSArray*)annotations;

- (MKPointAnnotation*) createPointAtLocation:(CLLocation*)location withTitle:(NSString*)string;

- (BOOL) comparePolyline:(MKPolyline*)a toPolyline:(MKPolyline*)b;

- (BOOL) polyline:(MKPolyline*)line containsCoordinate:(CLLocationCoordinate2D)coordinate;
- (MKPolyline*) polylineByReplacingCoordinate:(CLLocationCoordinate2D)source withCoordinate:(CLLocationCoordinate2D)destination inPolyline:(MKPolyline*)line;

- (BOOL) compareCoordinate:(CLLocationCoordinate2D)a toCoordinate:(CLLocationCoordinate2D)b accuracy:(CGFloat)accuracy;

- (void) createPointFromCoordinate:(CLLocationCoordinate2D)coordinate completionHandler:(void (^)(SSUMapPoint * point, NSError * error))completionBlock;
- (void) createPointFromCoordinate:(CLLocationCoordinate2D)coordinate buildingID:(NSString*)buildingID index:(NSString*)index completionHandler:(void(^)(SSUMapPoint * point, SSUMapBuildingPerimeter * perimeter, NSError* error))completionBlock;
- (void) modifyPoint:(SSUMapPoint *)point;
- (void) deletePoint:(SSUMapPoint *)point;

- (void) createConnectionFromA:(SSUMapPoint *)pointA toB:(SSUMapPoint *)pointB;
- (void) deleteConnectionFromA:(SSUMapPoint *)pointA toB:(SSUMapPoint *)pointB;

@end
