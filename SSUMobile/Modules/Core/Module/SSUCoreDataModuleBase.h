//
//  SSUCoreDataModuleBase.h
//  SSUMobile
//
//  Created by Eric Amorde on 9/8/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUModuleBase.h"

@interface SSUCoreDataModuleBase : SSUModuleBase

@property (nonatomic, strong) NSManagedObjectContext * context;
@property (nonatomic, strong) NSManagedObjectContext * backgroundContext;

#pragma mark - Core Data

- (NSManagedObjectModel *) modelWithName:(NSString *)name;
- (NSPersistentStoreCoordinator *) persistentStoreCoordinatorWithName:(NSString *)storeName
                                                                model:(NSManagedObjectModel *) model;
- (NSManagedObjectContext *) contextWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator;
- (NSManagedObjectContext *) newBackgroundContext;
- (NSManagedObjectContext *) backgroundContextFromContext:(NSManagedObjectContext *)context;

@end
