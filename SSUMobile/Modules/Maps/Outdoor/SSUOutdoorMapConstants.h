//
//  SSUOutdoorMapConstants.h
//  SSUMobile
//
//  Created by Andrew Huss on 3/5/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CLCOORDINATES_EQUAL( a, b ) (fabs(a.latitude - b.latitude) <= 0.000000000001 && fabs(a.longitude - b.longitude) <= 0.000000000001)

extern NSString* const SSUUserDefaultsPointsUpdatedDate;
extern NSString* const SSUUserDefaultsPerimetersUpdatedDate;
extern NSString* const SSUUserDefaultsConnectionsUpdatedDate;

//extern NSString* const SSUOutdoorMapEntity<##>;
extern NSString* const SSUOutdoorMapEntityMapPoint;
extern NSString* const SSUOutdoorMapEntityPolygon;
extern NSString* const SSUOutdoorMapEntityLocation;
extern NSString* const SSUOutdoorMapEntityBuildingPerimeter;

extern NSString* const SSUPointKeyLatitude;
extern NSString* const SSUPointKeyLongitude;