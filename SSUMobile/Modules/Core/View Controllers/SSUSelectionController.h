//
//  SSUSelectionTableViewController.h
//  SSUMobile
//
//  Created by Eric Amorde on 7/9/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

@import UIKit;

#import "SSUSearchableTableViewController.h"

@class SSUSelectionController;

@protocol SSUSelectionDelegate <NSObject>

@optional
- (void) userDidSelectItem:(id)item atIndexPath:(NSIndexPath *)indexPath fromController:(SSUSelectionController *)controller;
- (void) selectionControllerDismissed:(SSUSelectionController *)controller;

@end

/**
 Displays a list of options that the user can select.
 */
@interface SSUSelectionController : SSUSearchableTableViewController <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>

/**
 The choices that the controller will present to the user. 
 If the objects in the array are NSString objects, the table view will set the text of each table cell to the string value. 
 Otherwise, [object description] for each object in the array.
 */
@property (nonatomic) NSArray *choices;

/**
 Controls whether or not the user can freely modify the selected item until pressing the "Done" button
 in the navigation bar. If this is YES, then the selectionControllerDismissed: method must be utilized
 by the delegate to retrieve the selected item. If this is NO, the SSUSelectionController will call
 the userDidSelectItem:atIndexPath:fromController: method on its delegate and dismiss itself.
 */
@property (nonatomic) BOOL allowUserDismissal;

/**
 If set, the row at this index will have a checkmark next to it and will be used if the user presses
 done. This has no effect if allow
 */
@property (nonatomic) NSIndexPath *defaultIndex;

/**
 The key used to populate each table cell's text label. If the choices are not NSString objects,
 The SSUSelectionController will call valueForKey: on each choice and pass to it the value of textKey.
 The default value is description.
 */
@property (nonatomic, copy) NSString *textKey;

/**
 The key to use as the cell's subtitle
 */
@property (nonatomic, copy) NSString * subtitleKey;

/** If an item is selected, this property will contain the object at the selected index path */
@property (nonatomic, weak) id selectedItem;

/** If a row is selected, this property will hold the selected index path */
@property (nonatomic) NSIndexPath *selectedIndex;

/** This controller's SSUSelectionDelegate object @see SSUSelectionDelegate */
@property (nonatomic, weak) id<SSUSelectionDelegate> delegate;

/** The search bar at the top of the view controller */
@property (nonatomic) UISearchBar * searchBar;

/** The current search data, if any, filtered by the text entered in the search bar */
@property (nonatomic) NSArray * searchData;


/**
 @param items Choices to present to the user
 */
- (instancetype) initWithItems:(NSArray *)items;

@end
