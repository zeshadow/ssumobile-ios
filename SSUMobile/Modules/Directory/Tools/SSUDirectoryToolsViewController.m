//
//  SSUDirectoryToolsViewController.m
//  SSUMobile
//
//  Created by Eric Amorde on 7/8/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUDirectoryToolsViewController.h"
#import "SSUDirectoryModule.h"
#import "SSUDirectoryObject.h"
#import "SSUDepartment.h"
#import "SSUPerson.h"
#import "SSUBuilding.h"
#import "SSUSchool.h"

@interface SSUDirectoryViewController ()

- (SSUDirectoryObject *) objectAtIndex:(NSIndexPath *)indexPath;

@end

@implementation SSUDirectoryToolsViewController

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.entities = @[SSUDirectoryEntityDepartment];
    [self loadEntityName:SSUDirectoryEntityDepartment usingPredicate:nil];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SSUDirectoryObject * object = [self objectAtIndex:self.tableView.indexPathForSelectedRow];
    SSUDetailTableViewController * detail = segue.destinationViewController;
    [detail loadObject:object inContext:[SSUDirectoryModule sharedInstance].context];
}

- (IBAction)filterButtonPressed:(UIBarButtonItem *)sender {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Filter" message:@"Select a filter" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"All entries" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self loadEntityName:self.entityName usingPredicate:nil];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Missing chair" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K = nil",@"chair"];
        [self loadEntityName:self.entityName usingPredicate:predicate];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Missing AC" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K = nil",@"ac"];
        [self loadEntityName:self.entityName usingPredicate:predicate];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Missing school" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K = nil",@"school"];
        [self loadEntityName:self.entityName usingPredicate:predicate];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Missing building" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K = nil",@"building"];
        [self loadEntityName:self.entityName usingPredicate:predicate];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    
    [self.navigationController presentViewController:alertController animated:YES completion:NULL];
}

@end
