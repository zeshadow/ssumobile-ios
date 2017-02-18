//
//  SSUSpotlightServices.h
//  SSUMobile
//
//  Created by Eric Amorde on 08/16/2016.
//  Copyright © 2016 Sonoma State University Department of Computer Science. All rights reserved.
//

@import Foundation;
@import UIKit;
@import CoreSpotlight;
@import MobileCoreServices;

extern NSString * const SSUSpotlightActivityRequestingDisplayNotification;

@protocol SSUSpotlightSupportedProtocol <NSObject>

/** Return YES if the item with the given identifier originates from you */
- (BOOL) recognizesIdentifier:(NSString *)identifier;
/** Called when the receiver should update the given entry in the index */
- (void) searchableIndex:(CSSearchableIndex *)index reindexItemWithIdentifier:(NSString *)identifier;
/** Called when the receiver should update all entries in the index */
- (void) searchAbleIndexRequestingUpdate:(CSSearchableIndex *)index;
/** Prepare a view controller to display the item which was selected in search */
- (UIViewController *) viewControllerForSearchableItemWithIdentifier:(NSString *)identfier;

@end

@interface SSUSpotlightServices : CSIndexExtensionRequestHandler <CSSearchableIndexDelegate>

@end
