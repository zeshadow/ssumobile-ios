//
//  SSUModuleBase.h
//  SSUMobile
//
//  Created by Eric Amorde on 9/8/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SSUModule <NSObject>

+ (nonnull instancetype) sharedInstance;

/** A user-facing title for this module. Should be localized */
- (nonnull NSString *) title;
/** A non-user-facing identifier for this module. */
- (nonnull NSString *) identifier;

/** Called immediately after application launch to provide modules with a time to set themselves up properly */
- (void) setup;
/** Called when the application is updating all modules at once */
- (void) updateData:(void  (^ _Nullable )())completion;
/** Called when the user requests the deletion of all cached data */
- (void) clearCachedData;

@end

@protocol SSUModuleUI <SSUModule>

/** The image that will be used as the button for this module */
- (nullable UIImage *) imageForHomeScreen;
/** The module's initial view controller */
- (nonnull UIViewController *) initialViewController;

/** 
 Return YES if your module is available, or NO if the functionality is not available or you do not
 need to present a view controller to the user (ex. just going to open a link in Safari
 */
- (BOOL) shouldNavigateToModule;

/** If YES, this module's `viewForHomeScreen` view will be set as the navigation item's rightBarButtonItem */
- (BOOL) showModuleInNavigationBar;
/** The view that shows up on the homescreen and navigates to this module */
- (nonnull UIView *) viewForHomeScreen;

@end

@interface SSUModuleBase : NSObject <SSUModule>

@property (nonatomic, strong, readonly, nonnull) NSDateFormatter * dateFormatter;

+ (nonnull instancetype) sharedInstance;

- (BOOL) setExcludeFromBackupAttributeOnResourceAtURL:(nullable NSURL *)url toValue:(BOOL)excluded;

@end
