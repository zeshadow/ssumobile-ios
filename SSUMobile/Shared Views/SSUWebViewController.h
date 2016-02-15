#import <UIKit/UIKit.h>

@interface SSUWebViewController : UIViewController

/// Use one or the other
@property (nonatomic, copy) NSString *urlToLoad;
@property (nonatomic, copy) NSString *htmlToShow;

+ (SSUWebViewController *)webViewControllerFromStoryboard;

@end
