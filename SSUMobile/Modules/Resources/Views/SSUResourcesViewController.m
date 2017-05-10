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
    [self makeSearchFetchedResultsController];// Zeyad added
    
    self.tableView.separatorColor = SSU_BLUE_COLOR;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.searchKey = @"name";//zeyad added
    
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

    NSArray * sortDescriptors = @[
                                  [NSSortDescriptor sortDescriptorWithKey:@"section.id" ascending:YES],
                                  [NSSortDescriptor sortDescriptorWithKey:@"section.name" ascending:YES],
                                  [NSSortDescriptor sortDescriptorWithKey:@"section.position" ascending:YES]
                                  ];
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:SSUResourcesEntityResource];
    fetchRequest.sortDescriptors = sortDescriptors; //Zeyad
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:self.context
                                                                          sectionNameKeyPath:@"section.position"
                                                                                   cacheName:nil];
 
    SSULogDebug(@"Fetch Results Controller: %@",  self.fetchedResultsController.sectionNameKeyPath);

    
}




-(void) makeSearchFetchedResultsController{
    //Made By Zeyad
    
    NSArray * sortDescriptors = @[
                                  [NSSortDescriptor sortDescriptorWithKey:@"section.id" ascending:YES],
                                  [NSSortDescriptor sortDescriptorWithKey:@"section.name" ascending:YES],
                                  [NSSortDescriptor sortDescriptorWithKey:@"section.position" ascending:YES]                                  ];
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:SSUResourcesEntityResource];

    request.sortDescriptors = sortDescriptors;
    request.includesPendingChanges = NO;
    

    
    SSULogDebug(@"Search Fetch Results Controller: %@",  self.searchFetchedResultsController);
    
    SSULogDebug(@"SSUResourcesEntitySection: %@",SSUResourcesEntitySection);

    //*
    self.searchFetchedResultsController =[[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                             managedObjectContext:self.context
                                                                               sectionNameKeyPath:@"section.position" 
                                                                                        cacheName:nil];
    self.searchFetchedResultsController.delegate =self;
    [self.searchFetchedResultsController performFetch:nil];

     // */
     
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //zeyad modified
    if(self.isSearching){
        return [[self.searchFetchedResultsController sections] count];
        
    }else{
        return [[self.fetchedResultsController sections] count];
        
    }
    
    
    //return [[self.fetchedResultsController sections] count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //zeyad modified
    if(self.isSearching){
        return [self.searchFetchedResultsController.sections[section] numberOfObjects];

    }else{
        return [self.fetchedResultsController.sections[section] numberOfObjects];

    }
        
    
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    //zeyad modified
    id<NSFetchedResultsSectionInfo> info;
    if(self.isSearching){
        info = self.searchFetchedResultsController.sections[section];
    }else{
        info = self.fetchedResultsController.sections[section];
    
    }
    //id<NSFetchedResultsSectionInfo> info= self.fetchedResultsController.sections[section];
    SSUResourcesEntry * firstResource = [[info objects] objectAtIndex:0];
    return [firstResource.section name];
}



- (SSUResourcesEntry *) objectAtIndex:(NSIndexPath *)indexPath {
    //Zeyad added
    //on second call, this errors after a search
    //at this index, there is no value.
    if(self.isSearching) {
        return [self.searchFetchedResultsController objectAtIndexPath:indexPath];
    } else {
        return [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /* zeyad
 
     
     
     */
    
    //zeyad added, might not need
   // SSUResourcesEntry *object = [self objectAtIndex:indexPath];
   // NSString *cellIndentifier = object.entity.name;

    
    SSUResourcesEntry * resource = [self objectAtIndex:indexPath];
    SSUResourcesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.titleLabel.text = resource.name;
    
    
    cell.phoneLabel.textColor = SSU_BLUE_COLOR;
    cell.phoneLabel.text = resource.phone;
    cell.urlLabel.text = [[resource.url stringByReplacingOccurrencesOfString:@"http://" withString:@""]
                                        stringByReplacingOccurrencesOfString:@"www." withString:@""];
    
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //zeyad this function is in booth resources and directory
    
    
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
