//
//  SSUOutdoorMapViewController+tools.m
//  SSUMobile
//
//  Created by Andrew Huss on 3/2/13.
//  Copyright (c) 2013 Computer Science. All rights reserved.
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
    [annotation setCoordinate:location.coordinate];
    [annotation setTitle:string];
    return annotation;
}

- (void) loadPathPoints {
    [self.mapView addAnnotations:self.mapPoints];
}

- (void) connectMapPoints {
    __block NSMutableSet* connections = [NSMutableSet set];
    __block NSArray* mapPoints = self.mapPoints;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        for (SSUMapPoint* point in mapPoints) {
            for (SSUMapPoint* neighbor in point.connections) {
                CLLocationCoordinate2D* coords = malloc(sizeof(CLLocationCoordinate2D) * 2);
                coords[0] = point.coordinate;
                coords[1] = neighbor.coordinate;
                MKPolyline* line = [MKPolyline polylineWithCoordinates:coords count:2];
                free(coords);
                
                BOOL found = NO;
                for (MKPolyline* connection in connections) {
                    if ([self comparePolyline:connection toPolyline:line]) {
                        found = YES;
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
    });
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

- (void) createPointFromCoordinate:(CLLocationCoordinate2D)coordinate buildingID:(NSString*)buildingID index:(NSString*)index completionHandler:(void(^)(SSUMapPoint* point, NSError* error))completionBlock {
    SSULogDebug(@"Will Create Point");
    NSString* urlBase = [SSUMoonlightBaseURL stringByAppendingPathComponent:@"createPoint"];
    NSURL* url = nil;
    NSMutableDictionary * params = [@{
                                     @"latitude" : @(coordinate.latitude),
                                     @"longitude" : @(coordinate.longitude),
                                     @"key" : [SSUDebugCredentials token]
                                     } mutableCopy];
    if (buildingID && index) {
        params[@"buildingID"] = buildingID;
        params[@"index"] = index;
    }
    url = [NSURL URLWithString:urlBase];
    [SSUMoonlightCommunicator postURL:url parameters:params completionHandler:^(NSData *data, NSError *error) {
        if (error) {
            completionBlock(nil, [NSError errorWithDomain:@"Create Point Connection Error" code:0 userInfo:0]);
        }
        else if (data != nil){
            NSError* jsonError = nil;
            NSDictionary* results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            if (jsonError) {
                // Non-JSON response
                NSString * response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                SSULogDebug(@"Response: %@",response);
            }
            else if (results[@"error"]) {
                completionBlock(nil, [NSError errorWithDomain:@"Create Point Received Error" code:0 userInfo:0]);
                SSULogDebug(@"Error creating point: %@", error.localizedDescription);
            }
            else {
                [[SSUMapModule sharedInstance].context performBlock:^{
                    SSUMapPoint* point = [SSUMapBuilder mapPointWithID:[results[SSUMoonlightManagerKeyID] stringValue] inContext:[SSUMapModule sharedInstance].context];
                    point.latitude = @(coordinate.latitude).stringValue;
                    point.longitude = @(coordinate.longitude).stringValue;
                    
                    completionBlock(point, nil);
                }];
            }
        }
        else {
            SSULogDebug(@"Did not receive response");
        }
    }];
}

- (void) modifyPoint:(SSUMapPoint*)point {
    SSULogDebug(@"Will Modify Point");
    NSString* urlBase = [SSUMoonlightBaseURL stringByAppendingPathComponent:@"modifyPoint"];
    NSDictionary * params = @{
                              @"pID" : point.id,
                              @"latitude" : point.latitude,
                              @"longitude" : point.longitude,
                              @"key" : [SSUDebugCredentials token]
                              };
    
    [SSUMoonlightCommunicator postURL:[NSURL URLWithString:urlBase] parameters:params completionHandler:^(NSData *data, NSError *error) {
        if (error) {
            SSULogDebug(@"Modify Point Error: %@", error.debugDescription);
        }
        else if(data) {
            NSString * response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            SSULogDebug(@"Response: %@",response);
            SSULogDebug(@"Did Modify Point");
        }
        else {
            SSULogDebug(@"Did not receive response");
        }
    }];
}

- (void) deleteConnectionsFromPoint:(SSUMapPoint*)point {
    for (SSUMapPoint* connection in [point connections]) {
        [self deleteConnectionFromA:point toB:connection];
    }
}

- (void) createConnectionsFromPoint:(SSUMapPoint*)point {
    for (SSUMapPoint* connection in [point connections]) {
        [self createConnectionFromA:point toB:connection];
    }
}

- (void) deletePoint:(SSUMapPoint*)point {
    SSULogDebug(@"Will Delete Point");
    NSString* urlBase = [SSUMoonlightBaseURL stringByAppendingPathComponent:@"deletePoint"];
    NSDictionary * params = @{
                              @"pID" : point.id,
                              @"key" : [SSUDebugCredentials token]
                              };

    [SSUMoonlightCommunicator postURL:[NSURL URLWithString:urlBase] parameters:params completionHandler:^(NSData *data, NSError *error) {
        if (error) {
            SSULogDebug(@"Delete Point Error: %@", error.debugDescription);
        }
        else if(data) {
#ifdef DEBUG
            NSString * response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            SSULogDebug(@"Response: %@",response);
#endif
            [[SSUMapModule sharedInstance].context performBlock:^{
                [[SSUMapModule sharedInstance].context deleteObject:point];
                SSULogDebug(@"Did Delete Point");
            }];
        }
        else {
            SSULogDebug(@"Did not receive response");
        }
    }];
}

- (void) createConnectionFromA:(SSUMapPoint*)pointA toB:(SSUMapPoint*)pointB {
    SSULogDebug(@"Will Create Connection");
    NSString* urlBase = [SSUMoonlightBaseURL stringByAppendingPathComponent:@"createConnection"];
    NSDictionary * params = @{
                              @"aID" : pointA.id,
                              @"bID" : pointB.id,
                              @"distance" : @([self distanceBetweenMapPoint:pointA andMapPoint:pointB]),
                              @"key" : [SSUDebugCredentials token]
                              };
    
    [SSUMoonlightCommunicator postURL:[NSURL URLWithString:urlBase] parameters:params completionHandler:^(NSData *data, NSError *error) {
        if (error) {
            SSULogDebug(@"Create Connection Error: %@", error.debugDescription);
        }
        else if (data != nil) {
#ifdef DEBUG
            NSString * response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            SSULogDebug(@"Response: %@",response);
#endif
            [[SSUMapModule sharedInstance].context performBlock:^{
                [pointA addConnectionsObject:pointB];
                [pointB addConnectionsObject:pointA];
                [[SSUMapModule sharedInstance].context save:nil];
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
    NSString* urlBase = [SSUMoonlightBaseURL stringByAppendingPathComponent:@"deleteConnection"];
    NSDictionary * params = @{
                              @"aID" : pointA.id,
                              @"bID" : pointB.id,
                              @"key" : [SSUDebugCredentials token]
                              };
    
    [SSUMoonlightCommunicator postURL:[NSURL URLWithString:urlBase] parameters:params completionHandler:^(NSData *data, NSError *error) {
        if (error) {
            SSULogDebug(@"Delete Connection Error: %@", error.debugDescription);
        }
        else if (data) {
#ifdef DEBUG
            NSString * response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            SSULogDebug(@"Response: %@",response);
#endif
            [[SSUMapModule sharedInstance].context performBlock:^{
                [pointA removeConnectionsObject:pointB];
                [pointB removeConnectionsObject:pointA];
                [[SSUMapModule sharedInstance].context save:nil];
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
            }];
            SSULogDebug(@"Did Delete Connection");
        }
        else {
            SSULogDebug(@"Did not receive response");
        }
    }];
}

@end
