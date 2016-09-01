//
//  SSUCoreDataTableViewController.h
//  SSUMobile
//
//  Created by Eric Amorde on 9/6/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

@import UIKit;
@import CoreData;

@interface SSUCoreDataTableViewController : UITableViewController

@property (nonatomic, strong) NSFetchedResultsController * fetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController * searchFetchedResultsController;

/**
 The key used in the predicate for text searches.
 
 Default: term
 */
@property (nonatomic, strong) NSString * searchKey;

/**
 The table view that will be used to show search results
 */
@property (nonatomic, weak) UITableView * searchTableView;

/**
 Will be YES if currently searching
 */
@property (nonatomic) BOOL isSearching;

- (void) performFetch;
- (void) performSearchFetch;

- (void) filterContentForSearchText:(NSString *)searchText;

@end
