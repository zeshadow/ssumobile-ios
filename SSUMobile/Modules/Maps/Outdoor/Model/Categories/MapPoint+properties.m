//
//  MapPoint+properties.m
//  SSUMobile
//
//  Created by Andrew Huss on 3/5/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "MapPoint+properties.h"
#import "Location+properties.h"
#import "SSUMapBuildingPerimeter.h"

@implementation SSUMapPoint (properties)

- (NSString*) title {
    return self.id;
}

- (BOOL)isBuildingPerimeter {
    return [self.polygon isKindOfClass:[SSUMapBuildingPerimeter class]];
}

- (BOOL)isBuildingEntrance {
    return self.isBuildingPerimeter && self.connections.count >= 1;
}

- (BOOL)isBuildingWall {
    return self.isBuildingPerimeter && self.connections.count == 0;
}

- (BOOL)isConnectedToCampusPath {
    if (self.isBuildingPerimeter) {
        return self.isBuildingEntrance;
    } else {
        // sometimes there are random points that aren't connected to anything.
        // Although this simple check isn't bullet proof (e.g. if we have a random
        // circle out in the middle of nowhere), it weeds out most of the invalid points.
        return self.connections.count >= 1;
    }
}

- (SSUMapBuildingPerimeter *)buildingPerimeter {
    if ([self.polygon isKindOfClass:[SSUMapBuildingPerimeter class]]) {
        return (SSUMapBuildingPerimeter *)self.polygon;
    } else {
        return nil;
    }
}

@end
