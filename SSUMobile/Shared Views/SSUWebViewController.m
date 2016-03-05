//
//  SSUWebViewController.h
//  SSUMobile
//
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUWebViewController.h"
#import "MBProgressHud.h"

static NSString * const kStoryboardName = @"SSUWebViewController";

@interface SSUWebViewController () <UIActionSheetDelegate,UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (nonatomic) IBOutlet UIBarButtonItem * backButton;
@property (nonatomic) IBOutlet UIBarButtonItem * forwardButton;

@property (nonatomic) MBProgressHUD * progressHUD;

@end

@implementation SSUWebViewController

+ (SSUWebViewController *) webViewController {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:kStoryboardName
                                                           bundle:[NSBundle bundleForClass:self]];
    id viewController = [storyboard instantiateInitialViewController];
    NSAssert([viewController isKindOfClass:[self class]], @"Expecting web view");
    return viewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem * actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(didPressActionButton:)];
    self.navigationItem.rightBarButtonItem = actionButton;
    
    [self updateNavigationButtons];
    
    self.webview.delegate = self;
    
    if (self.htmlToShow) {
        [self.webview loadHTMLString:self.htmlToShow baseURL:nil];
        actionButton.enabled = NO;
    } else if (self.urlToLoad) {
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.urlToLoad]];
        request.timeoutInterval = 10;
        [self.webview loadRequest:request];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.webview stopLoading];
}

- (void) updateNavigationButtons {
    self.backButton.enabled = NO;
    self.forwardButton.enabled = NO;
}

#pragma mark - IBActions

- (IBAction)didPressBackButton:(UIBarButtonItem *)sender {
    if ([self.webview canGoBack]) {
        [self.webview goBack];
    }
}

- (IBAction)didPressForwardButton:(id)sender{
    if ([self.webview canGoForward]) {
        [self.webview goForward];
    }
}

- (void) didPressActionButton:(UIBarButtonItem *)sender {
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:@"Open in Safari", nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheet

- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        NSURL * url = [NSURL URLWithString:self.urlToLoad];
        if ([[UIApplication sharedApplication] canOpenURL:url])
            [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - UIWebView

- (void) webViewDidStartLoad:(UIWebView *)webView {
    [self.progressHUD show:YES];
    [self.webview bringSubviewToFront:self.progressHUD];
    
    [self updateNavigationButtons];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    [self.progressHUD hide:YES afterDelay:1.0];
    [self updateNavigationButtons];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (error.code == NSURLErrorNotConnectedToInternet) {
        self.progressHUD.labelText = @"No Internet access";
        self.progressHUD.mode = MBProgressHUDModeText;
        [self.progressHUD hide:YES afterDelay:1.0];
    }
    else if ([error.userInfo[NSURLErrorFailingURLStringErrorKey] isEqualToString:self.urlToLoad]){
        self.progressHUD.labelText = @"Failed to load webpage";
        self.progressHUD.mode = MBProgressHUDModeText;
        [self.progressHUD hide:YES afterDelay:1.0];
    }
    else if (!self.webview.loading) {
        // The url that failed is some sort of image or embedded video, so ignore it
        [self.progressHUD hide:YES];
    }
}

#pragma mark - Properties

- (void)setUrlToLoad:(NSString *)urlToLoad {
    _urlToLoad = urlToLoad;
    if (self.view.window) {
        [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlToLoad]]];
    }
}

- (void)setHtmlToShow:(NSString *)htmlToShow {
    _htmlToShow = htmlToShow;
    if (self.view.window) {
        [self.webview loadHTMLString:htmlToShow baseURL:nil];
    }
}

- (MBProgressHUD *) progressHUD {
    if (_progressHUD) {
        return _progressHUD;
    }
    
    _progressHUD = [MBProgressHUD showHUDAddedTo:self.webview animated:YES];
    _progressHUD.labelText = @"Loading";
    
    return _progressHUD;
}

@end
