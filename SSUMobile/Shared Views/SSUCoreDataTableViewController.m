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
    
    [self.fetchedResultsController performFetch:nil];
    [self.searchFetchedResultsController performFetch:nil];

    self.fetchedResultsController.delegate = self;
    self.searchFetchedResultsController.delegate = self;
}

- (void) setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
    _fetchedResultsController = fetchedResultsController;
    
    _fetchedResultsController.delegate = self;
    [self performFetch];
}

- (void) setSearchFetchedResultsController:(NSFetchedResultsController *)searchFetchedResultsController {
    _searchFetchedResultsController = searchFetchedResultsController;
    
    [self performSearchFetch];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
        return self.fetchedResultsController.sections.count;
    }
    else {
        return self.searchFetchedResultsController.sections.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSFetchedResultsController * controller = (tableView == self.tableView) ? self.fetchedResultsController : self.searchFetchedResultsController;
    return [controller.sections[section] numberOfObjects];
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
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"term CONTAINS[cd] %@", searchText];
    [self performSearchFetch];
}

#pragma mark - NSFetchedResultsController Updates

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id )sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove: break;
        case NSFetchedResultsChangeUpdate: break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


@end
