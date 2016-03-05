//
//  SSUAboutViewController.m
//  SSUMobile
//
//  Created by Eric Amorde on 10/20/14.
//  Copyright (c) 2014 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUAboutViewController.h"
#import "SSUWebViewController.h"
#import "SSULDAPCredentials.h"
#import <SDWebImage/SDImageCache.h>
#import "MBProgressHUD.h"

static NSString * LEGAL_CELL = @"Legal";
static NSString * LDAP_CELL = @"LDAP";
static NSString * CACHE_CELL = @"Cache";

@interface SSUAboutViewController ()

@property (nonatomic, weak) IBOutlet UILabel * versionLabel;
@property (nonatomic, weak) IBOutlet UILabel * imageCacheLabel;
@property (nonatomic, weak) IBOutlet UILabel * ldapLabel;

@end

@implementation SSUAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    
    self.versionLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [self updateCacheDisplay];
    [self updateLDAPDisplay];
}

- (void) updateCacheDisplay {
    [[SDImageCache sharedImageCache] calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize) {
        double MB = totalSize / 1024.0 / 1024.0; // bytes --> MB
        self.imageCacheLabel.text = [NSString stringWithFormat:@"%0.2fMB / %lu images",MB,(unsigned long)fileCount];
    }];
}

- (void) updateLDAPDisplay {
    self.ldapLabel.enabled = [[SSULDAPCredentials sharedInstance] hasCredentials];
}

#pragma mark - Table View

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:LEGAL_CELL]) {
        SSUWebViewController * webView = [SSUWebViewController webViewController];
        webView.urlToLoad = [[NSBundle mainBundle] pathForResource:@"licenses" ofType:@"txt"];
        
        [self.navigationController pushViewController:webView animated:YES];
    }
    else if ([cell.reuseIdentifier isEqualToString:LDAP_CELL]) {
        if ([[SSULDAPCredentials sharedInstance] hasCredentials]) {
            [[SSULDAPCredentials sharedInstance] clearCredentials];
            [self updateLDAPDisplay];
            MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
            hud.labelText = @"Logged Out";
            hud.mode = MBProgressHUDModeText;
            [hud hide:YES afterDelay:1.0];
        }
    }
    else if ([cell.reuseIdentifier isEqualToString:CACHE_CELL]) {
        [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
            [self updateCacheDisplay];
        }];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
