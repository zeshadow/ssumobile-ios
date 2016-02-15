//
//  SSUNewsModule.m
//  SSUMobile
//
//  Created by Eric Amorde on 9/8/15.
//  Copyright (c) 2015 Computer Science. All rights reserved.
//

#import "SSUNewsModule.h"
#import "SSUMoonlightCommunicator.h"
#import "SSUNewsBuilder.h"
#import "SSULogging.h"

@implementation SSUNewsModule

+ (instancetype) sharedInstance {
    static SSUNewsModule * instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - SSUModule

- (NSString *) title {
    return NSLocalizedString(@"News",
                             @"The campus News provides upcoming information on upcoming events");
}

- (UIView *) viewForHomeScreen {
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"news_icon"]];
}

- (UIImage *) imageForHomeScreen {
    return [UIImage imageNamed:@"news_icon"];
}

- (UIViewController *) initialViewController {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"News_iPhone"
                                                          bundle:[NSBundle bundleForClass:[self class]]];
    return [storyboard instantiateInitialViewController];
}

- (BOOL) showModuleInNavigationBar {
    return NO;
}

- (void) setup {
    NSManagedObjectModel * model = [self modelWithName:@"News"];
    NSPersistentStoreCoordinator * coordinator = [self persistentStoreCoordinatorWithName:@"News" model:model];
    self.context = [self contextWithPersistentStoreCoordinator:coordinator];
    self.backgroundContext = [self backgroundContextFromContext:self.context];
}

- (void) clearCachedData {
    //TODO: implement clearCachedData
}

- (void) updateData:(void (^)())completion {
    SSULogDebug(@"Update News NEW");
    NSString * lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:SSUUserDefaultsNewsUpdatedDate];
    NSDate * date = (lastUpdate != nil) ? [self.dateFormatter dateFromString:lastUpdate] : nil;
    [SSUMoonlightCommunicator getJSONFromPath:@"news" sinceDate:date completion:^(id json, NSError *error) {
        if (error != nil) {
            SSULogError(@"Error while attemping to update News: %@", error);
            if (completion) {
                completion();
            }
        }
        else {
            NSString * date = [self.dateFormatter stringFromDate:[NSDate date]];
            [[NSUserDefaults standardUserDefaults] setObject:date forKey:SSUUserDefaultsNewsUpdatedDate];
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
    SSUNewsBuilder * builder = [[SSUNewsBuilder alloc] init];
    builder.context = self.backgroundContext;
    [builder build:json];
}


@end
