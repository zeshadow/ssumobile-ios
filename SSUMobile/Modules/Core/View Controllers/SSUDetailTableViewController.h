//
//  SSUDetailTableViewController.h
//  SSUMobile
//
//  Created by Andrew Huss on 1/31/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

@import UIKit;
@import CoreData;

@class SSUDetailTableViewController;

@protocol SSUDetailTableViewDelegate <NSObject>

- (void) detailTableView:(SSUDetailTableViewController *)controller didSelectObject:(id)object;
@optional
- (void) detailTableViewWillDismiss:(SSUDetailTableViewController *)controller;
- (void) detailTableViewDidAppear:(SSUDetailTableViewController *)controller;
- (void) detailTableView:(SSUDetailTableViewController *)controller requestedMapDisplayForObject:(id)object;

@end

// What will be shown if the value of a property is null/unknown
static NSString * UNKNOWN_VALUE = @"None";

@interface SSUDetailTableViewController : UITableViewController

- (void) loadObject:(NSManagedObject*)object inContext:(NSManagedObjectContext*)context;

- (NSManagedObject*) managedObjectForEntity:(NSString*)entityName withAttributeName:(NSString*)attributeName attributeValue:(id)attributeValue;

- (void) updateObject;
- (void) fetchObject;
- (NSManagedObject*) object;

- (void) hideCellAtIndexPath:(NSIndexPath *)indexPath;
- (void) unhideCellAtIndexPath:(NSIndexPath *)indexPath;
- (void) unhideAllCells;
- (BOOL) cellHiddenAtIndexPath:(NSIndexPath *)indexPath;

@property (weak,nonatomic) id<SSUDetailTableViewDelegate> delegate;
//@property (strong, nonatomic) NSMutableSet * hiddenIndices;


@end
