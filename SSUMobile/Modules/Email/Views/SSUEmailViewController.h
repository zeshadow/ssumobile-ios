//
//  SSUEmailViewController.h
//  SSUMobile
//
//  Created by Eric Amorde on 2/7/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

@import UIKit;

typedef NS_ENUM(NSInteger, SSUEmailViewControllerMode) {
    SSUEmailViewControllerModeEmail,
    SSUEmailViewControllerModeGoogleDocs,
};

@interface SSUEmailViewController : UIViewController

@property (nonatomic) SSUEmailViewControllerMode mode;

@end
