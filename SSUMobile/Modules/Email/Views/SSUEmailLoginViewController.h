//
//  SSUEmailLoginViewController.h
//  SSUMobile
//
//  Created by Eric Amorde on 2/7/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

@import UIKit;

@class SSUEmailLoginViewController;

@protocol SSUEmailLoginDelegate <NSObject>

- (void) loginControllerDidLogin:(SSUEmailLoginViewController *)controller;
- (void) loginControllerDidCancel:(SSUEmailLoginViewController *)controller;

@end

@interface SSUEmailLoginViewController : UITableViewController

@property (nonatomic,weak) id<SSUEmailLoginDelegate> delegate;

- (NSString *) username;
- (NSString *) password;
- (BOOL) rememberLogin;

@end
