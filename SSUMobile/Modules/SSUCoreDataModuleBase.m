//
//  SSUCoreDataModuleBase.m
//  SSUMobile
//
//  Created by Eric Amorde on 9/8/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUCoreDataModuleBase.h"
#import "SSULogging.h"

@implementation SSUCoreDataModuleBase


#pragma mark - Core Data stack

- (NSManagedObjectContextConcurrencyType) concurrencyType {
    return NSMainQueueConcurrencyType;
}

- (NSDictionary *) persistentStoreOptions {
#ifdef DEBUG
    // This makes debug builds create .sqlite files that are suitable for including the app bundle as
    // a "default" database
    return @{NSSQLitePragmasOption : @{@"journal_mode" : @"DELETE"}};
#else
    return nil;
#endif
}

- (NSMergePolicy *) mergePolicy {
    return NSMergeByPropertyStoreTrumpMergePolicy;
}

- (NSMergePolicyType) mergePolicyType {
    return NSMergeByPropertyStoreTrumpMergePolicyType;
}

- (NSManagedObjectModel *) modelWithName:(NSString *)name {
    NSURL * url = [[NSBundle bundleForClass:[self class]] URLForResource:name withExtension:@"momd"];
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinatorWithName:(NSString *)storeName
                                                                model:(NSManagedObjectModel *)model {
    NSURL *storeURL = [self.applicationDocumentsDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", storeName]];
    NSError *error = nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:storeURL.path]) {
        NSString *defaultStorePath = [[NSBundle bundleForClass:[self class]] pathForResource:storeName ofType:@"sqlite"];
        if (defaultStorePath) {
            NSError* copyError = nil;
            if (![[NSFileManager defaultManager] copyItemAtPath:defaultStorePath toPath:storeURL.path error:&copyError]) {
                SSULogError(@"Error: %@", copyError.debugDescription);
            }
            else {
                SSULogDebug(@"Loaded default %@ store...", storeName);
            }
        }
    }
    
    NSPersistentStoreCoordinator * psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    id options = [self persistentStoreOptions];
    if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // The models are incompatible, delete the store and recreate it
        [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:nil];
        [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:storeURL.path]) {
        [self setExcludeFromBackupAttributeOnResourceAtURL:storeURL toValue:YES];
    }
    return psc;
}

- (NSManagedObjectContext *) contextWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator {
    NSManagedObjectContext * context = [[NSManagedObjectContext alloc] initWithConcurrencyType:[self concurrencyType]];
    context.persistentStoreCoordinator = coordinator;
    context.mergePolicy = [self mergePolicy];
    
    return context;
}

- (NSManagedObjectContext *) newBackgroundContext {
    return [self backgroundContextFromContext:self.context];
}

/** 
 Creates a new context for use in a background thread, whose persistent store will be the same as
 the given context
 */
- (NSManagedObjectContext *) backgroundContextFromContext:(NSManagedObjectContext *)context {
    NSManagedObjectContext * backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    backgroundContext.parentContext = context;
    
    return backgroundContext;
}

@end
