//
//  SSUPersonViewController.m
//  SSUMobile
//
//  Created by Andrew Huss on 1/30/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUPersonViewController.h"
#import "SSULogging.h"
#import "SSUDirectoryConstants.h"
#import "SSUDirectoryViewController.h"
#import "RBStoryboardLink.h"
#import "SSUOutdoorMapSuperViewController.h"

@import AddressBook;
@import AddressBookUI;

typedef NS_ENUM(NSInteger, kTableViewSection) {
    kTableViewSectionPersonInfo = 0,
    kTableViewSectionOtherInfo,
    kTableViewSectionCount
};

typedef NS_ENUM(NSInteger, kPersonInfoRow) {
    kPersonInfoRowTitle = 0,
    kPersonInfoRowPhone,
    kPersonInfoRowEmail,
    kPersonInfoRowSite,
    kPersonInfoRowCount
};

typedef NS_ENUM(NSInteger, kOtherInfoRow) {
    kOtherInfoRowDepartment = 0,
    kOtherInfoRowLocation,
    kOtherInfoRowCount,
};

@interface SSUPersonViewController () <UIAlertViewDelegate, ABUnknownPersonViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *siteLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *officeLabel;

@property (weak, nonatomic) SSUPerson* person;

@end

@implementation SSUPersonViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateObject];
}

- (void) updateObject {
    _person = (SSUPerson*)[self object];
    [self unhideAllCells];
    self.titleLabel.text = self.person.title;
    self.titleLabel.enabled = !(SSUIsEmptyString(self.titleLabel.text));
    if (!self.titleLabel.enabled) {
        [self hideCellAtIndexPath:[NSIndexPath indexPathForRow:kPersonInfoRowTitle inSection:kTableViewSectionPersonInfo]];
    }
    
    self.siteLabel.text = self.person.site;
    self.siteLabel.enabled = !(SSUIsEmptyString(self.siteLabel.text));
    if (!self.siteLabel.enabled) {
        [self hideCellAtIndexPath:[NSIndexPath indexPathForRow:kPersonInfoRowSite inSection:kTableViewSectionPersonInfo]];
    }
    
    self.phoneLabel.text = self.person.phone;
    self.phoneLabel.enabled = !(SSUIsEmptyString(self.phoneLabel.text));
    if (!self.phoneLabel.enabled) {
        [self hideCellAtIndexPath:[NSIndexPath indexPathForRow:kPersonInfoRowPhone inSection:kTableViewSectionPersonInfo]];
    }
    
    self.emailLabel.text = self.person.email;
    self.emailLabel.enabled = !(SSUIsEmptyString(self.emailLabel.text));
    if (!self.emailLabel.enabled) {
        [self hideCellAtIndexPath:[NSIndexPath indexPathForRow:kPersonInfoRowEmail inSection:kTableViewSectionPersonInfo]];
    }
    
    self.departmentLabel.text = self.person.department.displayName;
    self.departmentLabel.enabled = !(SSUIsEmptyString(self.departmentLabel.text));
    if (!self.departmentLabel.enabled) {
        [self hideCellAtIndexPath:[NSIndexPath indexPathForRow:kOtherInfoRowDepartment inSection:kTableViewSectionOtherInfo]];
    }
    
    self.officeLabel.text = [self locationText];
    self.officeLabel.enabled = !(SSUIsEmptyString(self.officeLabel.text));
    if (!self.officeLabel.enabled) {
        [self hideCellAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    }
    
    [self.tableView reloadData];
}

/**
 Returns the building name and office number combined, as long as the office value does not
 already contain the building name
 */
- (NSString *) locationText {
    NSString * building = self.person.building.displayName;
    NSString * office = self.person.office;
    if(!SSUIsEmptyString(office)) {
        if (!SSUIsEmptyString(building) &&
            ![building isEqualToString:UNKNOWN_VALUE] &&
            [office rangeOfString:building].length == 0 &&
            [office rangeOfString:self.person.building.name].length == 0) {
            return [NSString stringWithFormat:@"%@ %@",building,office];
        }
        else {
            return office;
        }
    }
    
    return building;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    self.selectedObject = nil;
    if (indexPath.section == kTableViewSectionPersonInfo && indexPath.row == kPersonInfoRowPhone) {
        [self confirmCallPhoneNumber];
    }
    else if (indexPath.section == kTableViewSectionPersonInfo && indexPath.row == kPersonInfoRowEmail) {
        [self showEmailComposer];
    }
    else if (indexPath.section == kTableViewSectionOtherInfo && indexPath.row == kOtherInfoRowDepartment) {
        self.selectedObject = self.person.department;
    }
    else if (indexPath.section == kTableViewSectionOtherInfo && indexPath.row == kOtherInfoRowLocation) {
        self.selectedObject = self.person.building;
    }
    else if ([cell.reuseIdentifier isEqualToString:@"Contacts"]) {
        [self contactForPerson:self.person];
        return;
    }
    
    [self showDetailForObject:self.selectedObject animated:YES];
}

- (void) showEmailComposer {
    NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", [self.person.email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]];
    if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        [[UIApplication sharedApplication] openURL: URL];
    }
    else {
        SSULogDebug(@"Cannot open URL: %@", URL.absoluteString);
    }
}

- (void) callPhoneNumber {
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",_person.phone]];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - Address Book Integration

/**
 Present a view controller allowing the user to create a contact for this Person.
 
 See Apple's tutorial "QuickContacts" for some info on this. The documentation is not easy to grasp.
 
 You only need to create an ABMultiValueRef if the property type is kABMultiStringPropertyType
 
 The one's we care about are:
 email
 phone
 url
 
 For the ABMultiValueAddValueAndLabel() function, the third argument is a "label" constant, which specifies the label that will
 be shown in phone. For example, you can have a "Mobile" phone number, a "Work" phone number, etc.
 
 The generic labels available are: kABHomeLabel, kABWorkLabel, kABOtherLabel
 
 Some other properties have special labels, such as the URL property (kABPersonHomePageLabel)
 
 */
- (void) contactForPerson:(SSUPerson *)person
{
    ABRecordRef contact = ABPersonCreate();
    
    ABMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueRef url = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueRef phone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueRef organization = ABMultiValueCreateMutable(kABStringPropertyType);
    
    ABRecordSetValue(contact, kABPersonOrganizationProperty, (__bridge CFStringRef)(@"Sonoma State University"), NULL);
    
    if (!SSUIsEmptyString(person.firstName))
    {
        ABRecordSetValue(contact, kABPersonFirstNameProperty,(__bridge CFStringRef)person.firstName , NULL);
    }
    if (!SSUIsEmptyString(person.lastName))
    {
        ABRecordSetValue(contact, kABPersonLastNameProperty, (__bridge CFStringRef)(person.lastName), NULL);
    }
    if (!SSUIsEmptyString(person.email))
    {
        ABMultiValueAddValueAndLabel(email, (__bridge CFStringRef)(person.email), kABWorkLabel, NULL);
        ABRecordSetValue(contact, kABPersonEmailProperty, email, NULL);
    }
    if (!SSUIsEmptyString(person.phone))
    {
        ABMultiValueAddValueAndLabel(phone, (__bridge CFTypeRef)(person.phone), kABWorkLabel, NULL);
        ABRecordSetValue(contact, kABPersonPhoneProperty, phone, NULL);
    }
    if (!SSUIsEmptyString(person.title))
    {
        ABRecordSetValue(contact, kABPersonJobTitleProperty, (__bridge CFTypeRef)(person.title), NULL);
    }
    if (!SSUIsEmptyString(person.department.name))
    {
        ABRecordSetValue(contact, kABPersonDepartmentProperty, (__bridge CFTypeRef)(person.department.name), NULL);
    }
    if (!SSUIsEmptyString(person.site))
    {
        ABMultiValueAddValueAndLabel(url, (__bridge CFStringRef)(person.site), kABPersonHomePageLabel, NULL);
        ABRecordSetValue(contact, kABPersonURLProperty, url, NULL);
    }
    
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    if (status == kABAuthorizationStatusNotDetermined || status != kABAuthorizationStatusAuthorized)
        [self requestAddressBookAccess];
    
    ABUnknownPersonViewController *picker = [[ABUnknownPersonViewController alloc] init];
    picker.unknownPersonViewDelegate = self;
    picker.displayedPerson = contact;
    picker.allowsAddingToAddressBook = YES;
    picker.allowsActions = NO;
    picker.alternateName = person.title; // "Subtitle", shown right below the person's name
    picker.title = person.displayName;
        
    [self.navigationController pushViewController:picker animated:YES];
    
    /*
     Even with ARC, you have to release these Core Foundation data types with CFRelease
     or you'll leak memory
     */
    CFRelease(email);
    CFRelease(phone);
    CFRelease(url);
    CFRelease(organization);
    CFRelease(contact);
}

/**
 Dismisses the ABUnknownPersonViewController once the user is finished making a contact
 */
- (void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownPersonView didResolveToPerson:(ABRecordRef)person
{
    [self.navigationController popViewControllerAnimated:YES];
}

// Prompt the user for access to their Address Book data
-(void)requestAddressBookAccess
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!granted)
            {
                /**
                 The user has denied us access some time in the past, and they can only
                 give us access by going to the privacy settings in their device.
                 */
                [[[UIAlertView alloc] initWithTitle:@"Cannot Create Contact"
                                           message:@"You have denied access to your contacts. You can change this in your device's settings."
                                          delegate:nil
                                 cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
            if (addressBook)
            {
                CFRelease(addressBook);
            }
        });
    });
}

@end
