//
//  SSUOutdoorMapViewController.m
//  SSUMobile
//
//  Created by Andrew Huss on 2/17/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUOutdoorMapSuperViewController.h"
#import "SSULogging.h"
#import "SSUOutdoorMapConstants.h"

#import "SSUDirectoryModels.h"

#import "SSUMapModels.h"

#import "SSUDirectoryConstants.h"
#import "RBStoryboardLink.h"
#import "SSUBuildingViewController.h"
#import "SSUDepartmentViewController.h"
#import "SSUDirectoryViewController.h"
#import "SSUMoonlightCommunicator.h"

#import "SSUOutdoorMapSuperViewController_tools.h"

#import <MJDijkstra/MJDijkstra.h>
#import "SSUMobile-Swift.h"


const CGFloat kNavigationUpdateTime = 10;
const CFTimeInterval kMinimumTimeElapsedBetweenNavigationUpdates = 2;

@interface SSUBorderLabel : UILabel
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic, copy) UIColor *borderColor;
@end

@implementation SSUBorderLabel
- (void)drawTextInRect:(CGRect)rect {
    // http://stackoverflow.com/a/1424665
    CGSize shadowOffset = self.shadowOffset;
    UIColor *textColor = self.textColor;
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, self.borderWidth);
    CGContextSetLineJoin(c, kCGLineJoinRound);
    
    CGContextSetTextDrawingMode(c, kCGTextStroke);
    self.textColor = self.borderColor;
    [super drawTextInRect:rect];
    
    CGContextSetTextDrawingMode(c, kCGTextFill);
    self.textColor = textColor;
    self.shadowOffset = CGSizeMake(0, 0);
    [super drawTextInRect:rect];
    
    self.shadowOffset = shadowOffset;
}
@end

@interface SSUAnnotation : NSObject <MKAnnotation>
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@end

@implementation SSUAnnotation
@end

@interface SSUOutdoorMapSuperViewController()

@property (nonatomic) BOOL showsBuildingLabels;
@property (strong) NSMutableDictionary *dijkstrasDictionary;

@property CFTimeInterval lastUpdateTime;
@property (nonatomic) BOOL updatingNavigationPath;
@property (strong, nonatomic) MKPolyline* navigationPath;
@property (strong, nonatomic) MKPolyline* drivingPath;

@end

@implementation SSUMapBuildingPerimeter (SSUDijkstrasAdditions)

- (NSString *)idForDijkstrasDictionary {
    return [NSString stringWithFormat:@"b%@", self.buildingID];
}

+ (BOOL)isBuildingPerimeterID:(NSString *)id {
    return [id hasPrefix:@"b"];
}

@end

@implementation SSUOutdoorMapSuperViewController

#pragma mark - Navigation

- (void)updateNavigationPathWithCompletionHandler:(void(^)(MKPolyline* line, NSError *error))completionBlock; {
    if (!self.navigationDestination) {
        completionBlock(nil, [NSError errorWithDomain:kSSUErrorDomain
                                                 code:kSSUGenericErrorCode
                                             userInfo:@{NSLocalizedDescriptionKey: @"No destination specified."}]);
        return;
    }
    
    if (self.updatingNavigationPath) {
        completionBlock(nil, [NSError errorWithDomain:kSSUErrorDomain
                                                 code:kSSUGenericErrorCode
                                             userInfo:@{NSLocalizedDescriptionKey: @"Already in the middle of an update."}]);
        return;
    }
    
    if (!self.showDrivingDirections || [self locationIsOnCampus:self.mapView.userLocation.coordinate]) {
        // Remove any directions from off campus when they are no longer necessary
        [self.mapView removeOverlay:self.drivingPath];
        self.navigationStart = self.mapView.userLocation.coordinate;
    }
    
    // TODO: if the user is on the current path, then use the same path.
    self.updatingNavigationPath = YES;
    [self shortestPathFromStart:self.navigationStart
                     toBuilding:self.navigationDestination
              completionHandler:^(MKPolyline *line, NSError *error) {
                  if (error) {
                      SSULogError(@"Error finding path: %@", error);
                  } else if (!self.navigationDestination) {
                      // user pressed the stop button during the time it was looking for a new path
                      error = [NSError errorWithDomain:kSSUErrorDomain
                                                  code:kSSUGenericErrorCode
                                              userInfo:@{NSLocalizedDescriptionKey:@"User stopped navigating."}];
                  } else {
                      self.navigationPath = line;
                  }
                  self.updatingNavigationPath = NO;
                  completionBlock(line, error);
              }];
}

- (void)stopNavigating;
{
    self.navigationPath = nil;
    self.navigationDestination = nil;
    [self.mapView setRegion:[self campusRegion] animated:YES];
}

- (void)startNavigatingTo:(SSUMapBuildingPerimeter *)navigationDestination from:(CLLocationCoordinate2D)start completionHandler:(void (^)(BOOL successful))completionBlock {
    self.navigationPath = nil;
    self.navigationDestination = navigationDestination;
    self.navigationStart = (start.latitude == 0 && start.longitude == 0) ? self.mapView.userLocation.coordinate : start;
    [self updateNavigationPathWithCompletionHandler:^(MKPolyline *line, NSError *error) {
        if (!error) {
            const CGFloat kVerticalInsets = 50;
            const CGFloat kHorizontalInsets = 50;
            [self.mapView setVisibleMapRect:line.boundingMapRect edgePadding:UIEdgeInsetsMake(kVerticalInsets, kHorizontalInsets, kVerticalInsets, kHorizontalInsets) animated:YES];
        }
        if (completionBlock) {
            completionBlock(error == nil);
        }
    }];
}

- (void)startNavigatingTo:(SSUMapBuildingPerimeter *)navigationDestination completionHandler:(void(^)(BOOL successful))completionBlock;
{
    [self startNavigatingTo:navigationDestination
                       from:self.mapView.userLocation.coordinate
          completionHandler:completionBlock];
}

- (void)setNavigationPath:(MKPolyline *)navigationPath {
    if (self.navigationPath) {
        [self.mapView removeOverlay:self.navigationPath];
    }
    
    _navigationPath = navigationPath;
    
    if (navigationPath) {
        [self.mapView addOverlay:self.navigationPath];
    }
    self.showingDirections = (navigationPath != nil);
}

- (void) startNavigatingToCampusWithCompletion:(void (^)(BOOL successful))completion {
    CLLocationCoordinate2D flagPoleCoord = CLLocationCoordinate2DMake(38.338281, -122.674719);
    MKPlacemark * flagPole = [[MKPlacemark alloc] initWithCoordinate:flagPoleCoord addressDictionary:nil];
    MKMapItem * destination = [[MKMapItem alloc] initWithPlacemark:flagPole];
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = destination;
    request.transportType = MKDirectionsTransportTypeAny;
    [request setRequestsAlternateRoutes:YES];
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (!error) {
            MKRoute *route = response.routes.firstObject;
            [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
            self.drivingPath = route.polyline;
        }
        [self startNavigatingTo:self.navigationDestination from:flagPoleCoord completionHandler:^(BOOL success) {
            if (completion) {
                completion(success);
            }
        }];
    }];
}

#pragma mark - Helper methods

#define FEQUAL(a,b) (ABS((a) - (b)) < FLT_EPSILON)

- (CGPoint)pointOnLineSegmentStart:(CGPoint)lineStart end:(CGPoint)lineEnd closestToPoint:(CGPoint)userPoint {
    // line A: original path
    // line B: shortest path to it (perpendicular)
    
    if (FEQUAL(lineStart.x, lineEnd.x)) {
        // vertical line
        CGPoint intersection = CGPointMake(lineStart.x, userPoint.y);
        CGFloat topLineY = MAX(lineStart.y, lineEnd.y);
        CGFloat bottomLineY = MIN(lineStart.y, lineEnd.y);
        if (userPoint.y > topLineY) {
            intersection.y = topLineY;
        } else if (userPoint.y < bottomLineY) {
            intersection.y = bottomLineY;
        }
        return intersection;
    }
    
    // non-vertical line
    CGFloat slopeA = (lineStart.y - lineEnd.y) / (lineStart.x - lineEnd.x);
    CGFloat yIntA = lineStart.y - slopeA * lineStart.x;
    CGFloat slopeB = -1 / slopeA;
    CGFloat yIntB = userPoint.y - slopeB * userPoint.x;
    CGFloat x = (yIntB - yIntA) / (slopeA - slopeB);
    CGFloat y = slopeA * x + yIntA;
    
    CGPoint intersection = CGPointMake(x, y);
    CGPoint rightLinePoint = lineStart.x > lineEnd.x ? lineStart : lineEnd;
    CGPoint leftLinePoint = lineStart.x < lineEnd.x ? lineStart : lineEnd;
    if (intersection.x > rightLinePoint.x) {
        intersection = rightLinePoint;
    } else if (intersection.x < leftLinePoint.x) {
        intersection = leftLinePoint;
    }
    
    return intersection;
}

- (void)pointOnSegmentClosestTo:(CLLocationCoordinate2D)userPoint point:(out CLLocationCoordinate2D *)outClosestPoint segmentStart:(out SSUMapPoint **)outSegmentStart end:(out SSUMapPoint **)outSegmentEnd {
    CLLocationCoordinate2D closestPoint;
    SSUMapPoint *segmentEnd = nil;
    SSUMapPoint *segmentStart = nil;

    CGFloat minDistance = CGFLOAT_MAX;
    CGPoint userP = CGPointMake(userPoint.longitude, userPoint.latitude);
    const CLLocation* userLocation = [[CLLocation alloc] initWithLatitude:userPoint.latitude longitude:userPoint.longitude];
    
    for (SSUMapPoint* pointA in self.mapPoints) {
        if (!pointA.isConnectedToCampusPath) {
            // not connected
            continue;
        }
        for (SSUMapPoint *pointB in pointA.connections) {
            if (pointA.id.integerValue > pointB.id.integerValue) {
                // no need to process each edge twice, instead, only process those where B's id is greater than A's id
                continue;
            }
            
            // check distance to this edge (A->B)
            CGPoint pA = CGPointMake(pointA.coordinate.longitude, pointA.coordinate.latitude);
            CGPoint pB = CGPointMake(pointB.coordinate.longitude, pointB.coordinate.latitude);
            CGPoint pointOnLineSegment = [self pointOnLineSegmentStart:pA end:pB closestToPoint:userP];
            CLLocation *locationOnLineSegment = [[CLLocation alloc] initWithLatitude:pointOnLineSegment.y longitude:pointOnLineSegment.x];
            
            CGFloat distance = [userLocation distanceFromLocation:locationOnLineSegment];
            if (distance < minDistance) {
                minDistance = distance;
                closestPoint = locationOnLineSegment.coordinate;
                segmentStart = pointA;
                segmentEnd = pointB;
            }
        }
    }
    
    NSAssert(outSegmentStart != nil, @"Need to output a variable.");
    NSAssert(outSegmentEnd != nil, @"Need to output a variable.");
    NSAssert(outClosestPoint != nil, @"Need to output a variable.");
    *outSegmentStart = segmentStart;
    *outSegmentEnd = segmentEnd;
    *outClosestPoint = closestPoint;
}

- (SSUMapPoint*)closestMapPointToCoordinate:(CLLocationCoordinate2D)coordinate mustBeConnected:(BOOL)mustBeConnected {
    // TODO: do we really need these methods? seems like they are deprecated in favor of startingPathPointForUserCoordinate
    CGFloat minDistance = CGFLOAT_MAX;
    SSUMapPoint* closestPoint = nil;
    const CLLocation* location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    for (SSUMapPoint* point in self.mapPoints) {
        if (mustBeConnected && !point.isConnectedToCampusPath) {
            continue;
        }
        CGFloat distance = [point.location distanceFromLocation:location];
        if (distance < minDistance) {
            minDistance = distance;
            closestPoint = point;
        }
    }
    return closestPoint;
}


- (SSUMapPoint*) closestMapPointToCoordinate:(CLLocationCoordinate2D)coordinate {
    return [self closestMapPointToCoordinate:coordinate mustBeConnected:NO];
}

- (void)buildDijkstrasDictionaryWithCompletionHandler:(void(^)(void))completionBlock {
    if (self.dijkstrasDictionary) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock();
        });
        return;
    }
    
    NSMutableArray * objectIDs = [NSMutableArray new];
    for (SSUMapPoint * point in self.mapPoints) {
        [objectIDs addObject:point.objectID];
    }
    
    NSManagedObjectContext * backgroundContext = [[SSUMapModule sharedInstance] newBackgroundContext];
    [backgroundContext performBlock:^{
        NSMutableDictionary *dijkstrasDictionary = [NSMutableDictionary dictionary];
        // Copy objects to use in this background thread
        NSMutableArray * mapPoints = [NSMutableArray new];
        for (NSManagedObjectID * objID in objectIDs) {
            [mapPoints addObject:[backgroundContext objectWithID:objID]];
        }
        // build all connections from map points
        NSInteger connectionsFound = 0;
        for (SSUMapPoint* point in mapPoints) {
            for (SSUMapPoint* neighbor in point.connections) {
                if (!dijkstrasDictionary[point.id]) {
                    dijkstrasDictionary[point.id] = [NSMutableDictionary dictionary];
                }
                dijkstrasDictionary[point.id][neighbor.id] = [NSNumber numberWithInt:round([point.location distanceFromLocation:neighbor.location])];
                connectionsFound++;
            }
            
            // build all connections to buildings
            if (point.isBuildingEntrance) {
                SSUMapBuildingPerimeter *buildingPerimeter = point.buildingPerimeter;
                // Here we create nodes of the form "b10" to represent building 10. Now we connect each entrance to that node.
                // Finally instead of requesting directions to an entrance, we request directions to b10, and it will automatically choose the relevant entrance.
                dijkstrasDictionary[point.id][[buildingPerimeter idForDijkstrasDictionary]] = @0;
            }
        }
        
        NSAssert(connectionsFound > 0, @"No connections found!");
        
        self.dijkstrasDictionary = dijkstrasDictionary;
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock();
        });
    }];
}

- (void) shortestPathFromStart:(CLLocationCoordinate2D)start
                    toBuilding:(SSUMapBuildingPerimeter*)buildingPerimeter
             completionHandler:(void(^)(MKPolyline* line, NSError *error))completionBlock {

    if (start.longitude == 0 || !buildingPerimeter) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(nil, [NSError errorWithDomain:kSSUErrorDomain
                                                     code:kSSUGenericErrorCode
                                                 userInfo:@{NSLocalizedDescriptionKey: @"Not finding directions since we have an invalid start or end point (e.g. we might not have the user's location)."}]);
        });
        return;
    }
    
    [self buildDijkstrasDictionaryWithCompletionHandler:^{
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            NSString *destinationID = [buildingPerimeter idForDijkstrasDictionary];
            
            CLLocationCoordinate2D coordinateOnSegment;
            SSUMapPoint *nearestSegmentStart = nil;
            SSUMapPoint *nearestSegmentEnd = nil;
            [self pointOnSegmentClosestTo:start point:&coordinateOnSegment segmentStart:&nearestSegmentStart end:&nearestSegmentEnd];
            CLLocation *locationOnSegment = [[CLLocation alloc] initWithLatitude:coordinateOnSegment.latitude longitude:coordinateOnSegment.longitude];
            
            // TODO: if I start inside a building, don't try and connect me to a path, try to connect me to an entrance (I can't go through walls)
            // S represents the point on the path
            NSMutableArray *solution;
            @synchronized(self.dijkstrasDictionary) {
                self.dijkstrasDictionary[@"S"] = @{ nearestSegmentStart.id: [NSNumber numberWithInt:round([locationOnSegment distanceFromLocation:nearestSegmentStart.location])],
                                                    nearestSegmentEnd.id: [NSNumber numberWithInt:round([locationOnSegment distanceFromLocation:nearestSegmentEnd.location])]};
                //NSLog(@"Finding Directions from start segment %@<->%@ to destination: %@", nearestSegmentStart.id, nearestSegmentEnd.id, destinationID);
                
                solution = [MJShortestPath(self.dijkstrasDictionary, @"S", destinationID) mutableCopy];
            }
            
            if (!solution) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(nil, [NSError errorWithDomain:kSSUErrorDomain
                                                             code:kSSUGenericErrorCode
                                                         userInfo:@{NSLocalizedDescriptionKey: @"Unable to find path."}]);
                });
                return;
            }
            
            NSMutableArray *solutionPoints = [NSMutableArray array];
            
            // 1. add the current user's location
            SSUAnnotation *startingAnnotation = [SSUAnnotation new];
            startingAnnotation.coordinate = start;
            [solutionPoints addObject:startingAnnotation];

            // 2. add the point that connects the user to the nearest segment
            NSAssert([[solution firstObject] isEqualToString:@"S"], @"Should have started by connecting to a segment.");
            [solution removeObjectAtIndex:0];
            SSUAnnotation *segmentAnnotation = [SSUAnnotation new];
            segmentAnnotation.coordinate = coordinateOnSegment;
            [solutionPoints addObject:segmentAnnotation];
            
            // 3. add the rest of the points
            for (NSString *pointId in solution) {
                if (![SSUMapBuildingPerimeter isBuildingPerimeterID:pointId]) {
                    // don't add the final point which represents the building itself. We just need to get to the entrance.
                    [solutionPoints addObject:[SSUMapBuilder mapPointWithID:pointId inContext:[SSUMapModule sharedInstance].context]];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock([self polylineFromMKAnnotationArray:solutionPoints], nil);
            });
        });
    }];
}

- (MKPolyline*) polylineFromMKAnnotationArray:(NSArray *)arrayOfMKAnnotations {
    CLLocationCoordinate2D* coordinates = malloc(sizeof(CLLocationCoordinate2D) * arrayOfMKAnnotations.count);
    NSInteger index = 0;
    for (id<MKAnnotation> annotation in arrayOfMKAnnotations) {
        coordinates[index++] = annotation.coordinate;
    }
    MKPolyline* polyline = [MKPolyline polylineWithCoordinates:coordinates count:index];
    free(coordinates);
    return polyline;
}

- (BOOL) isPoint:(SSUMapPoint*)point inPaths:(NSMutableDictionary*)paths {
    NSManagedObjectID* objectID = point.objectID;
    for (NSArray* path in paths) {
        if ([path containsObject:objectID]) {
            return YES;
        }
    }
    return NO;
}

- (void) loadObject:(NSManagedObject*)object inContext:(NSManagedObjectContext*)context {
    if ([object isKindOfClass:[SSUBuilding class]]) {
        SSUBuilding* building = (SSUBuilding*)object;
        if ([SSUMapBuilder perimeterExistsForBuilding:building inContext:context]) {
            _loadedObject = [SSUMapBuilder perimeterForBuilding:building inContext:context];
        }
        else {
            _loadedObject = nil;
        }
    }
    else {
        [self performSegueWithIdentifier:@"BuildingMap" sender:object];
    }
}

- (void) loadBuildings {
    NSManagedObjectContext* context = [SSUMapModule sharedInstance].context;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:SSUOutdoorMapEntityBuildingPerimeter inManagedObjectContext:context];
    NSError *error = nil;
    NSArray* results = [context executeFetchRequest:request error:&error];
    
    if (!results || !results.count) {
        SSULogDebug(@"Error: %@", error.description);
    }
    for (SSUMapBuildingPerimeter* perimeter in results) {
        [_mapView addAnnotation:perimeter];
    }
}

- (NSArray *)mapPoints {
    if (!_mapPoints) {
        NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:SSUOutdoorMapEntityMapPoint];
        NSError* error = nil;
        request.returnsObjectsAsFaults = NO;
        NSArray* points = [[SSUMapModule sharedInstance].context executeFetchRequest:request error:&error];
        if (!points) {
            SSULogError(@"Error: %@", error.description);
            return nil;
        }
        _mapPoints = points;
    }
    return _mapPoints;
}

- (void) makeBuildingPerimeter:(SSUMapBuildingPerimeter*)buildingPerimeter visibleAnimated:(BOOL)animated {
    if (buildingPerimeter) {
        MKCoordinateRegion region = MKCoordinateRegionForMapRect(buildingPerimeter.boundingMapRect);
        [_mapView setRegion:region animated:animated];
    }
}

- (void) setBuildingPerimeter:(SSUMapBuildingPerimeter*)buildingPerimeter highlighted:(BOOL)highlighted {
    if (highlighted) {
        [_mapView addOverlay:buildingPerimeter.polygon];
    }
    else {
        [_mapView removeOverlay:buildingPerimeter.polygon];
    }
}

- (void)setShowsBuildingLabels:(BOOL)showsAnnotations {
    if (_showsBuildingLabels == showsAnnotations) {
        return;
    }
    
    _showsBuildingLabels = showsAnnotations;
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        if ([annotation isKindOfClass:[SSUMapBuildingPerimeter class]]) {
            [self.mapView viewForAnnotation:annotation].hidden = !showsAnnotations;
        }
    }
}

- (void)selectBuildingId:(NSInteger)buildingId {
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        if ([annotation isKindOfClass:[SSUMapBuildingPerimeter class]]) {
            SSUMapBuildingPerimeter *buildingPerimeter = (SSUMapBuildingPerimeter *)annotation;
            if (buildingPerimeter.buildingID.integerValue == buildingId) {
                [self makeBuildingPerimeter:buildingPerimeter visibleAnimated:NO];
                [self.mapView selectAnnotation:buildingPerimeter animated:YES];
                return;
            }
        }
    }
    
    SSULogError(@"Unable to find building: %ld", (long)buildingId);
}

+ (BOOL) canDisplayBuilding:(SSUBuilding *)building {
    NSFetchRequest* request = [NSFetchRequest new];
    request.entity = [NSEntityDescription entityForName:SSUOutdoorMapEntityBuildingPerimeter
                                 inManagedObjectContext:[SSUMapModule sharedInstance].context];
    
    __block BOOL result = NO;
    [[SSUMapModule sharedInstance].context performBlockAndWait:^{
        NSError* error = nil;
        NSArray* results = [[SSUMapModule sharedInstance].context executeFetchRequest:request error:&error];
        if (results) {
            for (SSUMapBuildingPerimeter* perimeter in results) {
                if ([perimeter.buildingID isEqualToString:building.id]) {
                    result = YES;
                    break;
                }
            }
        }
    }];
    return result;
}

#pragma mark - SSU Boundaries

/**
 Region of the campus to zoom to initially
 */
- (MKCoordinateRegion) campusRegion {
    const CLLocationDegrees kCampusCenterLatitude = 38.340534;
    const CLLocationDegrees kCampusCenterLongitude = -122.675323;
    const CLLocationDegrees kCampusLatitudeDelta = 0.006280;
    const CLLocationDegrees kCampusLongitudeDelta = 0.0005278;
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(kCampusCenterLatitude, kCampusCenterLongitude);
    MKCoordinateSpan span = MKCoordinateSpanMake(kCampusLatitudeDelta, kCampusLongitudeDelta);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
    return region;
}

/**
 Marks the physical boundaries of the campus
 
 Use to test if a location is on campus
 */
- (MKMapRect) campusMapRect {
    // 38.343115, -122.679788 TL
    // 38.336308, -122.667043 BR
    const CLLocationCoordinate2D topLeftCorner = CLLocationCoordinate2DMake(38.343115, -122.679788);
    const CLLocationCoordinate2D bottomRightCorner = CLLocationCoordinate2DMake(38.336308, -122.667043);

    MKMapPoint topLeftPoint = MKMapPointForCoordinate(topLeftCorner);
    MKMapPoint bottomRightPoint = MKMapPointForCoordinate(bottomRightCorner);
    MKMapRect mapRect = MKMapRectMake(topLeftPoint.x, topLeftPoint.y, bottomRightPoint.x - topLeftPoint.x, bottomRightPoint.y - topLeftPoint.y);
    
    return mapRect;
}

- (BOOL) locationIsOnCampus:(CLLocationCoordinate2D)location {
    MKMapPoint mapPoint = MKMapPointForCoordinate(location);
    return MKMapRectContainsPoint(self.campusMapRect, mapPoint);
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadBuildings];
    [self.mapView setRegion:[self campusRegion] animated:NO];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.showsBuildingLabels = YES;
    if (_loadedObject) {
        [self setBuildingPerimeter:_loadedObject highlighted:YES];
        [_mapView selectAnnotation:_loadedObject animated:YES];
        _loadedObject = nil;
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SSUDirectoryEntityBuilding]) {
        SSUBuildingViewController * controller = (SSUBuildingViewController *)segue.destinationViewController;
        SSUBuilding* building = [SSUDirectoryBuilder buildingWithID:((SSUMapBuildingPerimeter*)sender).buildingID inContext:[SSUDirectoryModule sharedInstance].context];
        [controller loadObject:building inContext:[SSUDirectoryModule sharedInstance].context];
    }
    else if ([segue.identifier isEqualToString:SSUDirectoryEntityDepartment]) {
        SSUDepartmentViewController * controller = (SSUDepartmentViewController *)segue.destinationViewController;
        [controller loadObject:sender inContext:[SSUDirectoryModule sharedInstance].context];
    }
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    else if ([annotation isKindOfClass:[SSUMapBuildingPerimeter class]]) {
        // Try to dequeue an existing pin view first.
        MKAnnotationView* annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:SSUDirectoryEntityBuilding];
        const NSInteger kLabelTag = 54;
        if (!annotationView)
        {
            // If an existing pin view was not available, create one.
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:SSUDirectoryEntityBuilding];
            annotationView.canShowCallout = NO;
            annotationView.draggable = NO;
            
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            
            SSUBorderLabel *label = [SSUBorderLabel new];
            label.borderColor = [UIColor blackColor];
            label.borderWidth = 2;
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:12];
            label.tag = kLabelTag;
            label.backgroundColor = [UIColor clearColor]; //[UIColor colorWithWhite:0.75 alpha:0.5];
            label.opaque = NO;
            [annotationView addSubview:label];
        }
        else {
            annotationView.annotation = annotation;
        }
        UILabel *label = (UILabel *)[annotationView viewWithTag:kLabelTag];
        label.text = ((SSUMapBuildingPerimeter *)annotation).title;
        [label sizeToFit];
        annotationView.frame = label.frame;
        
        return annotationView;
    }
    else if ([annotation isKindOfClass:[SSUMapPoint class]]) {
        SSUMapPoint *mapPoint = (SSUMapPoint *)annotation;
        MKPinAnnotationView* pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:SSUOutdoorMapEntityBuildingPerimeter];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:SSUOutdoorMapEntityBuildingPerimeter];
            pinView.animatesDrop = NO;
            pinView.canShowCallout = YES;
            pinView.draggable = NO;
        }
        else {
            pinView.annotation = annotation;
        }
        CGFloat alpha = 1;
        if (mapPoint.isBuildingEntrance) {
            pinView.pinColor = MKPinAnnotationColorGreen;
        } else if (mapPoint.isBuildingWall) {
            pinView.pinColor = MKPinAnnotationColorRed;
        } else {
            pinView.pinColor = MKPinAnnotationColorPurple;
            if (mapPoint.connections.count == 0) {
                alpha = 0.5;
            }
        }
        pinView.alpha = alpha;
        
        return pinView;
    }
    else if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        MKPinAnnotationView* pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:SSUOutdoorMapEntityMapPoint];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:SSUOutdoorMapEntityMapPoint];
            pinView.pinColor = MKPinAnnotationColorRed;
            pinView.animatesDrop = YES;
            pinView.canShowCallout = NO;
            pinView.draggable = NO;
        }
        else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    else {
        SSULogError(@"Unknown Annotation Type: %@", NSStringFromClass([annotation class]));
    }
    return nil;
}

- (MKOverlayRenderer *) mapView:(MKMapView *)mapView rendererForOverlay:(nonnull id<MKOverlay>)overlay {
    MKOverlayRenderer * renderer = nil;
    if ([overlay isKindOfClass:[MKPolygon class]]) {
        MKPolygonRenderer *polygon = [[MKPolygonRenderer alloc] initWithPolygon:overlay];
        polygon.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        polygon.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        polygon.lineWidth = 3;
        renderer = polygon;
    }
    else if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *line = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        line.lineWidth = 15;
        line.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.4];
        renderer = line;
    }
    return renderer;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    // show labels: at latitudeDelta = 0.018447, longitudeDelta = 0.013733
    // hide labels: at latitudeDelta = 0.036893, longitudeDelta = 0.027466
    self.showsBuildingLabels = (mapView.region.span.latitudeDelta < 0.03 &&
                                mapView.region.span.longitudeDelta < 0.02);
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    //    NSLog(@"New user location: %f,%f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    CFTimeInterval timeSinceLastUpdate = CACurrentMediaTime() - self.lastUpdateTime;
    if (timeSinceLastUpdate < kMinimumTimeElapsedBetweenNavigationUpdates) {
        // Don't update too frequently
        return;
    }

    [self updateNavigationPathWithCompletionHandler:^(MKPolyline *line, NSError *error) {
        if (!error) {
            self.lastUpdateTime = CACurrentMediaTime();
        }
    }];
}

#pragma mark - Annotation Selection Events

- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[SSUMapBuildingPerimeter class]]) {
        [self setBuildingPerimeter:(SSUMapBuildingPerimeter *)view.annotation highlighted:YES];
    }
}

- (void) mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[SSUMapBuildingPerimeter class]]) {
        [_mapView removeOverlay:((SSUMapBuildingPerimeter*)(view.annotation)).polygon];
        [self setBuildingPerimeter:(SSUMapBuildingPerimeter*)view.annotation highlighted:NO];
    }
}

@end
