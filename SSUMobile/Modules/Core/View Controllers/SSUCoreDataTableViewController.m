//
//  SSUCoreDataTableViewController.m
//  SSUMobile
//
//  Created by Eric Amorde on 9/6/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUCoreDataTableViewController.h"
#import "SSULogging.h"

@interface SSUCoreDataTableViewController () <NSFetchedResultsControllerDelegate>

@end

@implementation SSUCoreDataTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
    _fetchedResultsController = fetchedResultsController;
    _fetchedResultsController.delegate = self;
    [self performFetch];
}

- (void) setSearchFetchedResultsController:(NSFetchedResultsController *)searchFetchedResultsController {
    _searchFetchedResultsController = searchFetchedResultsController;
    _searchFetchedResultsController.delegate = self;
    [self performSearchFetch];
}

- (NSFetchedResultsController *) currentFetchedResultsController {
    if (self.isSearching) {
        if (self.searchFetchedResultsController == nil) {
            SSULogError(@"isSearching == YES but no value has been set for self.searchFetchedResultsController");
        } else {
            return self.searchFetchedResultsController;
        }
    }
    return self.fetchedResultsController;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.currentFetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSFetchedResultsController * controller = self.currentFetchedResultsController;
    return [controller.sections[section] numberOfObjects];
}

- (NSManagedObject *) objectAtIndex:(NSIndexPath *)indexPath {
    return [self.currentFetchedResultsController objectAtIndexPath:indexPath];
}

#pragma mark - Fetch

- (void) performFetch {
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        SSULogError(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

- (void) performSearchFetch {
    NSError * error = nil;
    if (![self.searchFetchedResultsController performFetch:&error]){
        SSULogError(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

#pragma mark - Search

- (void) filterContentForSearchText:(NSString*)searchText {
    NSFetchRequest *fetchRequest = self.searchFetchedResultsController.fetchRequest;
    fetchRequest.predicate = [self searchPredicateForText:searchText];
    [self performSearchFetch];
    [self.tableView reloadData];
}

#pragma mark - NSFetchedResultsController Updates

- (UITableView *) tableViewForController:(NSFetchedResultsController *)controller {
    return self.tableView;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    //TODO: Fix this functionality or change it so we can animate changes correctly
//    [[self tableViewForController:controller] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    return;
    UITableView *tableView = [self tableViewForController:controller];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id )sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    return;
    UITableView * tableView = [self tableViewForController:controller];
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeMove: break;
        case NSFetchedResultsChangeUpdate: break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [[self tableViewForController:controller] reloadData];
//    [[self tableViewForController:controller] endUpdates];
}


@end
