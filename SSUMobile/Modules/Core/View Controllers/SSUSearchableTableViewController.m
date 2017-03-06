//
//  SSUSearchableTableViewController.m
//  SSUMobile
//
//  Created by Eric Amorde on 31/08/2016.
//  Copyright © 2016 Sonoma State University Department of Computer Science. All rights reserved.
//

@import CoreGraphics;

#import "SSUSearchableTableViewController.h"
#import "SSULogging.h"

@interface SSUSearchableTableViewController () <UISearchBarDelegate>

@property (nonatomic, strong) UIBarButtonItem * searchButton;
@property (nonatomic, strong) UIBarButtonItem * cancelButton;

@end

@implementation SSUSearchableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.barTintColor = SSU_BLUE_COLOR;
    self.searchController.searchBar.tintColor = [UIColor whiteColor];
    self.searchController.searchBar.showsCancelButton = YES;
    self.searchController.searchBar.translucent = NO;
    self.searchController.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchController.searchBar.delegate = self;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.delegate = self;
    
    self.definesPresentationContext = YES;
    
    self.searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonAction:)];
    self.cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonAction:)];
    self.navigationItem.rightBarButtonItem = self.searchButton;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self cancelButtonAction:self.cancelButton];
}

- (NSString *) searchKey {
    if (_searchKey) return _searchKey;
    
    _searchKey = @"term";
    return _searchKey;
}

- (BOOL) isSearching {
    return self.searchController.active;
}

- (void) setIsSearching:(BOOL)isSearching {
    self.searchController.active = isSearching;
}

- (BOOL) searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self cancelButtonAction:self.cancelButton];
}

- (void) didPresentSearchController:(UISearchController *)searchController {
    //TODO: For now this works, but there is a weird but where the search bar cannot
    //      become first responder because it is in the middle of animations? not sure.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [searchController.searchBar becomeFirstResponder];
    });
}

- (void) updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString * searchText = searchController.searchBar.text;
    [self filterContentForSearchText:searchText];
}

- (void) filterContentForSearchText:(NSString*)searchText {
    SSULogWarn(@"Subclass of %@ did not implement filterContentForSearchText", NSStringFromClass([self class]));
}

- (NSPredicate *) searchPredicateForText:(NSString *)searchText {
    if ([searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
        return [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", self.searchKey, searchText];
    }
    return [NSPredicate predicateWithValue:YES];
}

- (void) searchButtonAction:(UIBarButtonItem *)button {
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.titleView = self.searchController.searchBar;
    [self.navigationController.navigationBar layoutSubviews];
    [self.searchController.searchBar layoutSubviews];
    
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self.searchController.searchBar becomeFirstResponder];
    }];
    self.searchController.active = YES;
    [CATransaction commit];
}

- (void) cancelButtonAction:(UIBarButtonItem *)cancel {
    self.navigationItem.titleView = nil;
    self.searchController.active = NO;
    self.navigationItem.rightBarButtonItem = self.searchButton;
    self.navigationItem.hidesBackButton = NO;
}


@end
