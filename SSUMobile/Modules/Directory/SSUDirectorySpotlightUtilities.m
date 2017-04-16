//
//  SSUDirectorySpotlightUtilities.m
//  SSUMobile
//
//  Created by Eric Amorde on 8/16/2016.
//  Copyright © 2016 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUDirectorySpotlightUtilities.h"
#import "SSUDirectoryBuilder.h"
#import "SSULogging.h"
#import "SSUMobile-Swift.h"

@implementation SSUDirectorySpotlightUtilities

static NSString * kIdentifierComponentSeparater = @"_";

typedef NS_ENUM(NSInteger, SSUDirectorySpotlightIdentifierComponents) {
    SpotlightAppName = 0,
    SpotlightEntityName,
    SpotlightEntityID
};

+ (void) searchableIndex:(CSSearchableIndex *)index
             reindexItem:(NSString *)identifier
               inContext:(NSManagedObjectContext *)context
                  domain:(NSString *)domain {
    [context performBlock:^{
        SSUDirectoryObject * obj = [self objectForIdentifier:identifier];
        CSSearchableItem * item = nil;
        
        if ([obj isKindOfClass:[SSUPerson class]]) {
            CSSearchableItemAttributeSet * attributes = [self attributeSetForPerson:(SSUPerson *)obj];
            item = [[CSSearchableItem alloc] initWithUniqueIdentifier:identifier domainIdentifier:domain attributeSet:attributes];
        }
        else if ([obj isKindOfClass:[SSUDepartment class]]) {
            CSSearchableItemAttributeSet * attributes = [self attributeSetForDepartment:(SSUDepartment *)obj];
            item = [[CSSearchableItem alloc] initWithUniqueIdentifier:identifier domainIdentifier:domain attributeSet:attributes];
        }
        else {
            SSULogError(@"Unrecognized object ID from spotlight index - %@", obj);
            SSULogError(@"Deleting index entry");
            [index deleteSearchableItemsWithIdentifiers:@[identifier] completionHandler:NULL];
        }
        
        if (item != nil) {
            [index indexSearchableItems:@[item] completionHandler:NULL];
        }
    }];
}

+ (void) populateIndex:(CSSearchableIndex *)index context:(NSManagedObjectContext *)context domain:(NSString *)domain {
    [context performBlock:^{
        NSArray<CSSearchableItem *> * items = [self getSearchableItemsWithContext:context domain:domain];
        [index indexSearchableItems:items completionHandler:^(NSError * _Nullable error) {
            if (error != nil) {
                SSULogError(@"Error during spotlight index");
                SSULogError(@"%@", error);
            }
            else {
                SSULogDebug(@"Directory Spotlight index completed - %@ items indexed", @(items.count));
            }
        }];
    }];
}

/**
 Adds a single directory entry to the index, or updates it if already there.
 This should be used to add items that the user has viewed to the index
 */
+ (void) addObjectToSearchableIndex:(SSUDirectoryObject *)object {
    [object.managedObjectContext performBlock:^{
        NSString * domain = [[SSUDirectoryModule sharedInstance] identifier];
        CSSearchableItem * item = [self searchableItemForObject:object inDomain:domain];
        if (item != nil) {
            [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:@[item] completionHandler:NULL];
        }
    }];
}

#pragma mark - Private

+ (NSString *) baseContentDescription {
    return NSLocalizedString(@"Directory Entry",
                             @"A description of a directory entry that shows up in spotlight search");
}

+ (CSSearchableItem *) searchableItemForObject:(SSUDirectoryObject *)obj inDomain:(NSString *)domain {
    NSString * identifier = [self uniqueIdenfitierForObject:obj];
    if ([obj isKindOfClass:[SSUPerson class]]) {
        CSSearchableItemAttributeSet * attributes = [self attributeSetForPerson:(SSUPerson *)obj];
        return [[CSSearchableItem alloc] initWithUniqueIdentifier:identifier domainIdentifier:domain attributeSet:attributes];
    }
    else if ([obj isKindOfClass:[SSUDepartment class]]) {
        CSSearchableItemAttributeSet * attributes = [self attributeSetForDepartment:(SSUDepartment *)obj];
        return [[CSSearchableItem alloc] initWithUniqueIdentifier:identifier domainIdentifier:domain attributeSet:attributes];
    }
    else {
        SSULogError(@"Unrecognized object ID from spotlight index - %@", obj);
        SSULogError(@"Deleting index entry");
        return nil;
    }
}

+ (CSSearchableItemAttributeSet *) attributeSetForObject:(SSUDirectoryObject *)object {
    if ([object isKindOfClass:[SSUPerson class]]) {
        return [self attributeSetForPerson:(SSUPerson *)object];
    }
    else if ([object isKindOfClass:[SSUDepartment class]]) {
        return [self attributeSetForDepartment:(SSUDepartment *)object];
    }
    else {
        return nil;
    }
    //TODO: School? Building? eh..
}

+ (CSSearchableItemAttributeSet *) attributeSetForDepartment:(SSUDepartment *)department {
    NSString * itemType = (__bridge NSString *)kUTTypeText;
    CSSearchableItemAttributeSet * attributes = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:itemType];
    attributes.title = department.displayName;
    attributes.contentDescription = [self baseContentDescription];
    attributes.keywords = [department.displayName componentsSeparatedByString:@" "];
    return attributes;
}

+ (CSSearchableItemAttributeSet *) attributeSetForPerson:(SSUPerson *)person {
    NSString * itemType = (__bridge NSString *)kUTTypeText;
    CSSearchableItemAttributeSet * attributes = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:itemType];
    attributes.title = person.displayName;
    if (!SSUIsEmptyString(person.department.displayName)) {
        attributes.contentDescription = [NSString stringWithFormat:@"%@ - %@", [self baseContentDescription], person.department];
    }
    else {
        attributes.contentDescription = [self baseContentDescription];
    }
    attributes.keywords = [person.displayName componentsSeparatedByString:@" "];
    return attributes;
}

+ (NSString *) uniqueIdenfitierForObject:(SSUDirectoryObject *)object {
    NSArray * components = @[[SSUDirectoryModule sharedInstance].identifier, object.entity.name, object.id];
    return [components componentsJoinedByString:kIdentifierComponentSeparater];
}

+ (NSArray<CSSearchableItem *> *) getSearchableItemsWithContext:(NSManagedObjectContext *)context domain:(NSString *)domain {
    NSMutableArray<CSSearchableItem *> * items = [NSMutableArray new];
    [items addObjectsFromArray:[self getDepartmentItemsWithContext:context domain:domain]];
    //TODO: maybe we shouldn't index people, are there are over 2000 entries..
    //[items addObjectsFromArray:[self getPersonItemsWithContext:context domain:domain]];
    return items;
}

+ (NSArray<CSSearchableItem *> *) getDepartmentItemsWithContext:(NSManagedObjectContext *)context domain:(NSString *)domain {
    NSArray<SSUDepartment *> * departments = [SSUDirectoryBuilder allObjectsWithEntityName:SSUDirectoryEntityDepartment context:context];
    NSMutableArray<CSSearchableItem *> * items = [NSMutableArray new];
    for (SSUDepartment * department in departments) {
        CSSearchableItem * item = [self searchableItemForObject:department inDomain:domain];
        [items addObject:item];
    }
    return items;
}

+ (NSArray<CSSearchableItem *> *) getPersonItemsWithContext:(NSManagedObjectContext *)context domain:(NSString *)domain {
    NSArray<SSUPerson *> * people = [SSUDirectoryBuilder allObjectsWithEntityName:SSUDirectoryEntityPerson context:context];
    NSMutableArray<CSSearchableItem *> * items = [NSMutableArray new];
    for (SSUPerson * person in people) {
        CSSearchableItem * item = [self searchableItemForObject:person inDomain:domain];
        [items addObject:item];
    }
    return items;
}

+ (SSUDirectoryObject *) objectForIdentifier:(NSString *)identifier {
    NSArray * components = [identifier componentsSeparatedByString:kIdentifierComponentSeparater];
    NSString * entityName = components[SpotlightEntityName];
    NSString * entityID = components[SpotlightEntityID];
    NSManagedObjectContext * context = [[SSUDirectoryModule sharedInstance] context];
    SSUDirectoryObject * object = (SSUDirectoryObject *)[SSUDirectoryBuilder objectWithEntityName:entityName ID:entityID context:context];
    return object;
}


@end
