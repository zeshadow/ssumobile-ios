//
//  SSUPathPointToolViewController.m
//  SSUMobile
//
//  Created by Andrew Huss on 3/2/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

typedef enum Mode {
    kModeCreate = 0,
    kModeEdit,
    kModeOff,
} Mode;

#import "SSUOutdoorPathPointToolViewController.h"
#import "SSUMapModels.h"
#import "SSUDebugCredentials.h"

@interface SSUOutdoorPathPointToolViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSegmentedControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;

- (IBAction)addButtonPressed:(id)sender;

@property (weak, nonatomic) SSUMapPoint* selectedPoint;

#pragma mark - Dragging Properties
@property (strong, nonatomic) NSArray* connectedLines;
@property (strong, nonatomic) SSUMapPoint* draggingPoint;

@end

@implementation SSUOutdoorPathPointToolViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self loadPathPoints];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadPathPoints];
    [SSUDebugCredentials requestCredentials];
}

- (void) loadPathPoints {
    [self.mapView addAnnotations:self.mapPoints];
    self.modeSegmentedControl.enabled = self.mapPoints.count;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (self.modeSegmentedControl.selectedSegmentIndex == kModeEdit ||
        self.modeSegmentedControl.selectedSegmentIndex == kModeOff)
        return;
    CLLocationCoordinate2D coord = [self.mapView convertPoint:[sender locationInView:self.mapView]
                                         toCoordinateFromView:self.mapView];
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            [self createPointFromCoordinate:coord completionHandler:^(SSUMapPoint *point, NSError *error) {
                _modeSegmentedControl.enabled = YES;
                if (!error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.mapView addAnnotation:point];
                    });
                }
            }];
            break;
        }
        case UIGestureRecognizerStateChanged:
            break;
        case UIGestureRecognizerStateEnded: {
            break;
        }
        default:
            break;
    }
}

- (void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    switch (newState) {
        case MKAnnotationViewDragStateEnding: {
            if ([view.annotation isKindOfClass:[SSUMapPoint class]]) {
                [self modifyPoint:(SSUMapPoint *)view.annotation];
            }
        }
        default:
            break;
    }
}

- (IBAction)didChangeModeValue:(UISegmentedControl *)sender {
    SSUMapPoint* tempSelectedPoint = _selectedPoint;
    NSArray* annotations = self.mapView.annotations;
    
    // Update the draggable and enabled settings of the point annotations
    for (id<MKAnnotation> annotation in annotations) {
        MKAnnotationView * view = [self.mapView viewForAnnotation:annotation];
        view.draggable = (self.modeSegmentedControl.selectedSegmentIndex == kModeEdit);
        view.enabled = (self.modeSegmentedControl.selectedSegmentIndex == kModeEdit);
    }
    
    
    [self.mapView selectAnnotation:tempSelectedPoint animated:NO];
    _deleteButton.enabled = (sender.selectedSegmentIndex == kModeEdit) && _selectedPoint;
}

- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView* annotationView = [super mapView:mapView viewForAnnotation:annotation];
    if ([annotation isKindOfClass:[SSUMapPoint class]]) {
        annotationView.draggable = (self.modeSegmentedControl.selectedSegmentIndex == kModeEdit);
        annotationView.enabled = (self.modeSegmentedControl.selectedSegmentIndex == kModeEdit);
    }
    return annotationView;
}


- (IBAction)didTapDeleteButton:(id)sender {
    if (_selectedPoint) {
        SSUMapPoint* pointToRemove = _selectedPoint;
        [self.mapView removeAnnotation:pointToRemove];
        [self deletePoint:pointToRemove];
    }
}

- (IBAction)addButtonPressed:(id)sender {
    // TODO: Clean this feature up a bit
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    CLLocationCoordinate2D location = self.mapView.userLocation.coordinate;
    [self createPointFromCoordinate:location completionHandler:^(SSUMapPoint *point, NSError *error) {
        _modeSegmentedControl.enabled = YES;
        if (!error) {
            [self.mapView addAnnotation:point];
        }
    }];
}

- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [super mapView:mapView didSelectAnnotationView:view];
    NSAssert([view.annotation isKindOfClass:[SSUMapPoint class]], @"Expecting an SSUMapPoint here");
    _selectedPoint = (SSUMapPoint *)view.annotation;
    _deleteButton.enabled = self.modeSegmentedControl.selectedSegmentIndex == kModeEdit;
}

- (void) mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    [super mapView:mapView didDeselectAnnotationView:view];
    if (_selectedPoint) {
        _selectedPoint = nil;
        _deleteButton.enabled = NO;
    }
}



@end
