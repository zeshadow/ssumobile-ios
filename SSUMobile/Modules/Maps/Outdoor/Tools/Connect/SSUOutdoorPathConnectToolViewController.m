//
//  SSUPathConnectToolViewController.m
//  SSUMobile
//
//  Created by Andrew Huss on 3/2/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUOutdoorPathConnectToolViewController.h"
#import "SSUMapModule.h"
#import "SSUDebugCredentials.h"

typedef enum Mode {
    kModeCreate = 0,
    kModeRemove,
    kModeOff,
} Mode;

@interface SSUOutdoorPathConnectToolViewController (){}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *undoButton;

@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSegmentedControl;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;


@property (strong, nonatomic) NSMutableArray* points;
@property (strong, nonatomic) NSMutableArray* connections;

@property (weak, nonatomic) SSUMapPoint* selectedPoint;
@property (nonatomic) Mode mode;

@end

@implementation SSUOutdoorPathConnectToolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [SSUDebugCredentials requestCredentials];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _mode = kModeOff;
    [self.mapView addAnnotations:self.mapPoints];
    [self connectMapPoints];
    _undoButton.enabled = YES;
}

- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [super mapView:mapView didSelectAnnotationView:view];
    if (_mode == kModeOff) return;
    
    if ([view.annotation isKindOfClass:[SSUMapPoint class]]) {
        SSUMapPoint* connectedPoint = (SSUMapPoint *)view.annotation;
        if (self.selectedPoint && self.selectedPoint != connectedPoint) {
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            
            dispatch_async(queue, ^{
                __block MKPolyline* newLine = nil;
                CLLocationCoordinate2D* coords = [self coordsFromAnnotations:@[self.selectedPoint, connectedPoint]];
                newLine = [MKPolyline polylineWithCoordinates:coords count:2];
                free(coords);
                switch (_mode) {
                    case kModeCreate:{
                        
                        if ([(self.selectedPoint).connections containsObject:connectedPoint] && [connectedPoint.connections containsObject:self.selectedPoint]) {
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Connection already exists" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
                            });
                            self.selectedPoint = connectedPoint;
                        }
                        else {
                            [[SSUMapModule sharedInstance].context performBlock:^{
                                [self createConnectionFromA:self.selectedPoint toB:connectedPoint];
                                
                                if (self.selectedPoint.connections.count == 1) {
                                    // refresh the point in case it was a building wall that just became a building entrance
                                    [mapView removeAnnotation:self.selectedPoint];
                                    [mapView addAnnotation:self.selectedPoint];
                                    
                                }
                                if (connectedPoint.connections.count == 1) {
                                    // refresh the point in case it was a building wall that just became a building entrance
                                    [mapView removeAnnotation:connectedPoint];
                                    [mapView addAnnotation:connectedPoint];
                                }
                                [self.mapView addOverlay:newLine];
                                self.selectedPoint = connectedPoint;
                            }];
                        }
                        break;
                    } // end case
                    case kModeRemove:{
                        MKPolyline* lineToRemove = nil;
                        for (id <MKOverlay> overlay in mapView.overlays) {
                            if ([overlay isKindOfClass:[MKPolyline class]]) {
                                if ([self comparePolyline:overlay toPolyline:newLine]) {
                                    lineToRemove = overlay;
                                    break;
                                }
                            }
                        }
                        if (lineToRemove) {
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                [self.mapView removeOverlay:lineToRemove];
                                
                                [self deleteConnectionFromA:self.selectedPoint toB:connectedPoint];
                                
                                if (!self.selectedPoint.connections.count) {
                                    // refresh the point in case it was a building entrance that just became a building wall
                                    [mapView removeAnnotation:self.selectedPoint];
                                    [mapView addAnnotation:self.selectedPoint];
                                }
                                if (!connectedPoint.connections.count) {
                                    // refresh the point in case it was a building entrance that just became a building wall
                                    [mapView removeAnnotation:connectedPoint];
                                    [mapView addAnnotation:connectedPoint];
                                }
                                
                                self.selectedPoint = connectedPoint;
                            });
                        }
                        else {
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No connection to remove" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
                            });
                            self.selectedPoint = connectedPoint;
                        }
                        break;
                    } // end case
                    case kModeOff: {
                        break;
                    } // end case
                }
            });
        }
        else {
            self.selectedPoint = connectedPoint;
        }
        _undoButton.enabled = YES;
        _cancelButton.enabled = YES;
    }
}

- (MKOverlayRenderer *) mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKOverlayRenderer * renderer = [super mapView:mapView rendererForOverlay:overlay];
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer * lineRenderer = (MKPolylineRenderer *)renderer;
        lineRenderer.strokeColor = [UIColor blackColor];
    }
    return renderer;
}


#pragma mark - Setters
- (void) setMode:(Mode)mode {
    _mode = mode;
    _modeSegmentedControl.selectedSegmentIndex = _mode;
}

- (IBAction)didChangeMode:(UISegmentedControl *)sender {
    _mode = (Mode)sender.selectedSegmentIndex;
}

- (IBAction)didTapCancel:(id)sender {
    for (id<MKAnnotation> annotation in self.mapView.selectedAnnotations) {
        [self.mapView deselectAnnotation:annotation animated:YES];
    }
    self.selectedPoint = nil;
    _cancelButton.enabled = NO;
    
    self.mode = kModeCreate;
}

- (void)setSelectedPoint:(SSUMapPoint *)selectedPoint {
    _selectedPoint = selectedPoint;
    self.parentViewController.navigationItem.title = selectedPoint.id ?: @"Path Connect Tool";
}



@end
