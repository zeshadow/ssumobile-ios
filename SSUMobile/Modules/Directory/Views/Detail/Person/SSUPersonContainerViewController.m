//
//  SSUPersonContainerViewController.m
//  SSUMobile
//
//  Created by Andrew Huss on 1/30/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUPersonContainerViewController.h"
#import "SSUPerson+properties.h"

@interface SSUPersonContainerViewController ()

@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;

@end

@implementation SSUPersonContainerViewController


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    // Make the header view as small as possible so that the positioning correctly reflects
    // what it appears to be in the storyboard. Needed for embedding in SSUPersonViewController.
    // This is kind of hacky. Maybe fix this later through the storyboard somehow.
    if (section == 0)
        return 1;
    return [super tableView:tableView heightForHeaderInSection:section];
}

- (void) updateObject {
    [super updateObject];
    SSUPerson* person = (SSUPerson*)[self object];
    
    if (!SSUIsEmptyString(person.firstName)) {
        _firstNameLabel.text = person.firstName;
        _firstNameLabel.enabled = YES;
    }
    else {
        _firstNameLabel.text = UNKNOWN_VALUE;
        _firstNameLabel.enabled = NO;
    }
    
    if (!SSUIsEmptyString(person.lastName)) {
        _lastNameLabel.text = person.lastName;
        _lastNameLabel.enabled = YES;
    }
    else {
        _lastNameLabel.text = UNKNOWN_VALUE;
        _lastNameLabel.enabled = NO;
    }
}

@end
