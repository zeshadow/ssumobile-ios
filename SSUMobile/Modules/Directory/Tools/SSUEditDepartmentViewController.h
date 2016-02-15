//
//  SSUEditDepartmentViewController.h
//  SSUMobile
//
//  Created by Eric Amorde on 7/8/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUDetailTableViewController.h"

@interface SSUEditDepartmentViewController : SSUDetailTableViewController

@property (nonatomic) IBOutlet UITextField * nameTextField;
@property (nonatomic) IBOutlet UITextField * displayNameTextField;
@property (nonatomic) IBOutlet UITextField * siteTextField;
@property (nonatomic) IBOutlet UITextField * phoneTextField;
@property (nonatomic) IBOutlet UITextField * officeTextField;

@property (nonatomic) IBOutlet UILabel * chairLabel;
@property (nonatomic) IBOutlet UILabel * acLabel;
@property (nonatomic) IBOutlet UILabel * schoolLabel;
@property (nonatomic) IBOutlet UILabel * buildingLabel;

@end
