//
//  Section.h
//  SSUMobile
//
//  Created by Eric Amorde on 11/19/14.
//  Copyright (c) 2014 Computer Science. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SSUResourcesEntry;

@interface SSUResourcesSection : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSSet *resources;
@end

@interface SSUResourcesSection (CoreDataGeneratedAccessors)

- (void)addResourcesObject:(SSUResourcesEntry *)value;
- (void)removeResourcesObject:(SSUResourcesEntry *)value;
- (void)addResources:(NSSet *)values;
- (void)removeResources:(NSSet *)values;

@end
