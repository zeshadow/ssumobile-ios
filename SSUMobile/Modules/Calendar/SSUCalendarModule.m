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
#import "SSUConfiguration.h"

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

- (nonnull NSString *) title {
    return NSLocalizedString(@"Calendar",
                             @"The campus Calendar provides upcoming information on upcoming events");
}

- (nonnull NSString *) identifier {
    return @"calendar";
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

- (BOOL) shouldNavigateToModule {
    return YES;
}

- (void) updateData:(void (^)())completion {
    SSULogDebug(@"Update Calendar");
    NSDate * date = [[SSUConfiguration sharedInstance] dateForKey:SSUCalendarUpdatedDateKey];
    [SSUMoonlightCommunicator getJSONFromPath:@"events/event/" sinceDate:nil completion:^(NSURLResponse * response, id json, NSError * error) {
        if (error != nil) {
            SSULogError(@"Error while attemping to update Calendar: %@", error);
            if (completion) {
                completion();
            }
        }
        else {
            [[SSUConfiguration sharedInstance] setObject:[NSDate date] forKey:SSUCalendarUpdatedDateKey];
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
