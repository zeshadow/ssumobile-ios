//
//  SSUCoreDataTableViewController.h
//  SSUMobile
//
//  Created by Eric Amorde on 9/6/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

@import UIKit;
@import CoreData;

#import "SSUSearchableTableViewController.h"

@interface SSUCoreDataTableViewController : SSUSearchableTableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, nullable, strong) NSFetchedResultsController * fetchedResultsController;
@property (nonatomic, nullable, strong) NSFetchedResultsController * searchFetchedResultsController;


- (void) performFetch;
- (void) performSearchFetch;

@end
