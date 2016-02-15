//
//  SSUAppPickerViewController.m
//  SSUMobile
//
//  Created by Andrew Huss on 2/14/13.
//  Copyright (c) 2013 Computer Science. All rights reserved.
//

#import "SSUAppPickerViewController.h"
#import "RBStoryboardLink.h"
#import "SSUAppDelegate.h"
#import "SSULogging.h"

@interface SSUAppPickerViewController ()

@end

@implementation SSUAppPickerViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.refreshControl addTarget:self action:@selector(didRefresh:) forControlEvents:UIControlEventValueChanged];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[RBStoryboardLink class]]) {
        RBStoryboardLink* link = segue.destinationViewController;
        SSULogDebug(@"Destination: %@", NSStringFromClass([link.scene class]));
    }
    [segue.destinationViewController setTitle:[self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow].textLabel.text];
}

- (IBAction)didRefresh:(id)sender {
    [AppDelegate updateAll];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.refreshControl];
}

@end
