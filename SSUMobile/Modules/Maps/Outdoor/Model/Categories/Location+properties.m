//
//  Coordinate+properties.m
//  SSUMobile
//
//  Created by Andrew Huss on 3/5/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "Location+properties.h"

@implementation SSUMapLocation (properties)

- (CLLocationCoordinate2D) coordinate {
   return self.location.coordinate;
}

- (void) setCoordinate:(CLLocationCoordinate2D) newCoordinate {
    self.latitude = @(newCoordinate.latitude).stringValue;
    self.longitude = @(newCoordinate.longitude).stringValue;
}

- (CLLocation*) location {
    return [[CLLocation alloc] initWithLatitude:self.latitude.doubleValue longitude:self.longitude.doubleValue];
}



@end
