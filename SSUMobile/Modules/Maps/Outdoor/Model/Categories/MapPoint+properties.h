//
//  MapPoint+properties.h
//  SSUMobile
//
//  Created by Andrew Huss on 3/5/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUMapPoint.h"
@import MapKit;
#import "Location+properties.h"
#import "SSUMapBuildingPerimeter.h"

@interface SSUMapPoint (properties) <MKAnnotation>

/// This point is part of a building.
@property (readonly) BOOL isBuildingPerimeter;

/// This point is part of a building but is not connected to any paths. It only represents a wall of the building.
@property (readonly) BOOL isBuildingWall;

/// This point is part of a building and is connected to a path.
@property (readonly) BOOL isBuildingEntrance;

/// This point is connected to the main campus path, and thus we can find directions to it.
@property (readonly) BOOL isConnectedToCampusPath;

/// The building perimeter this point is associated with, if any.
@property (readonly) SSUMapBuildingPerimeter *buildingPerimeter;

@end
