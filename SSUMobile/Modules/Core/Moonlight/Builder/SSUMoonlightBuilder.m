//
//  SSUBuilder.m
//  SSUMobile
//
//  Created by Andrew Huss on 1/30/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUMoonlightBuilder.h"
#import "SSULogging.h"

NSString* const SSUMoonlightManagerKeyID = @"id";
NSString* const SSUMoonlightManagerKeyCreated = @"created";
NSString* const SSUMoonlightManagerKeyModified = @"modified";
NSString* const SSUMoonlightManagerKeyDeleted = @"deleted";

@interface SSUMoonlightBuilder()

@property (nonatomic, strong, readwrite) NSDateFormatter * dateFormatter;

@end

@implementation SSUMoonlightBuilder

#pragma mark - Build

- (void) build:(id)results {
    [self doesNotRecognizeSelector:_cmd];
}

#pragma mark - Helper

- (NSDateFormatter*) dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterNoStyle;
        _dateFormatter.timeStyle = NSDateFormatterMediumStyle;
        _dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        _dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        // RFC 3339 style dates
        _dateFormatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'";
    }
    return _dateFormatter;
}

- (SSUMoonlightDataMode) modeFromCreated:(id)created modified:(id)modified deleted:(id)deleted {
    if (deleted && deleted != [NSNull null] && !SSUIsEmptyString(deleted)) {
        return SSUMoonlightDataModeDeleted;
    }
    else if (modified && modified != [NSNull null] && !SSUIsEmptyString(modified)) {
        return SSUMoonlightDataModeModified;
    }
    else if (created && created != [NSNull null] && !SSUIsEmptyString(created)) {
        return SSUMoonlightDataModeCreate;
    }
    return SSUMoonlightDataModeNone;
}

- (SSUMoonlightDataMode) modeFromJSONData:(NSDictionary *)jsonDictionary {
    return [self modeFromCreated:jsonDictionary[SSUMoonlightManagerKeyCreated]
                        modified:jsonDictionary[SSUMoonlightManagerKeyModified]
                         deleted:jsonDictionary[SSUMoonlightManagerKeyDeleted]];
}

#pragma mark - Query

+ (NSManagedObject *) objectWithEntityName:(NSString *)entityName
                                        ID:(id)ID
                                   context:(NSManagedObjectContext *)context {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K == %@", SSUMoonlightManagerKeyID, ID];
    return [self objectWithEntityName:entityName predicate:predicate context:context];
}


+ (NSManagedObject *) objectWithEntityName:(NSString *)entityName ID:(id)ID context:(NSManagedObjectContext *)context entityWasCreated:(BOOL *)isNew {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K == %@", SSUMoonlightManagerKeyID, ID];
    return [self objectWithEntityName:entityName predicate:predicate context:context entityWasCreated:isNew];
}


+ (NSManagedObject *) objectWithEntityName:(NSString *)entityName
                                 predicate:(NSPredicate *)predicate
                                   context:(NSManagedObjectContext *)context {
    return [self objectWithEntityName:entityName predicate:predicate context:context entityWasCreated:NULL];
}

/*
 This is used to find a object in a data model if it exists. If the object does not exist it will be created.
 */
+ (NSManagedObject *) objectWithEntityName:(NSString *)entityName
                                 predicate:(NSPredicate *)predicate
                                   context:(NSManagedObjectContext *)context
                          entityWasCreated:(BOOL*)isNew {
    __block NSManagedObject * returnValue = nil;
    [context performBlockAndWait:^{
        NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        request.includesPendingChanges = YES;
        request.predicate = predicate;
        
        //Does the object exist?
        NSError* error = nil;
        NSArray* results = [context executeFetchRequest:request error:&error];
        if (!results) {
            SSULogError(@"Error: %@", error);
            return;
        }
        else if (results.count == 1) {
            if (isNew) {
                *isNew = NO;
            }
            returnValue = results.firstObject;
            return;
        }
        else if (results.count > 1) {
            SSULogError(@"Error: More than one object fetched when expected only 1");
            for (NSManagedObject* object in results) {
                SSULogDebug(@"Object: %@", object);
            }
            returnValue = results.firstObject;
            return;
        }
        
        //Create the object
        if (isNew) {
            *isNew = YES;
        }
        
        returnValue = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    }];
    return returnValue;
}

+ (NSArray *) allObjectsWithEntityName:(NSString *)entityName matchingPredicate:(NSPredicate *)predicate context:(NSManagedObjectContext *)context {
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    fetchRequest.predicate = predicate;
    NSArray * results = [context executeFetchRequest:fetchRequest error:nil];
    return results;
}

+ (NSArray *) allObjectsWithEntityName:(NSString *)entityName context:(NSManagedObjectContext *)context {
    return [self allObjectsWithEntityName:entityName matchingPredicate:nil context:context];
}

- (NSArray *) allObjectsWithEntityName:(NSString *)entityName {
    return [[self class] allObjectsWithEntityName:entityName context:self.context];
}

+ (void) deleteObjectsWithEntityName:(NSString *)entityName matchingPredicate:(NSPredicate *)predicate context:(NSManagedObjectContext *)context {
    NSArray * objects = [self allObjectsWithEntityName:entityName matchingPredicate:predicate context:context];
    for (id object in objects) {
        [context deleteObject:object];
    }
}

- (NSDictionary *) cleanJSON:(NSDictionary *)json {
    NSMutableDictionary * result = [[NSMutableDictionary alloc] initWithDictionary:json];
    for (NSString * key in [json allKeys]) {
        if (json[key] == [NSNull null]) {
            [result removeObjectForKey:key];
        }
    }
    return result;
}

#pragma mark - Save

+ (void) saveContext:(NSManagedObjectContext *)context {
    if (context.concurrencyType != NSConfinementConcurrencyType) {
        [context performBlock:^{
            NSError* error = nil;
            if (![context save:&error]) {
                SSULogError(@"Builder Save Error: %@", error.debugDescription);
            }
            if (context.parentContext != nil) {
                [self saveContext:context.parentContext];
            }
            [context.parentContext performBlock:^{
                [context.parentContext save:nil];
            }];
        }];
    }
    else {
        NSError* error = nil;
        if (![context save:&error]) {
            SSULogError(@"Builder Save Error: %@", error.debugDescription);
        }
        if (context.parentContext != nil) {
            [self saveContext:context.parentContext];
        }
    }
}

- (void) saveContext {
    [[self class] saveContext:self.context];
}

@end
