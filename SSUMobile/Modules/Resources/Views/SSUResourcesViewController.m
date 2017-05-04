//
//  SSUResourcesViewController.m
//  SSUMobile
//
//  Created by Eric Amorde on 10/5/14.
//  Copyright (c) 2014 Sonoma State University Department of Computer Science. All rights reserved.
//

@import CoreData;

#import "SSUResourcesViewController.h"
#import "SSUResourcesCell.h"
#import "SSUResourcesConstants.h"
#import "SSUResourcesEntry.h"
#import "SSUResourcesSection.h"
#import "SSUMobile-Swift.h"

@interface SSUResourcesViewController () <UIActionSheetDelegate,NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSArray * sectionInfo;
@property (nonatomic, strong) NSIndexPath * selectedIndexPath;
@property (nonatomic, strong) NSManagedObjectContext * context;

@end

@implementation SSUResourcesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.context = [[SSUResourcesModule sharedInstance] context];
    [self setupCoreData]; // see below
    //[self makeSearchFetchedResultsController];// Zeyad added
    
    self.tableView.separatorColor = SSU_BLUE_COLOR;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void) refresh {    
    [[SSUResourcesModule sharedInstance] updateData:^{
        [self.refreshControl endRefreshing];
    }];
}

- (void) setupCoreData {
    //Zeyad
    //on startup contents of FetchRequest
    /*
     <NSFetchRequest: 0x6180002c3410> (entity: SSUResourcesEntry; predicate: ((null)); sortDescriptors: ((null)); type: NSManagedObjectResultType; )

     
     when you search, there is no fetch request,  it needs to be of entity SSUReasourcesEntry
     might need to build a new fetch request to pass to the search. I need to find out where it happens in directory and do it for Resources    
     
     
     
     */
    NSArray * sortDescriptors = @[
                                  [NSSortDescriptor sortDescriptorWithKey:@"section.position" ascending:YES],
                                  [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES],
                                  ];
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:SSUResourcesEntityResource];
    fetchRequest.sortDescriptors = sortDescriptors; //Zeyad
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:self.context
                                                                          sectionNameKeyPath:@"section.position"
                                                                                   cacheName:nil];
 
    NSLog(@"Fetch Results Controller: %@",  self.fetchedResultsController);

    
}




-(void) makeSearchFetchedResultsController{
    //Made By Zeyad
    //currently commented out in viewDidLoad()
    
    NSArray * sortDescriptors = @[
                                  [NSSortDescriptor sortDescriptorWithKey:@"section.position" ascending:YES],
                                  [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES],
                                  ];
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:SSUResourcesEntitySection];
    request.sortDescriptors = sortDescriptors;
    request.includesPendingChanges = NO;
    
    //there is an uncaught exeption found here
    /*
     *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: 'keypath section.position not found in entity <NSSQLEntity SSUResourcesSection id=2>'
     *** First throw call stack:
     
     */
    
    NSLog(@"Search Fetch Results Controller: %@",  self.searchFetchedResultsController);

    self.searchFetchedResultsController =[[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                             managedObjectContext:self.context
                                                                               sectionNameKeyPath:@"section.position" //uncaught expection
                                                                                        cacheName:nil];
    self.searchFetchedResultsController.delegate =self;
    [self.searchFetchedResultsController performFetch:nil];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fetchedResultsController.sections[section] numberOfObjects];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> info = self.fetchedResultsController.sections[section];
    SSUResourcesEntry * firstResource = [[info objects] objectAtIndex:0];
    return [firstResource.section name];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSUResourcesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    SSUResourcesEntry * resource = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.titleLabel.text = resource.name;
    
    
    cell.phoneLabel.textColor = SSU_BLUE_COLOR;
    cell.phoneLabel.text = resource.phone;
    cell.urlLabel.text = [[resource.url stringByReplacingOccurrencesOfString:@"http://" withString:@""]
                                        stringByReplacingOccurrencesOfString:@"www." withString:@""];
    
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SSUResourcesEntry * resource = [self.fetchedResultsController objectAtIndexPath:indexPath];
    self.selectedIndexPath = indexPath;
    UIActionSheet * actionSheet = nil;
    if (resource.phone && resource.url) {
        // Both phone and url
        NSString * phoneTitle = [NSString stringWithFormat:@"Call %@",resource.phone];
        NSString * urlTitle = @"Open in Safari";
        actionSheet = [[UIActionSheet alloc] initWithTitle:resource.name
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:phoneTitle,urlTitle, nil];
    }
    else if (resource.phone && !resource.url) {
        // Phone only
        NSString * phoneTitle = [NSString stringWithFormat:@"Call %@",resource.phone];
        actionSheet = [[UIActionSheet alloc] initWithTitle:resource.name
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:phoneTitle, nil];
    }
    else if (resource.url && !resource.phone) {
        // URL only
        NSString * urlTitle = @"Open in Safari";
        actionSheet = [[UIActionSheet alloc] initWithTitle:resource.name
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:urlTitle, nil];
    }
    else {
        // Contains neither phone nor URL
        return;
    }
    [actionSheet showInView:self.tableView];
}

- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString * title = [actionSheet buttonTitleAtIndex:buttonIndex];
    SSUResourcesEntry * resource = [self.fetchedResultsController objectAtIndexPath:self.selectedIndexPath];
    NSURL * url = nil;
    if ([title isEqualToString:@"Open in Safari"]) {
        url = [NSURL URLWithString:resource.url];
    }
    else if ([title containsString:@"Call"]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",resource.phone]];
    }
    if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}


@end
