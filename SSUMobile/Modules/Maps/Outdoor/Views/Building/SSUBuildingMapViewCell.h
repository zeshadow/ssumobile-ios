//
//  SSUBuildingMapViewCell.h
//  SSUMobile
//
//  Created by Eric Amorde on 10/15/15.
//  Copyright © 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

@import UIKit;
@import MapKit;

#import "SSUDirectoryBuilder.h"

@interface SSUBuildingMapViewCell : UITableViewCell

@property (nonatomic) IBOutlet MKMapView * mapView;
@property (nonatomic) IBOutlet UIImageView * buildingImageView;
@property (nonatomic) IBOutlet UILabel * buildingLabel;

@property (nonatomic) SSUBuilding * building;

@property (nonatomic) BOOL showsOverlay;

@end
