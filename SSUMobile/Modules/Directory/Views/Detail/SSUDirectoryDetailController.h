//
//  SSUDirectoryDetailController.h
//  SSUMobile
//
//  Created by Eric Amorde on 1/9/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUDetailTableViewController.h"
#import "SSUDirectoryModels.h"

@interface SSUDirectoryDetailController : SSUDetailTableViewController

@property (nonatomic,weak) id selectedObject;

- (void) showDetailForObject:(SSUDirectoryObject *)object animated:(BOOL)animated;

/**
 Asks the user to confirm calling the given phone number
 */
- (void) confirmCallPhoneNumber;
/**
 Asks the user to confirm loading the selected website in safari
 */
- (void) confirmNavigateToWebsite;

/**
 Asks the user to confirm starting a new email to the selected address
 */
- (void) confirmShowEmailComposer;

/**
 Called if the user confirmed the phone call
 */
- (void) callPhoneNumber;

/**
 Called if the user confirmed navigating to the website
 */
- (void) navigateToWebsite;

/**
 Called if the user confirmed starting a new email to the selected address
 */
- (void) showEmailComposer;

@end
