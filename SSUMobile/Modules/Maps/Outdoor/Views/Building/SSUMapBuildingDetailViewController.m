//
//  SSUMapBuildingDetailViewController.m
//  SSUMobile
//
//  Created by Eric Amorde on 9/30/15.
//  Copyright © 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUMapBuildingDetailViewController.h"

#import "SSULogging.h"

#import "SSUDirectoryViewController.h"
#import "SSUDepartmentViewController.h"
#import "SSUBuildingViewController.h"

#import "SSUMapModels.h"
#import "SSUMapBuilder.h"
#import "SSUBuildingMapViewCell.h"
#import "SSUDepartmentTableViewCell.h"

#import "SSUTableHeaderView.h"

#import "SSUMobile-Swift.h"

@import MapKit;

static NSString * const StoryboardName = @"Map_Building";
static NSString * const SegueIdentifierDepartment = @"Department";
static NSString * const SegueIdentifierBuilding = @"Building";

typedef NS_ENUM(NSInteger, TableSection) {
    TableSectionHeader = 0,
    TableSectionDepartments,
    TableSectionCount
};

typedef NS_ENUM(NSInteger, SectionHeaderRow) {
    SectionHeaderRowHeader = 0,
    SectionHeaderRowDirections,
    SectionHeaderRowViewInDirectory,
    SectionHeaderRowCount,
};

static CGFloat kRowHeightHeader = 230;
static CGFloat kRowHeightNormal = 44;

@interface SSUMapBuildingDetailViewController () <MKMapViewDelegate>

@property (nonatomic) SSUMapBuildingPerimeter * buildingPerimeter;
@property (nonatomic) NSArray * departments;

@end

@implementation SSUMapBuildingDetailViewController

+ (instancetype) instantiateFromStoryboard {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:StoryboardName
                                                          bundle:[NSBundle bundleForClass:[self class]]];
    return [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[SSUTableHeaderView class] forHeaderFooterViewReuseIdentifier:@"Header"];
    UIBarButtonItem * backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_down"] style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPressed:)];
    backButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void) backButtonPressed:(UIBarButtonItem *)button {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void) setBuilding:(SSUBuilding *)building {
    _building = building;
    self.departments = [self.building.departments sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES]]];
    NSManagedObjectContext * context = [[SSUMapModule sharedInstance] context];
    self.buildingPerimeter = [SSUMapBuilder perimeterForBuilding:_building inContext:context];
}

- (void) setBuildingPerimeter:(SSUMapBuildingPerimeter *)buildingPerimeter {
    _buildingPerimeter = buildingPerimeter;
}


#pragma mark - UITableView

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == TableSectionDepartments && [self tableView:tableView numberOfRowsInSection:section] == 0) {
        return nil;
    }
    SSUTableHeaderView * header = (id)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Header"];
    header.headerTextLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    return header;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == TableSectionHeader) {
        return SectionHeaderRowCount;
    }
    else if (section == TableSectionDepartments) {
        return self.departments.count;
    }
    
    return 0;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return TableSectionCount;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = nil;
    if (indexPath.section == TableSectionHeader) {
        if (indexPath.row == SectionHeaderRowHeader) {
            SSUBuildingMapViewCell * buildingCell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell" forIndexPath:indexPath];
            buildingCell.building = self.building;
            cell = buildingCell;
        }
        else if (indexPath.row == SectionHeaderRowDirections) {
            return [tableView dequeueReusableCellWithIdentifier:@"DirectionsCell"];
        }
        else if (indexPath.row == SectionHeaderRowViewInDirectory) {
            return [tableView dequeueReusableCellWithIdentifier:@"DirectoryCell"];
        }
    }
    else if (indexPath.section == TableSectionDepartments) {
        SSUDepartmentTableViewCell * departmentCell = [tableView dequeueReusableCellWithIdentifier:@"DepartmentCell" forIndexPath:indexPath];
        departmentCell.directoryEntry = self.departments[indexPath.row];
        cell = departmentCell;
    }
    
    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == TableSectionDepartments) {
        if ([self tableView:tableView numberOfRowsInSection:section] == 0) {
            return nil;
        }
        return [NSString stringWithFormat:@"Departments in %@",self.building.displayName];
    }
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TableSectionHeader && indexPath.row == SectionHeaderRowHeader) {
        return kRowHeightHeader;
    }
    else {
        return kRowHeightNormal;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == TableSectionDepartments) {
        [self performSegueWithIdentifier:SegueIdentifierDepartment sender:self.departments[indexPath.row]];
    }
    else if (indexPath.section == TableSectionHeader) {
        if(indexPath.row == SectionHeaderRowDirections) {
            // Directions
            if (![self.delegate userLocationAvailable]) {
                [self notifyUserLocationUnavailable];
            }
            [self.delegate mapBuildingDetailRequestedDirections:self];
        }
        else if (indexPath.row == SectionHeaderRowViewInDirectory) {
            // View this building in the campus directory
            [self performSegueWithIdentifier:SegueIdentifierBuilding sender:self];
        }
    }
}

#pragma mark - Helper

- (void) notifyUserLocationUnavailable {
    [[[UIAlertView alloc] initWithTitle:@"Device location unavailable"
                                message:@"We can't find your location right now. It's possible you have turned off Location Services for SSUMobile or that your device does not currently have location available"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
    //TODO: Put the logic for this in one place so multiple areas in the map can use it
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"directory"]) {
        SSUDirectoryViewController * controller = (SSUDirectoryViewController *)segue.destinationViewController;
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"building = %@",self.building];
        controller.defaultPredicate = predicate;
        controller.entities = @[SSUDirectoryEntityPerson,SSUDirectoryEntityDepartment, SSUDirectoryEntitySchool];
        [controller loadEntityName:SSUDirectoryEntityDepartment usingPredicate:nil];
    }
    else if ([segue.identifier isEqualToString:SegueIdentifierDepartment]) {
        SSUDepartmentViewController * controller = (id)segue.destinationViewController;
        [controller loadObject:sender inContext:[sender managedObjectContext]];
    }
    else if ([segue.identifier isEqualToString:SegueIdentifierBuilding]) {
        SSUBuildingViewController * controller = (id)segue.destinationViewController;
        [controller loadObject:self.building inContext:self.building.managedObjectContext];
    }
    else {
        SSULogDebug(@"Unrecognized segue: %@", segue);
    }
}


@end
