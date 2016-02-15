//
//  SSUResourcesBuilder.m
//  SSUMobile
//
//  Created by Eric Amorde on 11/19/14.
//  Copyright (c) 2014 Computer Science. All rights reserved.
//

#import "SSUResourcesBuilder.h"
#import "SSUResourcesConstants.h"
#import "SSULogging.h"

@implementation SSUResourcesBuilder

+ (SSUResourcesEntry *) resourceWithID:(NSNumber *)ID inContext:(NSManagedObjectContext *)context {
    if (ID.integerValue == 0)
        return nil;
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", SSUMoonlightManagerKeyID, ID];
    BOOL created = NO;
    SSUResourcesEntry * resource = (SSUResourcesEntry *)[self objectWithEntityName:SSUResourcesEntityResource
                                                       predicate:predicate
                                                         context:context
                                                entityWasCreated:&created];
    if (created) {
        [resource setId:ID];
    }
    return resource;
}

+ (SSUResourcesSection *) sectionWithID:(NSNumber *)ID inContext:(NSManagedObjectContext *)context {
    if (ID.integerValue == 0)
        return nil;
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", SSUMoonlightManagerKeyID, ID];
    BOOL created = NO;
    SSUResourcesSection * section = (SSUResourcesSection *)[self objectWithEntityName:SSUResourcesEntitySection
                                                    predicate:predicate
                                                      context:context
                                             entityWasCreated:&created];
    if (created) {
        [section setId:ID];
    }
    return section;
}

- (void) build:(NSDictionary*)results {
    [self buildResources:results[@"Resource"]];
    [self buildSections:results[@"Section"]];
    [self saveContext];
}

- (void) buildResources:(NSArray *)resources {
    SSULogDebug(@"Started Resources: %lu", (unsigned long)resources.count);
    NSDate* start = [NSDate date];
    for (NSDictionary * resourceData in resources) {
        SSUMoonlightDataMode mode = [self modeFromJSONData:resourceData];
        
        NSNumber * resourceID = [NSNumber numberWithInteger:[resourceData[SSUMoonlightManagerKeyID] integerValue]];
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
        
        NSNumber * sectionID = [NSNumber numberWithInteger:[resourceData[SSUResourcesResourceKeySectionID] integerValue]];
        SSUResourcesSection * section = [SSUResourcesBuilder sectionWithID:sectionID inContext:self.context];
        resource.section = section;
    }
    
    SSULogDebug(@"Finished resources: %f", [[NSDate date] timeIntervalSinceDate:start]);
}

- (void) buildSections:(NSArray *)sections {
    SSULogDebug(@"Started Sections: %lu", (unsigned long)sections.count);
    NSDate* start = [NSDate date];
    for (NSDictionary * sectionData in sections) {
        SSUMoonlightDataMode mode = [self modeFromJSONData:sectionData];
        
        NSNumber * sectionID = [NSNumber numberWithInteger:[sectionData[SSUMoonlightManagerKeyID] integerValue]];
        SSUResourcesSection * section = [SSUResourcesBuilder sectionWithID:sectionID inContext:self.context];
        if (section == nil)
            continue;
        if (mode == SSUMoonlightDataModeDeleted) {
            [self.context deleteObject:section];
            continue;
        }
        
        section.name = sectionData[SSUResourcesSectionKeyName];
        section.position = [NSNumber numberWithInteger:[sectionData[SSUResourcesSectionKeyPosition] integerValue]];
    }
    
    SSULogDebug(@"Finished sections: %f", [[NSDate date] timeIntervalSinceDate:start]);
}


@end
