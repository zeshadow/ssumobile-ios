//
//  SSUDepartmentViewController.m
//  SSUMobile
//
//  Created by Andrew Huss on 1/30/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUDepartmentViewController.h"
#import "SSUDirectoryConstants.h"
#import "SSUDirectoryViewController.h"
#import "RBStoryboardLink.h"
#import "SSUOutdoorMapSuperViewController.h"
#import "SSULogging.h"
#import "SSUMobile-Swift.h"

typedef NS_ENUM(NSInteger, KTableViewSection) {
    kTableViewSectionName = 0,
    kTableViewSectionContact,
    kTableViewSectionLocation,
    kTableViewSectionAdmin,
    kTableViewSectionPerson,
    kTableViewSectionCount
};

typedef NS_ENUM(NSInteger, kSectionNameRow) {
    kSectionNameRowName = 0,
    kSectionNameRowCount
};

typedef NS_ENUM(NSInteger, kSectionContactRow) {
    kSectionContactRowPhone = 0,
    kSectionContactRowWebsite,
    kSectionContactRowEmail,
    kSectionContactRowCount
};

typedef NS_ENUM(NSInteger, kSectionInfoRow) {
    kSectionInfoRowPhone = 0,
    kSectionInfoRowCount
};

typedef NS_ENUM(NSInteger, kSectionLocationRow) {
    kSectionLocationRowName = 0,
    kSectionLocationRowViewOnMap,
    kSectionLocationRowCount
};

typedef NS_ENUM(NSInteger, kSectionAdminRow) {
    kSectionAdminRowChair = 0,
    kSectionAdminRowAC,
    kSectionAdminRowSchool,
    kSectionAdminRowCount,
};

@interface SSUDepartmentViewController ()

@property (nonatomic) NSArray * people;
@property (nonatomic) SSUDepartment * department;
@property (nonatomic) NSManagedObjectContext * context;

@end

@implementation SSUDepartmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.context = [[SSUMapModule sharedInstance] context];
}

- (void) updateObject {
    [super updateObject];
    self.department = (SSUDepartment *)self.object;
    NSSortDescriptor * descriptor = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    self.people = [self.department.people sortedArrayUsingDescriptors:@[descriptor]];
    SSULogDebug(@"%@",self.department);
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return kTableViewSectionCount;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([self tableView:tableView titleForHeaderInSection:section] &&
        section == kTableViewSectionLocation && self.department.building) {
        return UITableViewAutomaticDimension;
    }
    return 1;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == kTableViewSectionPerson && self.people.count > 0)
        return @"All Employees";
    else if (section == kTableViewSectionLocation && self.department.building != nil)
        return @"Location";
    else return nil;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case kTableViewSectionName:     return kSectionNameRowCount;
        case kTableViewSectionContact:  return kSectionContactRowCount;
        case kTableViewSectionLocation: return kSectionLocationRowCount;
        case kTableViewSectionAdmin:    return kSectionAdminRowCount;
        case kTableViewSectionPerson:   return self.people.count;
        default: return 0;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self unhideCellAtIndexPath:indexPath];
    UITableViewCell * cell;
    switch (indexPath.section) {
        case kTableViewSectionName: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Name"];
            cell.textLabel.text = self.department.displayName;
            break;
        }
        case kTableViewSectionContact: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Contact"];
            if (indexPath.row == kSectionContactRowPhone) {
                // Phone
                cell.textLabel.text = self.department.phone;
                cell.detailTextLabel.text = @"Phone";
                if (SSUIsEmptyString(self.department.phone)) {
                    [self hideCellAtIndexPath:indexPath];
                }
            }
            else if (indexPath.row == kSectionContactRowWebsite) {
                // Site
                cell.detailTextLabel.text = @"Website";
                cell.textLabel.text = self.department.site;
                if (SSUIsEmptyString(self.department.site)) {
                    [self hideCellAtIndexPath:indexPath];
                }
            }
            else if (indexPath.row == kSectionContactRowEmail) {
                cell.detailTextLabel.text = @"Email";
                cell.textLabel.text = self.department.email;
                if (SSUIsEmptyString(self.department.email)) {
                    [self hideCellAtIndexPath:indexPath];
                }
            }
            break;
        }
        case kTableViewSectionLocation: {
            if (indexPath.row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:SSUDirectoryEntityBuilding];
                cell.textLabel.text = self.department.building.displayName;
                if (!SSUIsEmptyString(self.department.office)) {
                    NSString * office = [[NSString stringWithFormat:@" - Room %@",self.department.office]
                                         stringByReplacingOccurrencesOfString:self.department.building.name withString:@""];
                    cell.textLabel.text = [cell.textLabel.text stringByAppendingString:office];
                }
                if (!self.department.building) {
                    [self hideCellAtIndexPath:indexPath];
                }
            } else if (indexPath.row == 1) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"Location"];
                if (!self.department.building) {
                    [self hideCellAtIndexPath:indexPath];
                }
            }
            break;
        }
        case kTableViewSectionAdmin: {
            if (indexPath.row == kSectionAdminRowChair) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"Chair"];
                cell.textLabel.text = self.department.chair.displayName;
                if (!self.department.chair) {
                    [self hideCellAtIndexPath:indexPath];
                }
            } else if (indexPath.row == kSectionAdminRowAC) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"AC"];
                cell.textLabel.text = self.department.ac.displayName;
                if (!self.department.ac) {
                    [self hideCellAtIndexPath:indexPath];
                }
                
            } else if (indexPath.row == kSectionAdminRowSchool) {
                cell = [tableView dequeueReusableCellWithIdentifier:SSUDirectoryEntitySchool];
                cell.textLabel.text = self.department.school.displayName;
                if (!self.department.school) {
                    [self hideCellAtIndexPath:indexPath];
                }
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case kTableViewSectionPerson: {
            SSUPerson * person = [self.people objectAtIndex:indexPath.row];
            cell = [tableView dequeueReusableCellWithIdentifier:SSUDirectoryEntityPerson];
            cell.textLabel.text = person.displayName;
            cell.detailTextLabel.text = person.title;
            break;
        }
        default: {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            break;
        }
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedObject = nil;
    if (indexPath.section == kTableViewSectionPerson) {
        self.selectedObject = [self.people objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == kTableViewSectionAdmin) {
        switch (indexPath.row) {
            case kSectionAdminRowAC: self.selectedObject = self.department.ac; break;
            case kSectionAdminRowChair: self.selectedObject = self.department.chair; break;
            case kSectionAdminRowSchool: self.selectedObject = self.department.school; break;
            default: break;
        }
    }
    else if (indexPath.section == kTableViewSectionLocation &&
             indexPath.row == kSectionLocationRowViewOnMap &&
             self.department.building != nil) {
        if ([self.delegate respondsToSelector:@selector(detailTableView:requestedMapDisplayForObject:)])
            [self.delegate detailTableView:self requestedMapDisplayForObject:self.department.building];
        else
            [self performSegueWithIdentifier:@"Location" sender:self];
        return;
    }
    else if (indexPath.section == kTableViewSectionContact) {
        if (indexPath.row == kSectionContactRowPhone) {
            [self confirmCallPhoneNumber];
        }
        else if (indexPath.row == kSectionContactRowWebsite) {
            [self confirmNavigateToWebsite];
        }
        else if (indexPath.row == kSectionContactRowEmail) {
            [self confirmShowEmailComposer];
        }
        return;
    }
    
    [self showDetailForObject:self.selectedObject animated:YES];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Location"]) {
        SSUOutdoorMapSuperViewController * vc = segue.destinationViewController;
        [vc loadObject:self.department.building inContext:self.context];
    }
}

- (void) callPhoneNumber {
    NSString * tel = [NSString stringWithFormat:@"tel://%@",self.department.phone];
    NSURL * url = [NSURL URLWithString:tel];
    [[UIApplication sharedApplication] openURL:url];
}

- (void) navigateToWebsite {
    NSString * urlString = self.department.site;
    if ([urlString rangeOfString:@"http"].location != 0) {
        urlString = [@"http://" stringByAppendingString:urlString];
    }
    NSURL * url = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
}

- (void) showEmailComposer {
    NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", [self.department.email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]];
    if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        [[UIApplication sharedApplication] openURL: URL];
    }
    else {
        SSULogDebug(@"Cannot open URL: %@", URL.absoluteString);
    }
}

@end
