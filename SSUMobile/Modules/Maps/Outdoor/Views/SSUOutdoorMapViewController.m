
#import "SSUOutdoorMapViewController.h"
#import "SSUDirectoryBuilder.h"
#import "SSUMapPopoverContentController.h"
#import "SSUMapBuildingDetailViewController.h"
#import "SSUMobile-Swift.h"


@interface SSUOutdoorMapViewController () <UIActionSheetDelegate,CLLocationManagerDelegate, SSUMapBuildingDetailDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *endDirectionsButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic) BOOL endDirectionsButtonVisible;
@property (nonatomic) NSInteger endDirectionsButtonInsertionIndex;
@property (nonatomic) CLLocationManager * locationManager;
@property (nonatomic) SSUMapBuildingPerimeter * selectedBuildingPerimeter;
@property (nonatomic) MKMapRect returnToRect;

@end

@implementation SSUOutdoorMapViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    MKUserTrackingBarButtonItem *userTrackingBarButtonItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    NSMutableArray *items = [self.toolbar.items mutableCopy];
    [items insertObject:userTrackingBarButtonItem atIndex:0];
    self.toolbar.items = items;
    self.endDirectionsButtonInsertionIndex = [self.toolbar.items indexOfObject:self.endDirectionsButton];
    
    self.endDirectionsButtonVisible = NO;
    self.showDrivingDirections = NO;
    self.navigationItem.rightBarButtonItem = nil;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self requestLocationAuthorization];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent = NO;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[SSUMapModule sharedInstance] updateData:^{
        self.mapPoints = nil;
    }];
}

- (void) setShowingDirections:(BOOL)showingDirections {
    [super setShowingDirections:showingDirections];
    self.endDirectionsButtonVisible = showingDirections;
}

- (void)setEndDirectionsButtonVisible:(BOOL)endDirectionsButtonVisible {
    _endDirectionsButtonVisible = endDirectionsButtonVisible;
    
    if (!_endDirectionsButtonVisible && [self.toolbar.items containsObject:self.endDirectionsButton]) {
        NSMutableArray *items = [self.toolbar.items mutableCopy];
        [items removeObject:self.endDirectionsButton];
        self.toolbar.items = items;
    }
    else if (_endDirectionsButtonVisible && ![self.toolbar.items containsObject:self.endDirectionsButton]) {
        NSMutableArray *items = [self.toolbar.items mutableCopy];
        [items insertObject:self.endDirectionsButton atIndex:self.endDirectionsButtonInsertionIndex];
        self.toolbar.items = items;
    }
}

- (MKCoordinateRegion)regionByZoomingInTo:(CLLocationCoordinate2D)center {
    const CLLocationDegrees kCampusZoomedInLatitudeDelta = 0.002306;
    const CLLocationDegrees kCampusZoomedInLongitudeDelta = 0.001717;
    MKCoordinateSpan span = MKCoordinateSpanMake(kCampusZoomedInLatitudeDelta, kCampusZoomedInLongitudeDelta);
    return MKCoordinateRegionMake(center, span);
}

- (NSArray *) departmentsForBuildingPerimeter:(SSUMapBuildingPerimeter *)perimeter {
    SSUBuilding * building = [SSUDirectoryBuilder buildingWithID:perimeter.buildingID inContext:[SSUDirectoryModule sharedInstance].context];
    NSSortDescriptor * descripter = [NSSortDescriptor sortDescriptorWithKey:@"term" ascending:YES];
    NSArray * departments = [building.departments sortedArrayUsingDescriptors:@[descripter]];
    return departments;
}

#pragma mark - IBActions

- (IBAction)schoolTapped:(UIBarButtonItem *)sender {
    [self.mapView setRegion:[self campusRegion] animated:YES];
}

- (IBAction)endDirectionsTapped:(UIBarButtonItem *)sender {
    self.endDirectionsButtonVisible = NO;
    [self.mapView removeOverlays:self.mapView.overlays];
    [self stopNavigating];
}

// Disabled for now, because the functionality is buggy.
// We should be selecting the building on the map, but if the building isn't actually visible
// because the user zoomed in or scrolled away, then it won't have an annotation view associated
// with it. So there's a few hiccups related to this functionality, and it was released to the
// App Store in a broken state.
//- (IBAction)browseTapped:(UIBarButtonItem *)sender {
//    [self performSegueWithIdentifier:@"BuildingsSelector" sender:self];
//}

#pragma mark - Popover

- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([super respondsToSelector:@selector(mapView:didSelectAnnotationView:)])
        [super mapView:mapView didSelectAnnotationView:view];
    if ([view.annotation isKindOfClass:[SSUMapBuildingPerimeter class]]) {
        [self showDetailForBuildingPerimeter:(SSUMapBuildingPerimeter *)view.annotation];
    }
}

- (void) showDetailForBuildingPerimeter:(SSUMapBuildingPerimeter *)perimeter {
    SSUBuilding * building = [SSUDirectoryBuilder buildingWithID:perimeter.buildingID inContext:[SSUDirectoryModule sharedInstance].context];
    
    SSUMapBuildingDetailViewController * vc = [SSUMapBuildingDetailViewController instantiateFromStoryboard];
    vc.building = building;
    vc.delegate = self;
    
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:^{
        [self setBuildingPerimeter:self.selectedBuildingPerimeter highlighted:NO];
        [self.mapView deselectAnnotation:self.selectedBuildingPerimeter animated:NO];
    }];
}

/**
 @return YES if the user's location is available for use
 */
- (BOOL) userLocationAvailable {
    CLLocationCoordinate2D userLocation = self.mapView.userLocation.coordinate;
    return CLLocationCoordinate2DIsValid(userLocation) && userLocation.latitude != 0 && userLocation.longitude != 0;
}

- (void) userRequestedDirections:(SSUMapBuildingPerimeter *)destination {
    if (![self userLocationAvailable]) {
        [[[UIAlertView alloc] initWithTitle:@"Unknown Location"
                                    message:@"We can't find your location right now. It's possible you have turned off Location Services for SSUMobile or that your device does not currently have location available"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }
    CLLocationCoordinate2D userLocation = self.mapView.userLocation.coordinate;
    void(^errorBlock)(void) = ^() {
        static NSString * message = @"We are unable to show you directions at the moment. It is possible you have disabled sharing your location with SSUMobile.";
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:message
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
        [alertView show];
    };
    if (![self locationIsOnCampus:userLocation]) {
        if (self.showDrivingDirections) {
            self.navigationDestination = destination;
            [self startNavigatingToCampusWithCompletion:^(BOOL successful) {
                if (successful) {
                    self.endDirectionsButtonVisible = YES;
                }
                else {
                    errorBlock();
                }
            }];
        }
        else {
            [[[UIAlertView alloc] initWithTitle:@"Off Campus"
                                        message:@"Directions are only available while you're on campus. Try again when you're on campus."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            return;
        }
    }
    else {
        [self startNavigatingTo:destination completionHandler:^(BOOL successful) {
            if (successful) {
                self.endDirectionsButtonVisible = YES;
            }
            else {
                errorBlock();
            }
        }];
    }
}

- (void) setBuildingPerimeter:(SSUMapBuildingPerimeter *)buildingPerimeter highlighted:(BOOL)highlighted {
    if ([super respondsToSelector:@selector(setBuildingPerimeter:highlighted:)])
        [super setBuildingPerimeter:buildingPerimeter highlighted:highlighted];
    self.selectedBuildingPerimeter = buildingPerimeter;
}

#pragma mark - SSUClassSearchTableViewControllerDelegate

- (void)didDismissWithBuildingChoice:(NSInteger)buildingId {
    if (buildingId == NSNotFound) {
        return;
    }
    
    [self selectBuildingId:buildingId];
}

#pragma mark - SSUMapBuildingDetailDelegate

- (void) mapBuildingDetailRequestedDirections:(SSUMapBuildingDetailViewController *)controller {
    if (![self userLocationAvailable]) {
        return;
    }
    if (controller.view.window) {
        [controller dismissViewControllerAnimated:YES completion:NULL];
    }
    
    SSUMapBuildingPerimeter * destination = [SSUMapBuilder perimeterForBuilding:controller.building inContext:[SSUMapModule sharedInstance].context];
    
    [self userRequestedDirections:destination];
    
}

#pragma mark - CLLocationManagerDelegate

- (void) requestLocationAuthorization
{
    // Starting iOS 8.0, we have to explicity request location access
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        [self.locationManager requestWhenInUseAuthorization];
}

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.mapView setShowsUserLocation:YES];
    }
    else {
        [self.mapView setUserTrackingMode:MKUserTrackingModeNone];
        [self.mapView setShowsUserLocation:NO];
    }
}

#pragma mark - MKMapViewDelegate


- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated {
    if (mode == MKUserTrackingModeFollow) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusNotDetermined) {
            // Have not yet requested access
            [self requestLocationAuthorization];
        }
        else if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
            // We don't have access to the user's location so don't try to move the map, it will
            // just show an empty screen
            [self requestLocationAuthorization];
            mapView.userTrackingMode = MKUserTrackingModeNone;
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Access Location"
                                                                 message:@"If you want to use the location feature, please allow SSUMobile to access your location in your phone's settings"
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles: nil];
            [alertView show];
        }
    }
}

@end
