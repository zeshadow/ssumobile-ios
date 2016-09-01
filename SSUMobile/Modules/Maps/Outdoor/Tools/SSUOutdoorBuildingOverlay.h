//
//  SSUBuildingOverlay.h
//  SSUMobile
//
//  Created by Andrew Huss on 2/18/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

@import MapKit;
#import "SSUBuilding.h"

@interface SSUOutdoorBuildingOverlay : MKPolygonView

@property (strong, nonatomic) SSUBuilding* building;

@end
