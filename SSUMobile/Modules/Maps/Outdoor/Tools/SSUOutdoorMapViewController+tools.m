//
//  SSUOutdoorMapViewController+tools.m
//  SSUMobile
//
//  Created by Andrew Huss on 3/2/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUOutdoorMapViewController+tools.h"
#import "SSULogging.h"
#import "SSUMapBuilder.h"
#import "SSUMapModule.h"
#import "SSUMoonlightCommunicator.h"
#import "SSUDebugCredentials.h"

const CGFloat accuracy = 0.000000001;

@implementation SSUOutdoorMapSuperViewController (tools)

- (CLLocationCoordinate2D*) coordsFromAnnotations:(NSArray*)annotations {
    CLLocationCoordinate2D* coords = malloc(sizeof(CLLocationCoordinate2D) * annotations.count);
    for (int i = 0; i < annotations.count; i++) {
        coords[i] = [(id<MKAnnotation>)annotations[i] coordinate];
    }
    return coords;
}

- (MKPointAnnotation*) createPointAtLocation:(CLLocation*)location withTitle:(NSString*)string {
    MKPointAnnotation* annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = location.coordinate;
    annotation.title = string;
    return annotation;
}

- (void) loadPathPoints {
    [self.mapView addAnnotations:self.mapPoints];
}

- (void) connectMapPoints {
    NSMutableSet* connections = [NSMutableSet set];
    NSArray* mapPoints = self.mapPoints;
    CLLocationCoordinate2D* coords = malloc(sizeof(CLLocationCoordinate2D) * 2);
    CLLocationCoordinate2D empty = CLLocationCoordinate2DMake(0, 0);
    for (SSUMapPoint* point in mapPoints) {
        for (SSUMapPoint* neighbor in point.connections) {
            coords[0] = point.coordinate;
            coords[1] = neighbor.coordinate;
            MKPolyline* line = [MKPolyline polylineWithCoordinates:coords count:2];
            coords[0] = empty;
            coords[1] = empty;
            
            BOOL found = NO;
            for (MKPolyline* connection in connections) {
                if ([self comparePolyline:connection toPolyline:line]) {
                    found = YES;
                    break;
                }
            }
            if (!found) {
                [connections addObject:line];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.mapView addOverlay:line];
                });
            }
        }
    }
    free(coords);
}

- (BOOL) comparePolyline:(MKPolyline*)a toPolyline:(MKPolyline*)b {
    CLLocationCoordinate2D aa = MKCoordinateForMapPoint(a.points[0]);
    CLLocationCoordinate2D ab = MKCoordinateForMapPoint(a.points[1]);
    CLLocationCoordinate2D ba = MKCoordinateForMapPoint(b.points[0]);
    CLLocationCoordinate2D bb = MKCoordinateForMapPoint(b.points[1]);
    
    if ([self compareCoordinate:aa toCoordinate:ba accuracy:accuracy] && [self compareCoordinate:ab toCoordinate:bb accuracy:accuracy]) {
        return YES;
    }
    else if ([self compareCoordinate:aa toCoordinate:bb accuracy:accuracy] && [self compareCoordinate:ab toCoordinate:ba accuracy:accuracy]) {
        return YES;
    }
    return NO;
}

- (BOOL) polyline:(MKPolyline*)line containsCoordinate:(CLLocationCoordinate2D)coordinate {
    for (int i = 0; i < line.pointCount; i++) {
        if ([self compareCoordinate:MKCoordinateForMapPoint(line.points[i]) toCoordinate:coordinate accuracy:accuracy]) {
            return YES;
        }
    }
    return NO;
}

- (CLLocationDistance) distanceBetweenMapPoint:(SSUMapPoint*)a andMapPoint:(SSUMapPoint*)b {
    return [a.location distanceFromLocation:b.location];
}

- (MKPolyline*) polylineByReplacingCoordinate:(CLLocationCoordinate2D)source withCoordinate:(CLLocationCoordinate2D)destination inPolyline:(MKPolyline*)line {
    CLLocationCoordinate2D a = MKCoordinateForMapPoint(line.points[0]);
    CLLocationCoordinate2D b = MKCoordinateForMapPoint(line.points[1]);
    CLLocationCoordinate2D* coords = nil;
    if ([self compareCoordinate:source toCoordinate:a accuracy:accuracy]) {
        coords = malloc(sizeof(CLLocationCoordinate2D) * 2);
        coords[0] = destination;
        coords[1] = b;
    }
    else if ([self compareCoordinate:source toCoordinate:b accuracy:accuracy]) {
        coords = malloc(sizeof(CLLocationCoordinate2D) * 2);
        coords[0] = a;
        coords[1] = destination;
    }
    else {
        return line;
    }
    
    MKPolyline* polyline = [MKPolyline polylineWithCoordinates:coords count:2];
    free(coords);
    return polyline;
}

- (BOOL) compareCoordinate:(CLLocationCoordinate2D)a toCoordinate:(CLLocationCoordinate2D)b accuracy:(CGFloat)accuracy {
    long double lat = fabs(a.latitude - b.latitude);
    long double lon = fabs(a.longitude - b.longitude);
    if (lat <= accuracy && lon <= accuracy) {
        return YES;
    }
    return NO;
}

- (MKPolyline*) polylineWithMapPoints:(NSArray*)mapPoints {
    MKPolyline* polyline = nil;
    CLLocationCoordinate2D* coordinates = malloc(sizeof(CLLocationCoordinate2D) * mapPoints.count);
    NSInteger index = 0;
    for (SSUMapPoint* mapPoint in mapPoints) {
        coordinates[index++] = mapPoint.coordinate;
    }
    polyline = [MKPolyline polylineWithCoordinates:coordinates count:index];
    free(coordinates);
    return polyline;
}

- (NSArray*) fetchAllMapPoints {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:SSUOutdoorMapEntityMapPoint inManagedObjectContext:[SSUMapModule sharedInstance].context];
    request.relationshipKeyPathsForPrefetching = @[@"connections"];
    
    NSError* error = nil;
    NSArray* mapPoints = [[SSUMapModule sharedInstance].context executeFetchRequest:[[NSFetchRequest alloc] initWithEntityName:SSUOutdoorMapEntityMapPoint] error:&error];
    if (!mapPoints) {
        SSULogDebug(@"Error: %@", error.debugDescription);
    }
    return mapPoints;
}

#pragma mark - Save

- (BOOL) mapPointExistsWithID:(NSString*)pointID {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:SSUOutdoorMapEntityMapPoint inManagedObjectContext:[SSUMapModule sharedInstance].context];
    request.predicate = [NSPredicate predicateWithFormat:@"%K = %@", SSUMoonlightManagerKeyID, pointID];

    NSError* error = nil;
    NSInteger count = [[SSUMapModule sharedInstance].context countForFetchRequest:request error:&error];
    if (count == NSNotFound) {
        SSULogDebug(@"Error: %@", error.debugDescription);
        return NO;
    }
    return count;
}

- (NSString *) stringFromCoordinateDegrees:(CLLocationDegrees)degrees {
    static NSNumberFormatter * formatter = nil;
    if (formatter == nil) {
        formatter = [NSNumberFormatter new];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        formatter.maximumFractionDigits = 13;
    }
    
    return [formatter stringFromNumber:@(degrees)];
}

- (void) createPointFromCoordinate:(CLLocationCoordinate2D)coordinate completionHandler:(void (^)(SSUMapPoint * point, NSError * error))completionBlock {
    SSULogDebug(@"Will Create Point");
    NSURL* url = [SSUMoonlightCommunicator urlForPath:@"ssumobile/map/point/"];
    NSDictionary * params = @{
                              @"latitude" : [self stringFromCoordinateDegrees:coordinate.latitude],
                              @"longitude" : [self stringFromCoordinateDegrees:coordinate.longitude],
                              };
    NSURLRequest * request = [SSUMoonlightCommunicator postRequestWithURL:url parameters:params];
    request = [SSUDebugCredentials authenticatedRequestFromRequest:request];
    [SSUMoonlightCommunicator performJSONRequest:request completion:^(NSURLResponse *response, id json, NSError *error) {
        if (error) {
            completionBlock(nil, error);
        }
        else if (json != nil){
            [[SSUMapModule sharedInstance].context performBlock:^{
                SSUMapPoint* point = [SSUMapBuilder mapPointWithID:[json[SSUMoonlightManagerKeyID] stringValue] inContext:[SSUMapModule sharedInstance].context];
                point.latitude = @(coordinate.latitude).stringValue;
                point.longitude = @(coordinate.longitude).stringValue;
                SSULogDebug(@"Successfully created point: %@", point);
                completionBlock(point, nil);
            }];
        }
        else {
            SSULogError(@"Big issue here, no error but did not get a response either.");
            completionBlock(nil, nil);
        }
    }];
}

- (void) createPointFromCoordinate:(CLLocationCoordinate2D)coordinate buildingID:(NSString*)buildingID index:(NSString*)index completionHandler:(void (^)(SSUMapPoint * point, SSUMapBuildingPerimeter * perimeter, NSError * error))completionBlock {
    
    [self createPointFromCoordinate:coordinate completionHandler:^(SSUMapPoint *point, NSError *error) {
        if (error) {
            completionBlock(nil, nil, error);
        }
        else {
            [self createPerimeterForPoint:point buildingID:buildingID index:index completionHandler:^(SSUMapBuildingPerimeter *perimeter, NSError *error) {
                if (error) {
                    completionBlock(point, nil, error);
                }
                else {
                    completionBlock(point, perimeter, nil);
                }
            }];
        }
    }];
}

- (void) createPerimeterForPoint:(SSUMapPoint *)point buildingID:(NSString *)buildingID index:(NSString *)index completionHandler:(void(^)(SSUMapBuildingPerimeter * perimeter, NSError * error))completionBlock {
    NSURL * url = [SSUMoonlightCommunicator urlForPath:@"ssumobile/map/perimeter/"];
    NSDictionary * params = @{
                              @"building": @(buildingID.integerValue),
                              @"index": @(index.integerValue),
                              @"point": @(point.id.integerValue)
                              };
    NSURLRequest * baseRequest = [SSUMoonlightCommunicator postRequestWithURL:url parameters:params];
    NSURLRequest * request = [SSUDebugCredentials authenticatedRequestFromRequest:baseRequest];
    [SSUMoonlightCommunicator performJSONRequest:request completion:^(NSURLResponse *response, NSDictionary * json, NSError *error) {
        if (error) {
            SSULogDebug(@"Error while creating perimeter: %@",error);
            completionBlock(nil, error);
        }
        else if (json != nil) {
            SSULogDebug(@"Successfully added point to perimeter");
            NSManagedObjectContext * context = [[SSUMapModule sharedInstance] context];
            [context performBlock:^{
                SSUMapBuildingPerimeter * perimeter = [SSUMapBuilder perimeterForBuildingID:buildingID inContext:context];
                [perimeter addLocationsObject:point];
                [context save:nil];
                completionBlock(perimeter, nil);
            }];
        }
        else {
            SSULogDebug(@"Did not receive response from perimeter creation");
            completionBlock(nil, nil);
        }
    }];
}

- (void) modifyPoint:(SSUMapPoint*)point {
    SSULogDebug(@"Will Modify Point");
    NSString * path = [NSString stringWithFormat:@"ssumobile/map/point/%@/", point.id];
    NSURL * url = [SSUMoonlightCommunicator urlForPath:path];
    
    CLLocationCoordinate2D coord = point.coordinate;
    NSDictionary * params = @{
                              @"latitude" : [self stringFromCoordinateDegrees:coord.latitude],
                              @"longitude" : [self stringFromCoordinateDegrees:coord.longitude]
                              };
    
    NSURLRequest * baseRequest = [SSUMoonlightCommunicator updateRequestWithURL:url parameters:params];
    NSURLRequest * request = [SSUDebugCredentials authenticatedRequestFromRequest:baseRequest];
    [SSUMoonlightCommunicator performRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            SSULogDebug(@"Modify Point Error: %@", error.debugDescription);
        }
        else {
            SSULogDebug(@"Modify point success");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mapView removeAnnotation:point];
                [self.mapView addAnnotation:point];
            });
            [[SSUMapModule sharedInstance].context performBlock:^{
                [[SSUMapModule sharedInstance].context save:nil];
            }];
        }
    }];
}

- (void) deleteConnectionsFromPoint:(SSUMapPoint*)point {
    for (SSUMapPoint* connection in point.connections) {
        [self deleteConnectionFromA:point toB:connection];
    }
}

- (void) createConnectionsFromPoint:(SSUMapPoint*)point {
    for (SSUMapPoint* connection in point.connections) {
        [self createConnectionFromA:point toB:connection];
    }
}

- (void) deletePoint:(SSUMapPoint*)point {
    SSULogDebug(@"Will Delete Point");
    NSString * path = [NSString stringWithFormat:@"ssumobile/map/point/%@/", point.id];
    NSURL * url = [SSUMoonlightCommunicator urlForPath:path];
    
    NSURLRequest * baseRequest = [SSUMoonlightCommunicator deleteRequestWithURL:url parameters:nil];
    NSURLRequest * request = [SSUDebugCredentials authenticatedRequestFromRequest:baseRequest];
    [SSUMoonlightCommunicator performRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            SSULogDebug(@"Delete Point Error: %@", error.debugDescription);
        }
        else {
            [self.mapView removeAnnotation:point];
            [[SSUMapModule sharedInstance].context performBlock:^{
                [[SSUMapModule sharedInstance].context deleteObject:point];
                SSULogDebug(@"Did Delete Point");
            }];
        }
    }];
}

- (void) createConnectionFromA:(SSUMapPoint*)pointA toB:(SSUMapPoint*)pointB {
    SSULogDebug(@"Will Create Connection");
    NSURL * urlBase = [SSUMoonlightCommunicator urlForPath:@"ssumobile/map/point_connection/"];
    NSDictionary * params = @{
                              @"point_a" : pointA.id,
                              @"point_b" : pointB.id,
                              @"distance" : @([self distanceBetweenMapPoint:pointA andMapPoint:pointB]),
                              };
    
    NSURLRequest * baseRequest = [SSUMoonlightCommunicator postRequestWithURL:urlBase parameters:params];
    NSURLRequest * request = [SSUDebugCredentials authenticatedRequestFromRequest:baseRequest];
    
    [SSUMoonlightCommunicator performJSONRequest:request completion:^(NSURLResponse *response, id json, NSError *error) {
        if (error) {
            SSULogDebug(@"Create Connection Error: %@", error.debugDescription);
        }
        else if (json != nil) {
            [[SSUMapModule sharedInstance].context performBlock:^{
                [pointA addConnectionsObject:pointB];
                [pointB addConnectionsObject:pointA];
                [[SSUMapModule sharedInstance].context save:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSArray * selected = self.mapView.selectedAnnotations;
                    if ([self.mapView.annotations containsObject:pointA]) {
                        [self.mapView removeAnnotation:pointA];
                        [self.mapView addAnnotation:pointA];
                        for (id<MKAnnotation> a in selected) {
                            [self.mapView selectAnnotation:a animated:NO];
                        }
                    }
                    if ([self.mapView.annotations containsObject:pointB]) {
                        [self.mapView removeAnnotation:pointB];
                        [self.mapView addAnnotation:pointB];
                        for (id<MKAnnotation> a in selected) {
                            [self.mapView selectAnnotation:a animated:NO];
                        }
                    }
                });
            }];
            SSULogDebug(@"Did Create Connection");
        }
        else {
            SSULogDebug(@"Did not receive response");
        }
    }];
}

- (void) deleteConnectionFromA:(SSUMapPoint*)pointA toB:(SSUMapPoint*)pointB {
    SSULogDebug(@"Will Delete Connection");
    NSURL * url = [SSUMoonlightCommunicator urlForPath:@"ssumobile/map/point_connection/remove/"];
    NSDictionary * params = @{
                              @"point_a" : pointA.id,
                              @"point_b" : pointB.id,
                              };
    NSURLRequest * baseRequest = [SSUMoonlightCommunicator postRequestWithURL:url parameters:params];
    NSURLRequest * request = [SSUDebugCredentials authenticatedRequestFromRequest:baseRequest];
    
    [SSUMoonlightCommunicator performRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            SSULogDebug(@"Delete Connection Error: %@", error.debugDescription);
        }
        else {
            if (data != nil) {
                NSString * responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                SSULogDebug(@"Response: %@", responseString);
            }
            [[SSUMapModule sharedInstance].context performBlock:^{
                [pointA removeConnectionsObject:pointB];
                [pointB removeConnectionsObject:pointA];
                [[SSUMapModule sharedInstance].context save:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSArray * selected = self.mapView.selectedAnnotations;
                    if ([self.mapView.annotations containsObject:pointA]) {
                        SSULogDebug(@"Refreshing annotation");
                        [self.mapView removeAnnotation:pointA];
                        [self.mapView addAnnotation:pointA];
                        for (id<MKAnnotation> a in selected) {
                            [self.mapView selectAnnotation:a animated:NO];
                        }
                    }
                    if ([self.mapView.annotations containsObject:pointB]) {
                        SSULogDebug(@"Refreshing annotation");
                        [self.mapView removeAnnotation:pointB];
                        [self.mapView addAnnotation:pointB];
                        for (id<MKAnnotation> a in selected) {
                            [self.mapView selectAnnotation:a animated:NO];
                        }
                    }
                });
            }];
            SSULogDebug(@"Did Delete Connection");
        }
    }];
}

@end
