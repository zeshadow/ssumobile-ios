//
//  SSUCalendarModule.m
//  SSUMobile
//
//  Created by Eric Amorde on 9/8/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUCalendarModule.h"
#import "SSUCalendarBuilder.h"
#import "SSUMoonlightCommunicator.h"
#import "SSULogging.h"

@implementation SSUCalendarModule

+ (instancetype) sharedInstance {
    static SSUCalendarModule * instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - SSUModule

- (NSString *) title {
    return NSLocalizedString(@"Calendar",
                             @"The campus Calendar provides upcoming information on upcoming events");
}

- (UIView *) viewForHomeScreen {
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calendar_icon"]];
}

- (UIImage *) imageForHomeScreen {
    return [UIImage imageNamed:@"calendar_icon"];
}

- (UIViewController *) initialViewController {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Calendar_iPhone"
                                                          bundle:[NSBundle bundleForClass:[self class]]];
    return [storyboard instantiateInitialViewController];
}

- (void) setup {
    NSManagedObjectModel * model = [self modelWithName:@"Calendar"];
    NSPersistentStoreCoordinator * coordinator = [self persistentStoreCoordinatorWithName:@"Calendar" model:model];
    self.context = [self contextWithPersistentStoreCoordinator:coordinator];
    self.backgroundContext = [self backgroundContextFromContext:self.context];
}

- (void) clearCachedData {
    //TODO: implement clearCachedData
}

- (BOOL) showModuleInNavigationBar {
    return NO;
}

- (void) updateData:(void (^)())completion {
    SSULogDebug(@"Update Calendar NEW");
    NSString * lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:SSUUserDefaultsCalendarUpdatedDate];
    NSDate * date = (lastUpdate != nil) ? [self.dateFormatter dateFromString:lastUpdate] : nil;
    [SSUMoonlightCommunicator getJSONFromPath:@"calendar" sinceDate:date completion:^(id json, NSError *error) {
        if (error != nil) {
            SSULogError(@"Error while attemping to update Calendar: %@", error);
            if (completion) {
                completion();
            }
        }
        else {
            NSString * date = [self.dateFormatter stringFromDate:[NSDate date]];
            [[NSUserDefaults standardUserDefaults] setObject:date forKey:SSUUserDefaultsCalendarUpdatedDate];
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
    SSUCalendarBuilder * builder = [[SSUCalendarBuilder alloc] init];
    builder.context = self.backgroundContext;
    [builder build:json];
}

@end
