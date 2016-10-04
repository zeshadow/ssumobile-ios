//
//  SSUDirectoryViewController.h
//  SSUMobile
//
//  Created by Andrew Huss on 2/9/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

@import UIKit;
#import "SSUCoreDataTableViewController.h"
#import "SSUDirectoryConstants.h"
#import "SSUDetailTableViewController.h"
#import "SSUDirectoryModels.h"

@class SSUDirectoryViewController;

/**
 Delegate protocol for the SSUDirectoryViewController class.
 
 The protocol specifies one option method, [directoryViewController:didSelectObject:].
 */
@protocol SSUDirectoryDelegate <NSObject>

@optional
/**
 Called when the user selects a row in the list of objects being displayed.
 */
- (void) directoryViewController:(SSUDirectoryViewController *)controller didSelectObject:(id)object;

@end

@interface SSUDirectoryViewController : SSUCoreDataTableViewController <SSUDetailTableViewDelegate, UITableViewDataSource, UITableViewDelegate>

+ (instancetype) instantiateFromStoryboard;

/**
 Manually fetches a specific entity. Use this to force load an entity without needing user input.
 
 @warning  The view controller will attempt to select the segment of the UISegmentedControl corresponding to the entity. If
 none exists, the selection will be cleared.
 */
- (void) loadEntityName:(NSString*)entityName usingPredicate:(NSPredicate*)predicate;

/**
 Use this property if you need to display the detail view for a directory object from another storyboard
 
 Segue to this view controller and in your prepareForSegue: method, set this property to the object that needs to be displayed.
 */
@property (nonatomic) SSUDirectoryObject * objectToDisplay;

/**
 A list of entity names available in the segmented control header, as NSString objects.
 If nil, a default list of entities will be used.
 */
@property (strong, nonatomic) NSArray * entities;

/**
 The name of the current entity being displayed in the table view. Read only.
 */
@property (strong, nonatomic, readonly) NSString* entityName;

/**
 This predicate will be combined with any other predicates added internally by this view controller.
 
 For example, this predicate will be combined with any text searches*/
@property (nonatomic) NSPredicate * defaultPredicate;

/**
 Determines whether or not the section headers show text titles
 Default is NO.
 */
@property (nonatomic) BOOL showsSectionTitles;

/**
 Determines whether or not the table view shows section index titles
 Default is NO.
 */
@property (nonatomic) BOOL showsSectionIndexTitles;

/**
 This view controllers delegate.
 */
@property (weak, nonatomic) id<SSUDirectoryDelegate> delegate;

@end
