//
//  SSUSearchableTableViewController.h
//  SSUMobile
//
//  Created by Eric Amorde on 31/08/2016.
//  Copyright © 2016 Sonoma State University Department of Computer Science. All rights reserved.
//

@import UIKit;

#import "SSUCoreTableViewController.h"

@interface SSUSearchableTableViewController : SSUCoreTableViewController <UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, nonnull, strong) UISearchController * searchController;

/**
 The key used in the predicate for text searches.
 
 Default: term
 */
@property (nonatomic, nullable, strong) NSString * searchKey;

/**
 Will be YES if currently searching
 */
@property (nonatomic) BOOL isSearching;

- (void) filterContentForSearchText:(nonnull NSString *)searchText;
- (nonnull NSPredicate *) searchPredicateForText:(nonnull NSString *)searchText;

@end
