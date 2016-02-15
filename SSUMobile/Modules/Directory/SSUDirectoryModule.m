//
//  SSUDirectoryModule.m
//  SSUMobile
//
//  Created by Eric Amorde on 9/8/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUDirectoryModule.h"
#import "SSUDirectoryBuilder.h"
#import "SSUMoonlightCommunicator.h"
#import "SSULogging.h"

@interface SSUDirectoryModule()

@end

@implementation SSUDirectoryModule

+ (instancetype) sharedInstance {
    static SSUDirectoryModule * instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - SSUModule

- (NSString *) title {
    return NSLocalizedString(@"Directory",
                             @"The campus directory containing the contact information of faculty and staff");
}

- (UIView *) viewForHomeScreen {
    //return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"directory_icon"]];
    UIImage * image = [UIImage imageNamed:@"directory_icon"];
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];
    button.contentMode = UIViewContentModeScaleAspectFit;
    return button;
}

- (UIImage *) imageForHomeScreen {
    return [UIImage imageNamed:@"directory_icon"];
}

- (BOOL) showModuleInNavigationBar {
    return NO;
}

- (void) selectHomeScreenView:(UIView *)view {
    UIButton * button = (UIButton *)view;
    [button setHighlighted:YES];
}

- (void) deselectHomeScreenView:(UIView *)view {
    UIButton * button = (UIButton *)view;
    [button setHighlighted:NO];
}

- (UIViewController *) initialViewController {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Directory_iPhone"
                                                          bundle:[NSBundle bundleForClass:[self class]]];
    return [storyboard instantiateInitialViewController];
}

- (void) setup {
    NSManagedObjectModel * model = [self modelWithName:@"Directory"];
    NSPersistentStoreCoordinator * coordinator = [self persistentStoreCoordinatorWithName:@"Directory" model:model];
    self.context = [self contextWithPersistentStoreCoordinator:coordinator];
    self.backgroundContext = [self backgroundContextFromContext:self.context];
}

- (void) clearCachedData {
    //TODO: implement clearCachedData
}

- (void) updateData:(void (^)())completion {
    SSULogDebug(@"Update Directory NEW");
    NSString * lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:SSUUserDefaultsDirectoryUpdatedDate];
    NSDate * date = (lastUpdate != nil) ? [self.dateFormatter dateFromString:lastUpdate] : nil;
    [SSUMoonlightCommunicator getJSONFromPath:@"directory" sinceDate:date completion:^(id json, NSError *error) {
        if (error != nil) {
            SSULogError(@"Error while attemping to update directory: %@", error);
            if (completion) {
                completion();
            }
        }
        else {
            NSString * date = [self.dateFormatter stringFromDate:[NSDate date]];
            [[NSUserDefaults standardUserDefaults] setObject:date forKey:SSUUserDefaultsDirectoryUpdatedDate];
            [self.backgroundContext performBlock:^{
                [self buildJSON:json];
                if (completion) {
                    completion();
                }
            }];
        }
        SSULogDebug(@"Finish %@",self.title);
    }];
}

#pragma mark - Private

- (void) buildJSON:(id)json {
    SSUDirectoryBuilder * builder = [[SSUDirectoryBuilder alloc] init];
    builder.context = self.backgroundContext;
    [builder build:json];
}



@end
