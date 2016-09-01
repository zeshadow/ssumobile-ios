//
//  SSUBoundryBuildingSelectorViewController.h
//  SSUMobile
//
//  Created by Andrew Huss on 4/14/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

@import UIKit;
#import "SSUBuilding.h"

@class SSUBoundaryBuildingSelectorViewController;

@protocol SSUBoundaryBuildingSelectorViewControllerDelegate <NSObject>

- (void)boundaryBuildingSelector:(SSUBoundaryBuildingSelectorViewController *)viewController didSelectBuilding:(SSUBuilding *)building;

@end

@interface SSUBoundaryBuildingSelectorViewController : UITableViewController

/// If this is defined, a checkmark will appear near each of the buildings in this set. Otherwise, there will never be checkmarks near a building name.
@property (strong, nonatomic) NSSet* definedBuildingIDs;
@property (weak, nonatomic) id<SSUBoundaryBuildingSelectorViewControllerDelegate> delegate;

@end
