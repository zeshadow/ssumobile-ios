//
//  SSUMapPopoverContentController.h
//  SSUMobile
//
//  Created by Eric Amorde on 1/18/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//
//  This class is meant to display popover views in the map.
//  Set the `objects` property to an array of objects to list
//  in bottom section, and set the `textKey` property to the
//  property of the object to use as the cell's text. If not
//  set, the cell will display the result of calling `description`
//  on each object
//

@import UIKit;

@class SSUMapPopoverContentController;

@protocol SSUMapPopoverDelegate <NSObject>

@optional
- (void) contentController:(SSUMapPopoverContentController *)popover didSelectObject:(id)object;
- (void) contentControllerRequestedDirections:(SSUMapPopoverContentController *)popover;

@end

@interface SSUMapPopoverContentController : UITableViewController

@property (nonatomic,strong) NSArray * objects;
@property (nonatomic,strong) NSString * textKey;
@property (nonatomic,strong) NSString * sectionTitle;
@property (nonatomic,weak) id<SSUMapPopoverDelegate> delegate;

+ (instancetype) instantiateFromStoryboard;

@end
