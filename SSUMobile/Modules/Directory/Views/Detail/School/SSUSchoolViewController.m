//
//  SSUSchoolViewController.m
//  SSUMobile
//
//  Created by Eric Amorde on 2/26/14.
//  Copyright (c) 2014 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUSchoolViewController.h"
#import "SSUDirectoryViewController.h"

typedef NS_ENUM(NSInteger, TableViewSection) {
    TableViewSectionName,
    TableViewSectionInfo,
    TableViewSectionLocation,
    TableViewSectionDepartment,
    TableViewSectionCount
};

@interface SSUSchoolViewController ()

@property (weak, nonatomic) SSUSchool* school;
@property (nonatomic) NSArray * departments;

@end

@implementation SSUSchoolViewController

static const int INFO_ROWS = 3;

- (void) updateObject {
    self.school = (SSUSchool*)[self object];
    self.title = @"Contact Info";
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"term" ascending:YES];
    self.departments = [self.school.departments sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == TableViewSectionDepartment && self.school.departments.count > 0)
        return SSUDirectoryCategoryDepartments;
    else if (section == TableViewSectionLocation && self.school.building)
        return @"Building";
    else return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 10;
    else return 25;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case TableViewSectionName:
            return 1; break;
        case TableViewSectionLocation:
            return 1; break;
        case TableViewSectionInfo:
            return INFO_ROWS; break;
        case TableViewSectionDepartment:
            return self.departments.count; break;
        default:
            return 0;
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return TableViewSectionCount;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    [self unhideCellAtIndexPath:indexPath];
    if (indexPath.section == TableViewSectionName)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Name"];
        cell.textLabel.text = self.school.displayName;
    }
    else if (indexPath.section == TableViewSectionLocation)
    {
        if (indexPath.row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:SSUDirectoryEntityBuilding];
            cell.textLabel.text = self.school.building.displayName;
            if (!self.school.building) {
                [self hideCellAtIndexPath:indexPath];
            }
        }
    }
    else if (indexPath.section == TableViewSectionInfo)
    {
        SSUPerson * person = nil;
        if (indexPath.row == 0) {
            // Dean
            person = self.school.dean;
        }
        else if (indexPath.row == 1) {
            // Assistant
            person = self.school.assistant;
        }
        else if (indexPath.row == 2) {
            // Administrative Manager
            person = self.school.admin;
        }

        if (!person) {
            [self hideCellAtIndexPath:indexPath];
        }
        
        cell = [tableView dequeueReusableCellWithIdentifier:SSUDirectoryEntityPerson];
        cell.textLabel.text = (!SSUIsEmptyString(person.displayName)) ? (person.displayName) : UNKNOWN_VALUE;
        cell.detailTextLabel.text = (!SSUIsEmptyString(person.title)) ? (person.title) : UNKNOWN_VALUE;
    }
    else if (indexPath.section == TableViewSectionDepartment)
    {
        SSUDepartment * department = [self.departments objectAtIndex:indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:SSUDirectoryEntityDepartment];
        cell.textLabel.text = department.displayName;
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedObject = nil;
    UITableViewCell * selectedCell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([selectedCell.reuseIdentifier isEqualToString:SSUDirectoryEntityPerson]) {
        if (indexPath.row == 0)
        {
            self.selectedObject = self.school.dean;
        }
        else if (indexPath.row == 1)
        {
            self.selectedObject = self.school.assistant;
        }
        else if (indexPath.row == 2)
        {
            self.selectedObject = self.school.admin;
        }
    }
    else if ([selectedCell.reuseIdentifier isEqualToString:SSUDirectoryEntityDepartment]) {
        self.selectedObject = [self.departments objectAtIndex:indexPath.row];
    }
    else if ([selectedCell.reuseIdentifier isEqualToString:SSUDirectoryEntityBuilding]) {
        self.selectedObject = self.school.building;
    }
    else if ([selectedCell.reuseIdentifier isEqualToString:@"Location"] && self.school.building != nil) {
        if ([self.delegate respondsToSelector:@selector(detailTableView:requestedMapDisplayForObject:)])
            [self.delegate detailTableView:self requestedMapDisplayForObject:self.school.building];
        else
            [self performSegueWithIdentifier:@"Location" sender:self];
    }
    
    [self showDetailForObject:self.selectedObject animated:YES];
}

@end
