//
//  MapPoint.h
//  SSUMobile
//
//  Created by Main on 4/16/14.
//  Copyright (c) 2014 Sonoma State University Department of Computer Science. All rights reserved.
//

@import Foundation;
@import CoreData;
#import "SSUMapLocation.h"

@class SSUMapPoint, SSUMapPolygon;

@interface SSUMapPoint : SSUMapLocation

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSSet *connections;
@property (nonatomic, retain) SSUMapPolygon *polygon;
@end

@interface SSUMapPoint (CoreDataGeneratedAccessors)

- (void)addConnectionsObject:(SSUMapPoint *)value;
- (void)removeConnectionsObject:(SSUMapPoint *)value;
- (void)addConnections:(NSSet *)values;
- (void)removeConnections:(NSSet *)values;

@end
