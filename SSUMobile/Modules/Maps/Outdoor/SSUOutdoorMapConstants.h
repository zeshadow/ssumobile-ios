//
//  SSUOutdoorMapConstants.h
//  SSUMobile
//
//  Created by Andrew Huss on 3/5/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

@import Foundation;

#define CLCOORDINATES_EQUAL( a, b ) (fabs(a.latitude - b.latitude) <= 0.000000000001 && fabs(a.longitude - b.longitude) <= 0.000000000001)

extern NSString* const SSUMapPointsUpdatedDateKey;
extern NSString* const SSUMapPerimetersUpdatedDateKey;
extern NSString* const SSUMapConnectionsUpdatedDateKey;

extern NSString* const SSUOutdoorMapEntityMapPoint;
extern NSString* const SSUOutdoorMapEntityPolygon;
extern NSString* const SSUOutdoorMapEntityLocation;
extern NSString* const SSUOutdoorMapEntityBuildingPerimeter;

