//
//  SSUResourcesBuilder.h
//  SSUMobile
//
//  Created by Eric Amorde on 11/19/14.
//  Copyright (c) 2014 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUMoonlightBuilder.h"
#import "SSUResourcesEntry.h"
#import "SSUResourcesSection.h"

@interface SSUResourcesBuilder : SSUMoonlightBuilder

+ (SSUResourcesEntry *) resourceWithID:(NSNumber *)ID inContext:(NSManagedObjectContext *)context;
+ (SSUResourcesSection *) sectionWithID:(NSNumber *)ID inContext:(NSManagedObjectContext *)context;

- (void) buildResources:(NSArray *)resources;
- (void) buildSections:(NSArray *)sections;


@end
