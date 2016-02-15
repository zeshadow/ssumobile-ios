//
//  SSUDirectoryDetailController.h
//  SSUMobile
//
//  Created by Eric Amorde on 1/9/15.
//  Copyright (c) 2015 Computer Science. All rights reserved.
//

#import "SSUDetailTableViewController.h"
#import "SSUDirectoryModels.h"

@interface SSUDirectoryDetailController : SSUDetailTableViewController

@property (nonatomic,weak) id selectedObject;

- (void) showDetailForObject:(SSUDirectoryObject *)object animated:(BOOL)animated;

@end
