//
//  SSUWebViewController.h
//  SSUMobile
//
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

@import UIKit;

@interface SSUWebViewController : UIViewController

/// Use one or the other
@property (nonatomic) NSURL * urlToLoad;
@property (nonatomic, copy) NSString *htmlToShow;

/** Creates a new instance of SSUWebViewController */
+ (SSUWebViewController *) webViewController;

@end
