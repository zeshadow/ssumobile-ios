//
//  SSUAppPickerViewController.m
//  SSUMobile
//
//  Created by Andrew Huss on 2/14/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUAppPickerViewController.h"
#import "RBStoryboardLink.h"
#import "SSUAppDelegate.h"
#import "SSUModuleServices.h"
#import "SSULogging.h"

@interface SSUAppPickerViewController ()

@end

@implementation SSUAppPickerViewController


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
    segue.destinationViewController.title = [self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow].textLabel.text;
}

- (void) didRefresh:(id)sender {
    [[SSUModuleServices sharedInstance] updateAll];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.refreshControl];
}

@end
