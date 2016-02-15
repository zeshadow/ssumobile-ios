//
//  SSUResourcesBuilder.h
//  SSUMobile
//
//  Created by Eric Amorde on 11/19/14.
//  Copyright (c) 2014 Computer Science. All rights reserved.
//

#import "SSUMoonlightBuilder.h"
#import "SSUResourcesEntry.h"
#import "SSUResourcesSection.h"

@interface SSUResourcesBuilder : SSUMoonlightBuilder

+ (SSUResourcesEntry *) resourceWithID:(NSNumber *)ID inContext:(NSManagedObjectContext *)context;
+ (SSUResourcesSection *) sectionWithID:(NSNumber *)ID inContext:(NSManagedObjectContext *)context;


@end
