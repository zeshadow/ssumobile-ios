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
    [self setupCoreData];
    
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
    NSArray * sortDescriptors = @[
                                  [NSSortDescriptor sortDescriptorWithKey:@"section.position" ascending:YES],
                                  [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES],
                                  ];
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:SSUResourcesEntityResource];
    fetchRequest.sortDescriptors = sortDescriptors;
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:self.context
                                                                          sectionNameKeyPath:@"section.position"
                                                                                   cacheName:nil];
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
