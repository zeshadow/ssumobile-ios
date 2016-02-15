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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
        [_firstNameLabel setText:person.firstName];
        [_firstNameLabel setEnabled:YES];
    }
    else {
        [_firstNameLabel setText:UNKNOWN_VALUE];
        [_firstNameLabel setEnabled:NO];
    }
    
    if (!SSUIsEmptyString(person.lastName)) {
        [_lastNameLabel setText:person.lastName];
        [_lastNameLabel setEnabled:YES];
    }
    else {
        [_lastNameLabel setText:UNKNOWN_VALUE];
        [_lastNameLabel setEnabled:NO];
    }
}

@end
