//
//  SSUWebViewController.h
//  SSUMobile
//
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSUWebViewController : UIViewController

/// Use one or the other
@property (nonatomic, copy) NSString *urlToLoad;
@property (nonatomic, copy) NSString *htmlToShow;

/** Creates a new instance of SSUWebViewController */
+ (SSUWebViewController *) webViewController;

@end
