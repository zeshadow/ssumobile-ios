//
//  SSUBuildingViewController.m
//  SSUMobile
//
//  Created by Andrew Huss on 1/30/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUBuildingViewController.h"
#import "SSUDirectoryConstants.h"
#import "SSUDirectoryModels.h"
#import "SSUDirectoryViewController.h"
#import "SSUPersonViewController.h"
#import "SSUDepartmentViewController.h"
#import "RBStoryboardLink.h"
#import "SSUOutdoorMapSuperViewController.h"
#import "SSULogging.h"
#import "SSUMobile-Swift.h"


typedef NS_ENUM(NSInteger, TableViewSection) {
    TableViewSectionName = 0,
    TableViewSectionLocation,
    TableViewSectionDepartment,
    TableViewSectionPerson,
    TableViewSectionCount
};

@interface SSUBuildingViewController ()
    
@property (nonatomic) SSUBuilding * building;
@property (nonatomic) NSArray * departments;
@property (nonatomic) NSArray * people;
@property (nonatomic) NSArray * schools;
@property (nonatomic) NSManagedObjectContext * context;

@end

@implementation SSUBuildingViewController

- (void) updateObject {
    [super updateObject];
    self.context = [[SSUMapModule sharedInstance] context];
    self.building = (SSUBuilding*)[self object];
    NSSortDescriptor * descriptor = [NSSortDescriptor sortDescriptorWithKey:@"term" ascending:YES];
    self.departments = [self.building.departments sortedArrayUsingDescriptors:@[descriptor]];
    self.people = [self.building.people sortedArrayUsingDescriptors:@[descriptor]];
    self.schools = [self.building.schools sortedArrayUsingDescriptors:@[descriptor]];
    
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return TableViewSectionCount;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch ((TableViewSection)section) {
        case TableViewSectionName:
            return 1;
        case TableViewSectionLocation:
            return 1;
        case TableViewSectionDepartment:
            return self.departments.count;
        case TableViewSectionPerson:
            return self.people.count;
        case TableViewSectionCount:
            return 0;
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == TableViewSectionName || section == TableViewSectionLocation)
        return nil;
    else if (section == TableViewSectionDepartment && self.departments.count > 0)
        return SSUDirectoryCategoryDepartments;
    else if (section == TableViewSectionPerson && self.people.count > 0)
        return SSUDirectoryCategoryPeople;
    else return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    UITableViewCell * cell;
    [self unhideCellAtIndexPath:indexPath];
    if (section == TableViewSectionName) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Name"];
        cell.textLabel.text = [self.object valueForKey:@"displayName"];
    }
    else if (section == TableViewSectionLocation) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Location"];
        if (![SSUOutdoorMapSuperViewController canDisplayBuilding:self.building]) {
            [self hideCellAtIndexPath:indexPath];
        }
    }
    else if (section == TableViewSectionDepartment) {
        cell = [tableView dequeueReusableCellWithIdentifier:SSUDirectoryEntityDepartment];
        cell.textLabel.text = [[self.departments objectAtIndex:indexPath.row] displayName];
    }
    else if (section == TableViewSectionPerson) {
        cell = [tableView dequeueReusableCellWithIdentifier:SSUDirectoryEntityPerson];
        cell.textLabel.text = [[self.people objectAtIndex:indexPath.row] displayName];
        cell.detailTextLabel.text = [[[self.people objectAtIndex:indexPath.row] department] displayName];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedObject = nil;
    if (indexPath.section == TableViewSectionLocation) {
        if ([self.delegate respondsToSelector:@selector(detailTableView:requestedMapDisplayForObject:)])
            [self.delegate detailTableView:self requestedMapDisplayForObject:self.object];
        else
            [self performSegueWithIdentifier:@"Location" sender:self];
    }
    else if (indexPath.section == TableViewSectionDepartment) {
        self.selectedObject = [self.departments objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == TableViewSectionPerson) {
        self.selectedObject = [self.people objectAtIndex:indexPath.row];
    }
    
    [self showDetailForObject:self.selectedObject animated:YES];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Location"]) {
        SSUOutdoorMapSuperViewController* controller = (SSUOutdoorMapSuperViewController *)segue.destinationViewController;
        [controller loadObject:self.object inContext:self.context];
    }
    else {
        SSULogDebug(@"Unknown Segue: %@", segue.identifier);
    }
}

@end
