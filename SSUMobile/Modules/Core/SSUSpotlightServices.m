//
//  SSUSpotlightServices.m
//  SSUMobile
//
//  Created by Eric Amorde on 08/16/2016.
//  Copyright © 2016 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUSpotlightServices.h"
#import "SSUMobile-Swift.h"

NSString * const SSUSpotlightActivityRequestingDisplayNotification = @"edu.sonoma.ssumobile.spotlight.activity.display";

@implementation SSUSpotlightServices

#pragma mark - CSSearchableItemIndexDelegate

- (void) searchableIndex:(CSSearchableIndex *)searchableIndex reindexAllSearchableItemsWithAcknowledgementHandler:(void (^)(void))acknowledgementHandler {
    NSArray<SSUSpotlightSupportedProtocol> * spotlightModules = [self getSpotlightModules];
    for (id<SSUSpotlightSupportedProtocol> module in spotlightModules) {
        [module searchAbleIndexRequestingUpdate:searchableIndex];
    }
}

- (void) searchableIndex:(CSSearchableIndex *)searchableIndex reindexSearchableItemsWithIdentifiers:(NSArray<NSString *> *)identifiers acknowledgementHandler:(void (^)(void))acknowledgementHandler {
    NSArray<SSUSpotlightSupportedProtocol> * spotlightModules = [self getSpotlightModules];
    for (NSString * identifier in identifiers) {
        for (id<SSUSpotlightSupportedProtocol> module in spotlightModules) {
            if ([module recognizesIdentifier:identifier]) {
                [module searchableIndex:searchableIndex reindexItemWithIdentifier:identifier];
                break;
            }
        }
    }
}

- (NSArray<SSUSpotlightSupportedProtocol> *) getSpotlightModules {
    NSArray<SSUSpotlightSupportedProtocol> * spotlightModules = (id)[[SSUModuleServices sharedInstance] modulesConformingToProtocol:@protocol(SSUSpotlightSupportedProtocol)];
    return spotlightModules;
}

@end
