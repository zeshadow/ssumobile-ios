//
//  SSUAppDelegate.m
//  SSUMobile
//
//  Created by Andrew Huss on 1/24/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

@import Foundation;
@import CoreSpotlight;

#import "SSUAppDelegate.h"
#import "SSUSettingsConstants.h"
#import "SSURadioStreamer.h"
#import "SSUModuleBase.h"
#import "SSULogging.h"
#import "SSUConfiguration.h"
#import "SSUModuleServices.h"
#import "SSUSpotlightServices.h"

#import <SDWebImage/SDImageCache.h>

@interface SSUAppDelegate()

@end

@implementation SSUAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [SSULogging setupLogging];
    [self setupConfiguration];
    [self setupStyles];
    
    SSULogDebug(@"%@", SSUDocumentsDirectory());
    SSULogDebug(@"%@", SSUCachesDirectory());
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:SSUApplicationSupportDirectory().path]) {
        [[NSFileManager defaultManager] createDirectoryAtURL:SSUApplicationSupportDirectory()
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:nil];
    }
    
    //Update all modules
    if ([self isFirstLaunchForCurrentVersion]) {
        SSULogDebug(@"First launch");
        [self clearLocalDatabases];
        [[SSUConfiguration sharedInstance] setBool:NO forKey:[self firstLaunchKey]];
        [[SSUModuleServices sharedInstance] setupAll];
        [self showWelcomeMessage];
    }
    else {
        [[SSUModuleServices sharedInstance] setupAll];
    }
    
    [[SDImageCache sharedImageCache] setMaxCacheSize:1024*1000*100]; // 100MB max cache size
    
    return YES;
}

- (void) applicationDidBecomeActive:(UIApplication *)application {
    // Load settings from moonlight
    if (![self isFirstLaunchForCurrentVersion]) {
        [self loadRemoteConfiguration];
        [[SSUModuleServices sharedInstance] updateAll];
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

- (void) setupConfiguration {
    // Defaults not present in the JSON files
    NSDictionary *userDefaults = @{
                                   SSUDirectorySortOrderKey: @(kSSUFirstLast),
                                   SSUDirectoryDisplayOrderKey: @(kSSUFirstLast),
                                   [self firstLaunchKey] : @(YES)
                                   };
    
    [[SSUConfiguration sharedInstance] registerDefaults:userDefaults];
    // Load JSON defaults included in app bundle
    NSString * path = [[NSBundle mainBundle] pathForResource:@"defaults.json" ofType:nil];
    [[SSUConfiguration sharedInstance] loadDefaultsFromFilePath:path];
}

- (void) loadRemoteConfiguration {
    NSURL * configURL = [NSURL URLWithString:[SSUMoonlightBaseURL stringByAppendingPathComponent:@"settings"]];
    NSArray * classes = [[SSUConfiguration sharedInstance] stringArrayForKey:SSUModulesEnabledKey];
    [[SSUConfiguration sharedInstance] loadFromURL:configURL completion:^(NSError *error) {
        SSULogDebug(@"After loading from moonlight: %@", [[SSUConfiguration sharedInstance] dictionaryRepresentation]);
        if (![classes isEqualToArray:[[SSUConfiguration sharedInstance] stringArrayForKey:SSUModulesEnabledKey]]) {
            [[SSUModuleServices sharedInstance] loadModules];
        }
    }];
}

- (NSString *) firstLaunchKey {
    NSString * const versionKey = @"CFBundleShortVersionString";
    NSString * const appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:versionKey];
    NSString * const suffix = [NSString stringWithFormat:@"_%@", appVersion];
    NSString * const key = [SSUAppIsFirstLaunchKey stringByAppendingString:suffix];
    return key;
}

- (BOOL) isFirstLaunchForCurrentVersion {
    return [[SSUConfiguration sharedInstance] boolForKey:[self firstLaunchKey]];
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

#pragma mark - NSUserActivity / CoreSpotlight

- (BOOL) application:(UIApplication *)application
continueUserActivity:(nonnull NSUserActivity *)userActivity
  restorationHandler:(nonnull void (^)(NSArray * _Nullable))restorationHandler {
    if ([userActivity.activityType isEqualToString:CSSearchableItemActionType]) {
        NSString * identifier = userActivity.userInfo[CSSearchableItemActivityIdentifier];
        NSArray * spotlightModules = [[SSUModuleServices sharedInstance] modulesConformingToProtocol:@protocol(SSUSpotlightSupportedProtocol)];
        for (id<SSUSpotlightSupportedProtocol> module in spotlightModules) {
            if ([module recognizesIdentifier:identifier]) {
                UIViewController * viewController = [module viewControllerForSearchableItemWithIdentifier:identifier];
                [[NSNotificationCenter defaultCenter] postNotificationName:SSUSpotlightActivityRequestingDisplayNotification object:viewController];
            }
        }
    }
    return NO;
}

- (BOOL) application:(UIApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType {
    return [userActivityType isEqualToString:CSSearchableItemActionType];
}

#pragma mark - Helper

- (void) showWelcomeMessage {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Welcome to SSUMobile!"
                                                     message:@"Welcome to the lastest version of SSUMobile! In order to provide you with up to date information, some data will be download from internet."
                                                    delegate:self
                                           cancelButtonTitle:@"Okay"
                                           otherButtonTitles:nil];
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [[SSUModuleServices sharedInstance] updateAll];
    [self loadRemoteConfiguration];
}

/**
 Removes any existing Core Data database files stored in the documents directory.
 */
- (void) clearLocalDatabases {
    NSString * extensionToDelete = @".sqlite";
    [self deleteFilesInDiretory:SSUDocumentsDirectory() matchingExtension:extensionToDelete];
    [self deleteFilesInDiretory:SSUApplicationSupportDirectory() matchingExtension:extensionToDelete];
}

- (void) deleteFilesInDiretory:(NSURL *)directory matchingExtension:(NSString *)extension {
    BOOL isDirectory = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:directory.path isDirectory:&isDirectory];
    if (!(exists && isDirectory)) {
        SSULogError(@"Attempting to remove files from a path which does not exist or is not a directory: %@", directory);
        return;
    }
    
    NSArray * filePaths = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:directory
                                                        includingPropertiesForKeys:nil
                                                                           options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                             error:nil];
    for (NSURL * path in filePaths) {
        if ([path.path rangeOfString:extension].location == NSNotFound) {
            continue;
        }
        SSULogDebug(@"Removing file at path: %@",path);
        [[NSFileManager defaultManager] removeItemAtURL:path error:nil];
    }
}

@end
