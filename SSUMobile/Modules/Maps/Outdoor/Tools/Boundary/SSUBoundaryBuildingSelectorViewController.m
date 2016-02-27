//
//  SSUBoundryBuildingSelectorViewController.m
//  SSUMobile
//
//  Created by Andrew Huss on 4/14/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUBoundaryBuildingSelectorViewController.h"
#import "SSUDirectoryConstants.h"
#import "SSUDirectoryModule.h"
#import "SSULogging.h"

@interface SSUBoundaryBuildingSelectorViewController ()

@property (strong, nonatomic) NSFetchedResultsController * fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext * context;

@end

@implementation SSUBoundaryBuildingSelectorViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.context = [[SSUDirectoryModule sharedInstance] context];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // used for debugging: show all building ids in the console
        for (SSUBuilding *building in self.fetchedResultsController.fetchedObjects) {
            SSULogDebug(@"Building %@, id: %@", building.name, building.id);
        }
    });
    
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    SSUBuilding* building = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = building.name;
    
    if ([_definedBuildingIDs containsObject:building.id]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:SSUDirectoryEntityBuilding inManagedObjectContext:self.context];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    [fetchRequest setIncludesPendingChanges:NO];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Handle error
        SSULogError(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate boundaryBuildingSelector:self didSelectBuilding:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
