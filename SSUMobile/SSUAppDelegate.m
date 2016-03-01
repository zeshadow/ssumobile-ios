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
#import "SSUConfiguration.h"

#import <SDWebImage/SDImageCache.h>

NSString * const SSUModulesDidLoadNotification = @"edu.sonoma.modules.loaded.notification";
static NSString * const SSUModulesEnabledKey = @"edu.sonoma.modules.enabled";

@interface SSUAppDelegate()

@property (nonatomic) NSArray<SSUModule> * modules;
@property (nonatomic) NSArray<SSUModuleUI> * modulesUI;

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
        [self setupAll];
        [self showWelcomeMessage];
    }
    else {
        [self setupAll];
        [self updateAll];
    }
    
    [[SDImageCache sharedImageCache] setMaxCacheSize:1024*1000*100]; // 100MB max cache size
    
    return YES;
}

- (NSArray *) moduleClasses {
    NSArray <NSString *> * moduleClasses = [[SSUConfiguration sharedInstance] stringArrayForKey:@"edu.sonoma.modules.enabled"];
#ifdef DEBUG
    if (NSClassFromString(@"SSUDebugModule")) {
        return [moduleClasses arrayByAddingObject:@"SSUDebugModule"];
    }
    return moduleClasses;
#else
    return moduleClasses;
#endif
}

- (NSArray<SSUModule> *) modules {
    if (_modules) return _modules;
    
    NSMutableArray * moduleObjects = (id)[NSMutableArray new];
    for (NSString * className in [self moduleClasses]) {
        Class cls = NSClassFromString(className);
        id<SSUModule> module = [cls sharedInstance];
        NSAssert([module conformsToProtocol:@protocol(SSUModule)], @"Module with name %@ does not conform to the %@ protocol", className, NSStringFromProtocol(@protocol(SSUModule)));
        [moduleObjects addObject:module];
    }
    
    _modules = [moduleObjects copy];
    
    return _modules;
}

- (NSArray<SSUModuleUI> *) modulesUI {
    if (_modulesUI) return _modulesUI;
    
    NSMutableArray * moduleObjects = [NSMutableArray new];
    for (id<SSUModule> module in self.modules) {
        if ([module conformsToProtocol:@protocol(SSUModuleUI)]) {
            [moduleObjects addObject:module];
        }
    }
    
    _modulesUI = [moduleObjects copy];
    
    return _modulesUI;
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
    // Load settings from moonlight
    if ([self isFirstLaunchForCurrentVersion]) {
        return;
    }
    
    NSURL * configURL = [NSURL URLWithString:[SSUMoonlightBaseURL stringByAppendingPathComponent:@"settings"]];
    NSArray * classes = [[SSUConfiguration sharedInstance] stringArrayForKey:SSUModulesEnabledKey];
    [[SSUConfiguration sharedInstance] loadFromURL:configURL completion:^(NSError *error) {
        SSULogDebug(@"After loading from moonlight: %@", [[SSUConfiguration sharedInstance] dictionaryRepresentation]);
        if (![classes isEqualToArray:[[SSUConfiguration sharedInstance] stringArrayForKey:SSUModulesEnabledKey]]) {
            self.modules = nil;
            self.modulesUI = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:SSUModulesDidLoadNotification object:nil];
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
    [self updateAll];
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
