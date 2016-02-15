//
//  SSUMapPopoverContentController.m
//  SSUMobile
//
//  Created by Eric Amorde on 1/18/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUMapPopoverContentController.h"
#import "SSUTableHeaderView.h"

static NSString * const TableHeaderReuseIdentifier = @"PopoverHeader";

@interface SSUMapPopoverContentController ()

- (IBAction) directionsButtonPressed:(UIBarButtonItem *)button;
@property (nonatomic,strong) UILabel * emptyLabel;
@property (nonatomic) BOOL empty;

@end

@implementation SSUMapPopoverContentController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.emptyLabel = [UILabel new];
    self.emptyLabel.text = @"No departments here";
    self.emptyLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    [self.emptyLabel sizeToFit];
    
    [self.tableView registerClass:[SSUTableHeaderView class] forHeaderFooterViewReuseIdentifier:TableHeaderReuseIdentifier];
}

+ (instancetype) instantiateFromStoryboard {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Map_iPhone" bundle:nil];
    SSUMapPopoverContentController * controller = [storyboard instantiateViewControllerWithIdentifier:@"Popover"];
    return controller;
}

- (CGSize) preferredContentSize {
    [self.tableView sizeToFit];
    if (self.empty) {
        CGSize tableSize = self.tableView.frame.size;
        CGSize labelSize = self.emptyLabel.frame.size;
        CGSize navBarSize = self.navigationController.navigationBar.frame.size;
        CGSize contentSize = CGSizeMake(MAX(tableSize.width, labelSize.width),
                                        MAX(tableSize.height,labelSize.height+navBarSize.height));
        return contentSize;
    }
    return self.tableView.frame.size;
}

- (void) viewDidLayoutSubviews {
    self.emptyLabel.center = CGPointMake(self.tableView.center.x, self.emptyLabel.frame.size.height/2);
}

#pragma mark - Actions

- (IBAction) directionsButtonPressed:(UIBarButtonItem *)button {
    if ([self.delegate respondsToSelector:@selector(contentControllerRequestedDirections:)])
        [self.delegate contentControllerRequestedDirections:self];
}

#pragma mark - Table view data source

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SSUTableHeaderView * tableHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:TableHeaderReuseIdentifier];
    tableHeader.headerTextLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    return tableHeader;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return UITableViewAutomaticDimension;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (self.empty) ? nil : self.sectionTitle;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.empty) ? 0 : 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Object"];
    cell.textLabel.text = [self.objects[indexPath.row] valueForKey:self.textKey];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.delegate respondsToSelector:@selector(contentController:didSelectObject:)]) {
        id obj = self.objects[indexPath.row];
        [self.delegate contentController:self didSelectObject:obj];
    }
    
}


#pragma mark - Properties

/**
 The key passed to `valueForKey:` when called on each object in `objects`
 
 Default: "description"
 */
- (NSString *) textKey {
    if (_textKey) {
        return _textKey;
    }
    
    _textKey = @"description";
    return _textKey;
}

/**
 Used as the section title for the "objects" section
 
 Default: "Located here"
 */
- (NSString *) sectionTitle {
    if (_sectionTitle) {
        return _sectionTitle;
    }
    
    _sectionTitle = @"Located Here";
    return _sectionTitle;
}

- (void) setObjects:(NSArray *)objects {
    _objects = objects;
    self.empty = _objects.count == 0;
    [self.emptyLabel removeFromSuperview];
    if (self.empty) {
        [self.tableView addSubview:self.emptyLabel];
    }
    [self.tableView reloadData];
}

@end
