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
NSString* const SSUMoonlightManagerKeyCreated = @"Created";
NSString* const SSUMoonlightManagerKeyModified = @"Modified";
NSString* const SSUMoonlightManagerKeyDeleted = @"Deleted";

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
        _dateFormatter.locale = [NSLocale currentLocale];
        _dateFormatter.timeZone = [NSTimeZone localTimeZone];
        _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    return _dateFormatter;
}

- (SSUMoonlightDataMode) modeFromCreated:(NSString*)created modified:(NSString*)modified deleted:(NSString*)deleted {
    if (deleted && ![deleted isEqualToString:@"None"]) {
        return SSUMoonlightDataModeDeleted;
    }
    else if (modified && ![modified isEqualToString:@"None"]) {
        return SSUMoonlightDataModeModified;
    }
    else if (created && ![created isEqualToString:@"None"]) {
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
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K == %@",SSUMoonlightManagerKeyID,ID];
    return [[self class] objectWithEntityName:entityName predicate:predicate context:context];
}


+ (NSManagedObject *) objectWithEntityName:(NSString *)entityName
                                 predicate:(NSPredicate *)predicate
                                   context:(NSManagedObjectContext *)context {
    return [[self class] objectWithEntityName:entityName predicate:predicate context:context entityWasCreated:NULL];
}

/*
 This is used to find a object in a data model if it exists. If the object does not exist it will be created.
 */
+ (NSManagedObject *) objectWithEntityName:(NSString *)entityName
                                 predicate:(NSPredicate *)predicate
                                   context:(NSManagedObjectContext *)context
                          entityWasCreated:(BOOL*)isNew {
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.includesPendingChanges = YES;
    request.predicate = predicate;
    
    //Does the object exist?
    NSError* error = nil;
    NSArray* results = [context executeFetchRequest:request error:&error];
    if (!results) {
        SSULogError(@"Error: %@", error.debugDescription);
        return nil;
    }
    else if (results.count == 1) {
        if (isNew) {
            *isNew = NO;
        }
        return results.firstObject;
    }
    else if (results.count > 1) {
        SSULogError(@"Error: %@", @"More than one object returned in fetch");
        for (NSManagedObject* object in results) {
            SSULogDebug(@"Object: %@", object);
        }
        return nil;
    }
    
    //Create the object
    if (isNew) {
        *isNew = YES;
    }
    
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
}

+ (NSArray *) allObjectsWithEntityName:(NSString *)entityName context:(NSManagedObjectContext *)context {
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSArray * results = [context executeFetchRequest:fetchRequest error:nil];
    return results;
}

- (NSArray *) allObjectsWithEntityName:(NSString *)entityName {
    return [[self class] allObjectsWithEntityName:entityName context:self.context];
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
