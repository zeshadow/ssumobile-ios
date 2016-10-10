//
//  SSUBuildingBoundariesMapViewController.m
//  SSUMobile
//
//  Created by Andrew Huss on 3/1/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUOutdoorBoundaryToolMapViewController.h"
#import "SSULogging.h"
#import "SSUBoundaryBuildingSelectorViewController.h"
#import "SSUMapModule.h"
#import "SSUDebugCredentials.h"

const NSInteger kCreateSegmentedIndex = 0;
const NSInteger kEditSegmentedIndex = 1;

@interface SSUOutdoorBoundaryToolMapViewController () <SSUBoundaryBuildingSelectorViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSegmentedControl;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *setButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;

@property (strong, nonatomic) SSUMapBuildingPerimeter* perimeterBeingEdited;
@property (weak, nonatomic) SSUMapPoint* selectedPoint;

@property (weak, nonatomic) SSUMapPoint* editingMapPoint;

@end

@implementation SSUOutdoorBoundaryToolMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.perimeterBeingEdited = nil;
    [SSUDebugCredentials requestCredentials];
}

- (void)setPerimeterBeingEdited:(SSUMapBuildingPerimeter *)perimeterBeingEdited {
    if (_perimeterBeingEdited) {
        [self.mapView removeAnnotations:self.perimeterBeingEdited.locations.array];
        [self.mapView removeOverlay:self.perimeterBeingEdited.polygon];
        [self.mapView addAnnotation:self.perimeterBeingEdited];
    }
    
    _perimeterBeingEdited = perimeterBeingEdited;
    
    self.parentViewController.navigationItem.title = perimeterBeingEdited.title ?: @"Boundaries";
    if (perimeterBeingEdited) {
        [self.mapView removeAnnotation:self.perimeterBeingEdited];
        [self.mapView addOverlay:self.perimeterBeingEdited.polygon];
        if (_modeSegmentedControl.selectedSegmentIndex == kEditSegmentedIndex) {
            [self.mapView addAnnotations:self.perimeterBeingEdited.locations.array];
        }
    }
}

- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [super mapView:mapView didSelectAnnotationView:view];
    if ([view.annotation isKindOfClass:[SSUMapPoint class]]) {
        _selectedPoint = (SSUMapPoint *)view.annotation;
        _deleteButton.enabled = self.modeSegmentedControl.selectedSegmentIndex;
    }
    else if ([view.annotation isKindOfClass:[SSUMapBuildingPerimeter class]]) {
        // Show the new perimeter
        self.perimeterBeingEdited = (SSUMapBuildingPerimeter *)view.annotation;
    }
}

- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (self.modeSegmentedControl.selectedSegmentIndex != kCreateSegmentedIndex) {
        // not in creation mode
        return;
    }
    
    if (!self.perimeterBeingEdited) {
        SSULogDebug(@"No building selected!");
        return;
    }

    CLLocationCoordinate2D coord = [self.mapView convertPoint:[sender locationInView:self.mapView]
                                         toCoordinateFromView:self.mapView];
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            [self createPointFromCoordinate:coord buildingID:self.perimeterBeingEdited.buildingID index:@(self.perimeterBeingEdited.locations.count).stringValue completionHandler:^(SSUMapPoint *point, SSUMapBuildingPerimeter * perimeter, NSError *error) {
                
                if (_modeSegmentedControl.selectedSegmentIndex == kEditSegmentedIndex) {
                    [self.mapView addAnnotation:point];
                }
                [self.mapView removeOverlay:self.perimeterBeingEdited.__polygon];
                self.perimeterBeingEdited.__polygon = nil;
                [self.mapView addOverlay:self.perimeterBeingEdited.polygon];
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
            [self.mapView removeOverlay:self.perimeterBeingEdited.__polygon];
            self.perimeterBeingEdited.__polygon = nil;
            [self.mapView addOverlay:self.perimeterBeingEdited.polygon];
            
            if ([view.annotation isKindOfClass:[SSUMapPoint class]]) {
                [self modifyPoint:(SSUMapPoint *)view.annotation];
            }
        }
        default:
            break;
    }
}

- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView* annotationView = [super mapView:mapView viewForAnnotation:annotation];
    if ([annotation isKindOfClass:[SSUMapPoint class]]) {
        if (annotationView) {
            annotationView.draggable = self.modeSegmentedControl.selectedSegmentIndex == kEditSegmentedIndex;
            annotationView.enabled = self.modeSegmentedControl.selectedSegmentIndex == kEditSegmentedIndex;
        }
        else {
            SSULogDebug(@"PROBLEM");
        }
        if ([self.perimeterBeingEdited.locations firstObject] == annotation) {
            // the first object will be lightly colored
            annotationView.alpha = 0.5;
        } else {
            annotationView.alpha = 1;
        }
    }
    return annotationView;
}

- (IBAction)didTapSet:(id)sender {
    if (self.perimeterBeingEdited) {
        [self performSegueWithIdentifier:@"DirectoryBuildings" sender:self];
    }
}

- (IBAction)didChangeMode:(UISegmentedControl *)sender {
    if (self.perimeterBeingEdited) {
        if (sender.selectedSegmentIndex == kEditSegmentedIndex) {
            [self.mapView addAnnotations:self.perimeterBeingEdited.locations.array];
        } else {
            NSAssert(sender.selectedSegmentIndex == kCreateSegmentedIndex, @"Only 2 options available.");
            [self.mapView removeAnnotations:self.perimeterBeingEdited.locations.array];
        }
        _deleteButton.enabled = sender.selectedSegmentIndex;
    }
}

- (IBAction)didTapDelete:(id)sender {
    if (_selectedPoint) {
        [self.mapView removeOverlay:self.perimeterBeingEdited.polygon];
        self.perimeterBeingEdited.__polygon = nil;
        
        [self.mapView removeAnnotations:self.perimeterBeingEdited.locations.array];
        
        [self deletePoint:_selectedPoint]; // TODO: if deletePoint is not successful, it shouldn't show the user that the point was deleted!
        [[SSUMapModule sharedInstance].context deleteObject:_selectedPoint];
        NSError* error = nil;
        if (![[SSUMapModule sharedInstance].context save:&error]) {
            SSULogDebug(@"Error: %@", error.debugDescription);
        }
        
        if (_modeSegmentedControl.selectedSegmentIndex == kEditSegmentedIndex) {
            [self.mapView addAnnotations:self.perimeterBeingEdited.locations.array];
        }
        
        [self.mapView addOverlay:self.perimeterBeingEdited.polygon];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:@"BuildingsSelector"]) {
        SSUBoundaryBuildingSelectorViewController* vc = segue.destinationViewController;
        vc.delegate = self;
        
        NSFetchRequest* request = [NSFetchRequest new];
        request.entity = [NSEntityDescription entityForName:SSUOutdoorMapEntityBuildingPerimeter inManagedObjectContext:[SSUMapModule sharedInstance].context];
        
        NSError* error = nil;
        NSArray* results = [[SSUMapModule sharedInstance].context executeFetchRequest:request error:&error];
        NSMutableSet* buildingIds = nil;
        if (results) {
            buildingIds = [NSMutableSet set];
            for (SSUMapBuildingPerimeter* bp in results) {
                if (bp.buildingID) {
                    [buildingIds addObject:bp.buildingID];
                }
            }
        }
        
        vc.definedBuildingIDs = [buildingIds copy];
    }
}

#pragma mark - SSUBoundaryBuildingSelectorViewControllerDelegate

- (void)boundaryBuildingSelector:(SSUBoundaryBuildingSelectorViewController *)viewController didSelectBuilding:(SSUBuilding *)building {
    self.perimeterBeingEdited = [SSUMapBuilder perimeterForBuilding:building inContext:[SSUMapModule sharedInstance].context];
    NSError* error = nil;
    if (![[SSUMapModule sharedInstance].context save:&error]) {
        // TODO: save only necessary when the perimeter was created
        SSULogDebug(@"Error: %@", error.debugDescription);
    }
}

@end
