//
//  SSUResourcesBuilder.m
//  SSUMobile
//
//  Created by Eric Amorde on 11/19/14.
//  Copyright (c) 2014 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUResourcesBuilder.h"
#import "SSUResourcesConstants.h"
#import "SSULogging.h"

NSString * const SSUResourcesResourceKeyName = @"name";
NSString * const SSUResourcesResourceKeyURL = @"url";
NSString * const SSUResourcesResourceKeyPhone = @"phone";
NSString * const SSUResourcesResourceKeyImageURL = @"imageURL";
NSString * const SSUResourcesResourceKeySectionID = @"section";

NSString * const SSUResourcesSectionKeyName = @"name";
NSString * const SSUResourcesSectionKeyPosition = @"position";

@implementation SSUResourcesBuilder

+ (SSUResourcesEntry *) resourceWithID:(NSNumber *)ID inContext:(NSManagedObjectContext *)context {
    if (ID.integerValue == 0)
        return nil;
    BOOL created = NO;
    SSUResourcesEntry * resource = (SSUResourcesEntry *)[self objectWithEntityName:SSUResourcesEntityResource
                                                                                ID:ID
                                                                           context:context
                                                                  entityWasCreated:&created];
    if (created) {
        resource.id = ID;
    }
    return resource;
}

+ (SSUResourcesSection *) sectionWithID:(NSNumber *)ID inContext:(NSManagedObjectContext *)context {
    if (ID.integerValue == 0)
        return nil;
    BOOL created = NO;
    SSUResourcesSection * section = (SSUResourcesSection *)[self objectWithEntityName:SSUResourcesEntitySection
                                                                                   ID:ID
                                                                              context:context
                                                                     entityWasCreated:&created];
    if (created) {
        section.id = ID;
    }
    return section;
}

- (void) buildResources:(NSArray *)resources {
    SSULogDebug(@"Started Resources: %lu", (unsigned long)resources.count);
    NSDate* start = [NSDate date];
    for (NSDictionary * raw in resources) {
        NSDictionary * resourceData = [self cleanJSON:raw];
        SSUMoonlightDataMode mode = [self modeFromJSONData:resourceData];
        
        NSNumber * resourceID = @([resourceData[SSUMoonlightManagerKeyID] integerValue]);
        SSUResourcesEntry * resource = [SSUResourcesBuilder resourceWithID:resourceID inContext:self.context];
        if (resource == nil)
            continue;
        if (mode == SSUMoonlightDataModeDeleted) {
            [self.context deleteObject:resource];
            continue;
        }
        
        resource.name = resourceData[SSUResourcesResourceKeyName];
        resource.url = resourceData[SSUResourcesResourceKeyURL];
        resource.phone = resourceData[SSUResourcesResourceKeyPhone];
        resource.imageURL = resourceData[SSUResourcesResourceKeyImageURL];
        
        NSNumber * sectionID = @([resourceData[SSUResourcesResourceKeySectionID] integerValue]);
        SSUResourcesSection * section = [SSUResourcesBuilder sectionWithID:sectionID inContext:self.context];
        resource.section = section;
    }
    [self saveContext];
    SSULogDebug(@"Finished resources: %f", [[NSDate date] timeIntervalSinceDate:start]);
}

- (void) buildSections:(NSArray *)sections {
    SSULogDebug(@"Started Sections: %lu", (unsigned long)sections.count);
    NSDate* start = [NSDate date];
    for (NSDictionary * raw in sections) {
        NSDictionary * sectionData = [self cleanJSON:raw];
        SSUMoonlightDataMode mode = [self modeFromJSONData:sectionData];
        
        NSNumber * sectionID = @([sectionData[SSUMoonlightManagerKeyID] integerValue]);
        SSUResourcesSection * section = [SSUResourcesBuilder sectionWithID:sectionID inContext:self.context];
        if (section == nil)
            continue;
        if (mode == SSUMoonlightDataModeDeleted) {
            [self.context deleteObject:section];
            continue;
        }
        
        section.name = sectionData[SSUResourcesSectionKeyName];
        section.position = @([sectionData[SSUResourcesSectionKeyPosition] integerValue]);
    }
    [self saveContext];
    
    SSULogDebug(@"Finished sections: %f", [[NSDate date] timeIntervalSinceDate:start]);
}


@end
