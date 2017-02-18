//
//  SSUCoreTableViewController.m
//  SSUMobile
//
//  Created by Eric Amorde on 31/08/2016.
//  Copyright © 2016 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUCoreTableViewController.h"
#import "SSUTableHeaderView.h"

static NSString * const kHeaderReuseIdentifier = @"SSUCoreTableViewHeader";

@interface SSUCoreTableViewController ()

@end

@implementation SSUCoreTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = SSU_BLUE_COLOR;
    
    [self.tableView registerClass:[SSUTableHeaderView class] forHeaderFooterViewReuseIdentifier:kHeaderReuseIdentifier];
}

#pragma mark - Table view

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString * identifier = kHeaderReuseIdentifier;
    SSUTableHeaderView * header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    header.headerTextLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    return header;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 22; // default height, override in subclasses if needed
}

@end
