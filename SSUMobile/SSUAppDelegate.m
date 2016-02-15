//
//  SSUAppDelegate.m
//  SSUMobile
//
//  Created by Andrew Huss on 1/24/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUAppDelegate.h"
#import "SSUSettingsConstants.h"
#import "SSURadioStreamer.h"
#import "SSUModuleBase.h"
#import "SSULogging.h"

#import <SDWebImage/SDImageCache.h>

@implementation SSUAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [SSULogging setupLogging];
    [self registerUserDefaults];
    [self setupStyles];
    
    SSULogDebug(@"%@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    
    //Update all modules
    if ([self isFirstLaunchForCurrentVersion]) {
        SSULogDebug(@"First launch");
        [self clearLocalDatabases];
        [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:[self firstLaunchKey]];
        [self setupAll];
    }
    else {
        [self setupAll];
        [self updateAll];
    }
    
    [[SDImageCache sharedImageCache] setMaxCacheSize:1024*1000*100]; // 100MB max cache size
    
    return YES;
}

- (NSArray *) moduleClasses {
    return @[
             @"SSUAboutModule",
             @"SSUDirectoryModule",
             @"SSUCalendarModule",
             @"SSUNewsModule",
             @"SSURadioModule",
             @"SSUMapModule",
             @"SSUResourcesModule",
             @"SSUEmailModule",
#ifdef DEBUG
             @"SSUDebugModule",
#endif
             ];
}

- (NSArray<SSUModule> *) modules {
    static NSArray<SSUModule> * modules = nil;
    if (modules) return modules;
    
    NSMutableArray * moduleObjects = (id)[NSMutableArray new];
    for (NSString * className in [self moduleClasses]) {
        Class cls = NSClassFromString(className);
        id<SSUModule> module = [cls sharedInstance];
        NSAssert([module conformsToProtocol:@protocol(SSUModule)], @"Module with name %@ does not conform to the %@ protocol", className, NSStringFromProtocol(@protocol(SSUModule)));
        [moduleObjects addObject:module];
    }
    
    modules = [moduleObjects copy];
    
    return modules;
}

- (NSArray<SSUModuleUI> *) modulesUI {
    static NSArray<SSUModuleUI> * modules = nil;
    if (modules) return modules;
    
    NSMutableArray * moduleObjects = [NSMutableArray new];
    for (id<SSUModule> module in self.modules) {
        if ([module conformsToProtocol:@protocol(SSUModuleUI)]) {
            [moduleObjects addObject:module];
        }
    }
    
    return [moduleObjects copy];
}

- (void) updateAll {
    for (id<SSUModule> module in self.modules) {
        [module updateData:NULL];
    }
}

- (void) setupAll {
    for (id<SSUModule> module in self.modules) {
        [module setup];
    }
}

- (void) setupStyles {
    
    UIColor * mainColor = SSU_BLUE_COLOR;
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:mainColor];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UIToolbar appearance] setBarStyle:UIBarStyleBlack];
    [[UIToolbar appearance] setBarTintColor:mainColor];
    [[UIToolbar appearance] setTintColor:[UIColor whiteColor]];
    [[UISearchBar appearance] setBarTintColor:mainColor];
    [[UISearchBar appearance] setTintColor:mainColor];
    [[UISearchBar appearance] setBackgroundColor:mainColor];
    [[UISearchBar appearance] setBarStyle:UIBarStyleBlack];
    [[UISegmentedControl appearance] setTintColor:mainColor];
    [[UISegmentedControl appearanceWhenContainedIn:[UIToolbar class], nil] setTintColor:[UIColor whiteColor]];
    [[UISegmentedControl appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:[UIColor whiteColor]];
    [[UIBarButtonItem appearanceWhenContainedIn:[UIToolbar class], nil] setTintColor:[UIColor whiteColor]];

}

- (void) registerUserDefaults {
    NSDictionary *userDefaults = @{
                                   SSUDirectorySortOrderKey: @(kSSUFirstLast),
                                   SSUDirectoryDisplayOrderKey: @(kSSUFirstLast),
                                   [self firstLaunchKey] : @(YES)
                                   };
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaults];
}

- (NSString *) firstLaunchKey {
    NSString * const versionKey = @"CFBundleShortVersionString";
    NSString * const appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:versionKey];
    NSString * const suffix = [NSString stringWithFormat:@"_%@", appVersion];
    NSString * const key = [SSUAppIsFirstLaunchKey stringByAppendingString:suffix];
    return key;
}

- (BOOL) isFirstLaunchForCurrentVersion {
    return [[NSUserDefaults standardUserDefaults] boolForKey:[self firstLaunchKey]];
}

/**
 Remote Control Notification
 
 This is called when the user interacts with the media controls on the lock screen
 or in the command center
 */
- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlPause:
            case UIEventSubtypeRemoteControlPlay:
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [[SSURadioStreamer sharedInstance] togglePlayer];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                break;
            default:
                break;
        }
    }
}

- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[SDImageCache sharedImageCache] clearMemory];
}

#pragma mark - Helper

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

/**
 Removes any existing Core Data database files stored in the documents directory.
 */
- (void) clearLocalDatabases {
    NSURL * documents = [self applicationDocumentsDirectory];
    NSArray * filePaths = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:documents includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    NSString * extensionToDelete = @".sqlite";
    for (NSURL * path in filePaths) {
        if ([path.path rangeOfString:extensionToDelete].length == 0) {
            continue;
        }
        SSULogDebug(@"Removing file at path: %@",path);
        [[NSFileManager defaultManager] removeItemAtURL:path error:nil];
    }
}

@end
