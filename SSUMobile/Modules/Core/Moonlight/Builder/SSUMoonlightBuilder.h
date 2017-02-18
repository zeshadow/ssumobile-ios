//
//  SSUBuilder.h
//  SSUMobile
//
//  Created by Andrew Huss on 1/30/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

@import Foundation;
@import CoreData;

#define SSUMoonlightBuilderStringify(obj) [obj description]

typedef NS_ENUM(NSInteger, SSUMoonlightDataMode) {
    SSUMoonlightDataModeCreate,
    SSUMoonlightDataModeModified,
    SSUMoonlightDataModeDeleted,
    SSUMoonlightDataModeNone
};

extern NSString* const SSUMoonlightManagerKeyID;
extern NSString* const SSUMoonlightManagerKeyCreated;
extern NSString* const SSUMoonlightManagerKeyModified;
extern NSString* const SSUMoonlightManagerKeyDeleted;

typedef void(^Block)(BOOL hadChanges, NSError* error);

@interface SSUMoonlightBuilder : NSObject

@property (nonatomic, copy) Block completionBlock;
@property (nonatomic) NSManagedObjectContext * context;
@property (nonatomic) NSData * data;
@property (nonatomic, readonly) NSDateFormatter * dateFormatter;

- (SSUMoonlightDataMode) modeFromCreated:(NSString *)created
                                modified:(NSString *)modified
                                 deleted:(NSString *)deleted;

- (SSUMoonlightDataMode) modeFromJSONData:(NSDictionary *)jsonDictionary;

+ (NSManagedObject *) objectWithEntityName:(NSString*)entityName
                                 predicate:(NSPredicate*)predicate
                                   context:(NSManagedObjectContext*)context
                          entityWasCreated:(BOOL*)isNew;

+ (NSManagedObject *) objectWithEntityName:(NSString*)entityName
                                predicate:(NSPredicate*)predicate
                                  context:(NSManagedObjectContext*)context;

+ (NSManagedObject *) objectWithEntityName:(NSString*)entityName
                                       ID:(id)ID
                                  context:(NSManagedObjectContext *)context;

+ (NSManagedObject *) objectWithEntityName:(NSString *)entityName
                                        ID:(id)ID
                                   context:(NSManagedObjectContext *)context
                          entityWasCreated:(BOOL*)isNew;

+ (NSArray *) allObjectsWithEntityName:(NSString *)entityName
                     matchingPredicate:(NSPredicate *)predicate
                               context:(NSManagedObjectContext *)context;

+ (NSArray *) allObjectsWithEntityName:(NSString *)entityName
                               context:(NSManagedObjectContext *)context;

- (NSArray *) allObjectsWithEntityName:(NSString *)entityName;

+ (void) deleteObjectsWithEntityName:(NSString *)entityName
                   matchingPredicate:(NSPredicate *)predicate
                             context:(NSManagedObjectContext *)context;

+ (void) saveContext:(NSManagedObjectContext*)context;
- (void) saveContext;

/** Removes any [NSNull null] instances from the given JSON dictionary */
- (NSDictionary *) cleanJSON:(NSDictionary *)json;

- (void) build:(id)results;

@end
