//
//  SSUEditDepartmentViewController.m
//  SSUMobile
//
//  Created by Eric Amorde on 7/8/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUEditDepartmentViewController.h"
#import "SSUDirectoryModule.h"
#import "SSUMoonlightCommunicator.h"
#import "SSUDirectoryBuilder.h"
#import "SSUSelectionController.h"
#import "SSUDepartment.h"
#import "SSUPerson.h"
#import "SSUSchool.h"
#import "SSUBuilding.h"

#import "SSULogging.h"
#import "SSUDebugCredentials.h"

#import "MBProgressHUD.h"

@interface SSUEditDepartmentViewController () <SSUSelectionDelegate>

@property (nonatomic,strong) SSUDepartment * department;
@property (nonatomic,strong) NSMutableDictionary * departmentDictionary;
@property (nonatomic,strong) NSString * selectionKey;
@property (nonatomic,strong) NSManagedObjectContext * context;

@end

@implementation SSUEditDepartmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.context = [[SSUDirectoryModule sharedInstance] context];
    [self updateUI];
    [SSUDebugCredentials requestCredentials];
}

- (NSMutableDictionary *) departmentDictionary {
    if (_departmentDictionary) return _departmentDictionary;
    
    _departmentDictionary = [NSMutableDictionary new];
    return _departmentDictionary;
}

- (void) loadObject:(NSManagedObject *)object inContext:(NSManagedObjectContext *)context {
    self.department = (id)object;
    NSArray * allKeys = @[@"id",@"name",@"displayName",@"site",@"phone",@"office",@"chair",@"ac",@"school",@"building"];
    for (NSString * key in allKeys) {
        id value = [self.department valueForKey:key];
        self.departmentDictionary[key] = (value == nil) ? [NSNull null] : value;
    }
}

- (void) updateUI {
    self.nameTextField.text = SSUTrimString(self.departmentDictionary[@"name"]);
    self.displayNameTextField.text = SSUTrimString(self.departmentDictionary[@"displayName"]);
    self.siteTextField.text = SSUTrimString(self.departmentDictionary[@"site"]);
    self.phoneTextField.text = SSUTrimString(self.departmentDictionary[@"phone"]);
    self.officeTextField.text = SSUTrimString(self.departmentDictionary[@"office"]);

    [self updateChairLabel];
    [self updateAcLabel];
    [self updateSchoolLabel];
    [self updateBuildingLabel];
    
    self.chairLabel.text = (self.departmentDictionary[@"chair"] != [NSNull null]) ? [self.departmentDictionary[@"chair"] displayName] : nil;
    self.acLabel.text = (self.departmentDictionary[@"ac"] != [NSNull null]) ? [self.departmentDictionary[@"ac"] displayName] : nil;
    self.schoolLabel.text = (self.departmentDictionary[@"school"] != [NSNull null]) ? [self.departmentDictionary[@"school"] displayName] : nil;
    self.buildingLabel.text = (self.departmentDictionary[@"building"] != [NSNull null]) ? [self.departmentDictionary[@"building"] displayName] : nil;
}

- (void) updateChairLabel {
    if (self.departmentDictionary[@"chair"] == [NSNull null]) {
        self.chairLabel.text = @"";
    } else {
        self.chairLabel.text = [self.departmentDictionary[@"chair"] displayName];
    }
}

- (void) updateAcLabel {
    if (self.departmentDictionary[@"ac"] == [NSNull null]) {
        self.acLabel.text = @"";
    } else {
        self.acLabel.text = [self.departmentDictionary[@"ac"] displayName];
    }
}

- (void) updateSchoolLabel {
    if (self.departmentDictionary[@"school"] == [NSNull null]) {
        self.schoolLabel.text = @"";
    } else {
        self.schoolLabel.text = [self.departmentDictionary[@"school"] displayName];
    }
}

- (void) updateBuildingLabel {
    if (self.departmentDictionary[@"building"] == [NSNull null]) {
        self.buildingLabel.text = @"";
    } else {
        self.buildingLabel.text = [self.departmentDictionary[@"building"] displayName];
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [NSString stringWithFormat:@"%@ - %@",self.department.name,self.department.id];
    }
    return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NSArray * options = [self selectionOptionsForIndexPath:indexPath];
        self.selectionKey = [self selectionKeyForIndexPath:indexPath];
        SSUSelectionController * selectionController = [[SSUSelectionController alloc] initWithItems:options];
        selectionController.textKey = @"displayName";
        selectionController.delegate = self;
        selectionController.selectedItem = self.departmentDictionary[self.selectionKey];
        selectionController.allowUserDismissal = YES;
        if (indexPath.row <= 1) {
           selectionController.subtitleKey = @"department.displayName";
        }
        UINavigationController * modal = [[UINavigationController alloc] initWithRootViewController:selectionController];
        [self presentViewController:modal animated:YES completion:NULL];
    }
}

- (NSArray *) selectionOptionsForIndexPath:(NSIndexPath *)indexPath {
    NSString * entityName = nil;
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: entityName = SSUDirectoryEntityPerson; break;
            case 1: entityName = SSUDirectoryEntityPerson; break;
            case 2: entityName = SSUDirectoryEntitySchool; break;
            case 3: entityName = SSUDirectoryEntityBuilding; break;
            default: return @[];
        }
    }
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"term" ascending:YES];
    return [[self.context executeFetchRequest:fetchRequest error:nil] sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (NSString *) selectionKeyForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: return @"chair";
            case 1: return @"ac";
            case 2: return @"school";
            case 3: return @"building";
            default: return nil;
        }
    }
    return nil;
}

- (NSDictionary *) departmentData {
    NSMutableDictionary * base = [self.departmentDictionary mutableCopy];
    base[@"chair_id"] = (base[@"chair"] == [NSNull null]) ? @"" : @([[self.departmentDictionary[@"chair"] id] integerValue]);
    base[@"ac_id"] = (base[@"ac"] == [NSNull null]) ? @"" : @([[self.departmentDictionary[@"ac"] id] integerValue]);
    base[@"school_id"] = (base[@"school"] == [NSNull null]) ? @"" : @([[self.departmentDictionary[@"school"] id] integerValue]);
    base[@"building_id"] = (base[@"building"] == [NSNull null]) ? @"" : @([[self.departmentDictionary[@"building"] id] integerValue]);

    return @{
             @"id" : SSUTrimString(base[@"id"]),
             @"name" : SSUTrimString(base[@"name"]),
             @"displayName" : SSUTrimString(base[@"displayName"]),
             @"site" : SSUTrimString(base[@"site"]),
             @"phone" : SSUTrimString(base[@"phone"]),
             @"office" : SSUTrimString(base[@"office"]),
             
             @"chair" : @([base[@"chair_id"] integerValue]),
             @"ac" : @([base[@"ac_id"] integerValue]),
             @"school" : @([base[@"school_id"] integerValue]),
             @"building" : @([base[@"building_id"] integerValue]),
             };
}

- (IBAction) textFieldDidChange:(UITextField *)textField {
    NSString * key = textField.placeholder;
    self.departmentDictionary[key] = textField.text;
}

- (IBAction)submitButtonPressed:(UIBarButtonItem *)sender {
    [self submit];
}

- (void) submit {
    [self.department setValuesForKeysWithDictionary:self.departmentDictionary];
    SSULogDebug(@"%@",self.department);
    NSURL * url = [NSURL URLWithString:[SSUMoonlightBaseURL stringByAppendingPathComponent:@"modifyDepartment"]];
    NSMutableDictionary * params = [[self departmentData] mutableCopy];
    params[@"key"] = [SSUDebugCredentials token];
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    [SSUMoonlightCommunicator postURL:url parameters:params completion:^(NSURLResponse * response, NSData * data, NSError * error) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = (error == nil) ? @"Success" : [error description];
        [hud hide:YES afterDelay:2.0];
        NSString * responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        SSULogDebug(@"Response: %@", responseString);
    }];
}

#pragma mark - SSUSelectionDelegate

- (void) userDidSelectItem:(id)item atIndexPath:(NSIndexPath *)indexPath fromController:(SSUSelectionController *)controller {
    self.departmentDictionary[self.selectionKey] = item;
    [self updateUI];
}

- (void) selectionControllerDismissed:(SSUSelectionController *)controller {
    [self userDidSelectItem:controller.selectedItem atIndexPath:controller.selectedIndex fromController:controller];
}


@end
