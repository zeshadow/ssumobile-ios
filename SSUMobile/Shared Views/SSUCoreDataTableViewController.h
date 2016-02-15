//
//  SSUCoreDataTableViewController.h
//  SSUMobile
//
//  Created by Eric Amorde on 9/6/15.
//  Copyright (c) 2015 Computer Science. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSUCoreDataTableViewController : UITableViewController

@property (nonatomic, strong) NSFetchedResultsController * fetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController * searchFetchedResultsController;

- (void) performFetch;
- (void) performSearchFetch;

- (void) filterContentForSearchText:(NSString *)searchText;

@end
