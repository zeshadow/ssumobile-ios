//
//  SSUMapBuildingDetailViewController.h
//  SSUMobile
//
//  Created by Eric Amorde on 9/30/15.
//  Copyright © 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

@import UIKit;
#import "SSUDirectoryModels.h"

@class SSUMapBuildingDetailViewController;

@protocol SSUMapBuildingDetailDelegate <NSObject>

- (BOOL) userLocationAvailable;
- (void) mapBuildingDetailRequestedDirections:(SSUMapBuildingDetailViewController *)controller;

@end

@interface SSUMapBuildingDetailViewController : UITableViewController

+ (instancetype) instantiateFromStoryboard;

@property (nonatomic, strong) SSUBuilding * building;
@property (nonatomic, weak) id<SSUMapBuildingDetailDelegate> delegate;

@end
