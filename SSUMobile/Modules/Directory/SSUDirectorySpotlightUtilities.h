//
//  SSUDirectorySpotlightUtilities.h
//  SSUMobile
//
//  Created by Eric Amorde on 16/08/2016.
//  Copyright © 2016 Sonoma State University Department of Computer Science. All rights reserved.
//

@import Foundation;
#import "SSUDirectoryModels.h"
#import "SSUSpotlightServices.h"

@interface SSUDirectorySpotlightUtilities : NSObject

+ (void) searchableIndex:(CSSearchableIndex *)index
             reindexItem:(NSString *)identifier
               inContext:(NSManagedObjectContext *)context
                  domain:(NSString *)domain;

+ (void) populateIndex:(CSSearchableIndex *)index
               context:(NSManagedObjectContext *)context
                domain:(NSString *)domain;

+ (SSUDirectoryObject *) objectForIdentifier:(NSString *)identifier;

@end
