//
//  SSUDirectionToolViewController.m
//  SSUMobile
//
//  Created by Andrew Huss on 3/22/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUOutdoorDirectionToolViewController.h"
#import "SSULogging.h"

@interface SSUOutdoorDirectionToolViewController () <UIActionSheetDelegate>

@property (strong, nonatomic) MKPointAnnotation* startPoint;
@property (weak, nonatomic) MKPolyline* shortestPath;
@property (strong, nonatomic) SSUMapBuildingPerimeter *destination;

@property (strong, nonatomic) CLLocation *lastRecordedPoint;
@property (strong, nonatomic) NSMutableString *recordingOutput;

@end

@implementation SSUOutdoorDirectionToolViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)showPath {
    if (self.shortestPath) {
        [self.mapView removeOverlay:self.shortestPath];
    }

    [self shortestPathFromStart:self.startPoint.coordinate
                     toBuilding:self.destination
              completionHandler:^(MKPolyline *line, NSError *error) {
                  self.shortestPath = line;
                  if (line) {
                      [self.mapView addOverlay:line];
                  }
                  else if (error) {
                      SSULogDebug(@"%@",error);
                      NSString * message = [NSString stringWithFormat:@"Unable to find directions from %0.6f,%0.6f to %@",self.startPoint.coordinate.latitude,self.startPoint.coordinate.longitude,self.destination.buildingName];
                      UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                           message:message
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"OK"
                                                                 otherButtonTitles:nil];
                      [alertView show];
                  }
              }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView* view = [super mapView:mapView viewForAnnotation:annotation];
    
    if ([view isKindOfClass:[MKPinAnnotationView class]]) {
        view.draggable = NO;
    }
    return view;
}

- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)sender {
    CLLocationCoordinate2D coord = [self.mapView convertPoint:[sender locationInView:self.mapView]
                                         toCoordinateFromView:self.mapView];
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            SSULogDebug(@"Coordinate latitude: %f     longitude:%f", coord.latitude, coord.longitude);
            if (self.startPoint) {
                [self.mapView removeAnnotation:self.startPoint];
            }
            self.startPoint = [MKPointAnnotation new];
            self.startPoint.coordinate = coord;
            [self.mapView addAnnotation:self.startPoint];
            //[self.mapView addAnnotation:[self closestMapPointToCoordinate:coord]];
            [self showPath];
            break;
        }
        default:
            break;
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [super mapView:mapView regionDidChangeAnimated:animated];
    SSULogDebug(@"New map region! Center: %f,%f. Span:%f,%f.", mapView.region.center.latitude, mapView.region.center.longitude, mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta);
}

- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[SSUMapBuildingPerimeter class]]) {
        [mapView deselectAnnotation:view.annotation animated:NO]; // don't show the popup
        self.destination = (SSUMapBuildingPerimeter *)view.annotation;
        [self showPath];
    }
}

#pragma mark - IBActions

- (IBAction)actionButtonTapped:(UIBarButtonItem *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Toggle Point Recording", nil];
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: // Toggle Point Recording
            [self togglePointRecording];
            break;
        default:
            break;
    }
}

#pragma mark - Record Points

- (IBAction)mapViewTapped:(UITapGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateEnded || !self.recordingOutput) {
        return;
    }
    
    CLLocationCoordinate2D coord = [self.mapView convertPoint:[sender locationInView:self.mapView]
                                         toCoordinateFromView:self.mapView];
    [self recordPoint:coord];
    
    
    self.startPoint = [MKPointAnnotation new];
    self.startPoint.coordinate = coord;
    [self showPath];
}

- (void)recordPoint:(CLLocationCoordinate2D)newPoint {
    const CGFloat kAppleTravelTime = 2; // the default time it takes to travel from one point to another
    const CGFloat kDesiredSpeed = 6; // meters per sec
    const CGFloat kDesiredDistanceBetweenPoints = kDesiredSpeed * kAppleTravelTime;
    NSString * const kFormatString = @"    <wpt lat=\"%f\" lon=\"%f\"></wpt>\n";
    
    CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:newPoint.latitude longitude:newPoint.longitude];
    NSInteger numberOfPoints = 1;
    if (self.lastRecordedPoint) {
        CLLocationDistance distance = [self.lastRecordedPoint distanceFromLocation:newLocation];
        numberOfPoints = MAX(round(distance / kDesiredDistanceBetweenPoints), 1);
        CGFloat deltaLatitude = newPoint.latitude - self.lastRecordedPoint.coordinate.latitude;
        CGFloat deltaLongitude = newPoint.longitude - self.lastRecordedPoint.coordinate.longitude;
        for (NSInteger i = 0; i < numberOfPoints; i++) {
            CLLocationDegrees latitude = self.lastRecordedPoint.coordinate.latitude + (numberOfPoints/distance * deltaLatitude) * (i+1);
            CLLocationDegrees longitude = self.lastRecordedPoint.coordinate.longitude + (numberOfPoints/distance * deltaLongitude) * (i+1);
            [self.recordingOutput appendFormat:kFormatString, latitude, longitude];
        }
    } else {
        [self.recordingOutput appendFormat:kFormatString, newPoint.latitude, newPoint.longitude];
    }
    SSULogError(@"Recorded %ld point(s) to: %f,%f", (long)numberOfPoints, newPoint.latitude, newPoint.longitude);
    
    self.lastRecordedPoint = newLocation;
}


- (void)startRecordingPoints {
    SSULogError(@"Started recording points. Tap anywhere on the map to begin recording points.");
    self.recordingOutput = [NSMutableString string];
    [self.recordingOutput appendString:@"<?xml version=\"1.0\"?>\n<gpx version=\"1.1\" creator=\"Xcode\">\n"];
    self.lastRecordedPoint = nil;
}

- (void)stopRecordingPoints {
    [self.recordingOutput appendString:@"</gpx>"];
    SSULogError(@"Done recording, here is your gpx file: \n%@", self.recordingOutput);
    self.recordingOutput = nil;
}

- (void)togglePointRecording {
    if (!self.recordingOutput) {
        [self startRecordingPoints];
    } else {
        [self stopRecordingPoints];
    }
}

@end
