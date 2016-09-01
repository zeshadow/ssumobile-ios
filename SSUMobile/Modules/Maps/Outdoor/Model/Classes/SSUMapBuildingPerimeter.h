//
//  BuildingPerimeter.h
//  SSUMobile
//
//  Created by Andrew Huss on 4/10/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

@import Foundation;
@import CoreData;
#import "SSUMapPolygon.h"


@interface SSUMapBuildingPerimeter : SSUMapPolygon

@property (nonatomic, retain) NSString * buildingID;
@property (nonatomic, retain) NSString * buildingName;

@end
