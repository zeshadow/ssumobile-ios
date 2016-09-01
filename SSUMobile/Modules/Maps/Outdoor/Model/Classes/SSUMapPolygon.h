//
//  Polygon.h
//  SSUMobile
//
//  Created by Andrew Huss on 4/12/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

@import Foundation;
@import CoreData;

@class SSUMapPoint;
@class MKPolygon;
@interface SSUMapPolygon : NSManagedObject

@property (nonatomic, retain) NSOrderedSet *locations;
@property (strong, nonatomic) MKPolygon* __polygon;

@end

@interface SSUMapPolygon (CoreDataGeneratedAccessors)

- (void)insertObject:(SSUMapPoint *)value inLocationsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromLocationsAtIndex:(NSUInteger)idx;
- (void)insertLocations:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeLocationsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInLocationsAtIndex:(NSUInteger)idx withObject:(SSUMapPoint *)value;
- (void)replaceLocationsAtIndexes:(NSIndexSet *)indexes withLocations:(NSArray *)values;
- (void)addLocationsObject:(SSUMapPoint *)value;
- (void)removeLocationsObject:(SSUMapPoint *)value;
- (void)addLocations:(NSOrderedSet *)values;
- (void)removeLocations:(NSOrderedSet *)values;
@end
