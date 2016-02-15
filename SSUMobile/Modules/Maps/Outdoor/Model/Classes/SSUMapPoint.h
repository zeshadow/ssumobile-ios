//
//  MapPoint.h
//  SSUMobile
//
//  Created by Main on 4/16/14.
//  Copyright (c) 2014 Computer Science. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
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
