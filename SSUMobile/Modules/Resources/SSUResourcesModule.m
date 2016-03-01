//
//  SSUResourcesModule.m
//  SSUMobile
//
//  Created by Eric Amorde on 9/8/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUResourcesModule.h"
#import "SSUResourcesBuilder.h"
#import "SSUMoonlightCommunicator.h"
#import "SSULogging.h"
#import "SSUConfiguration.h"

@implementation SSUResourcesModule

+ (instancetype) sharedInstance {
    static SSUResourcesModule * instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - SSUModule

- (NSString *) title {
    return NSLocalizedString(@"Resources",
                             @"Campus resources, such as phone numbers and web links");
}

- (UIView *) viewForHomeScreen {
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"resources_icon"]];
}

- (UIImage *) imageForHomeScreen {
    return [UIImage imageNamed:@"resources_icon"];
}

- (UIViewController *) initialViewController {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Resources"
                                                          bundle:[NSBundle bundleForClass:[self class]]];
    return [storyboard instantiateInitialViewController];
}

- (BOOL) showModuleInNavigationBar {
    return NO;
}

- (BOOL) shouldNavigateToModule {
    return YES;
}

- (void) setup {
    NSManagedObjectModel * model = [self modelWithName:@"Resources"];
    NSPersistentStoreCoordinator * coordinator = [self persistentStoreCoordinatorWithName:@"Resources" model:model];
    self.context = [self contextWithPersistentStoreCoordinator:coordinator];
    self.backgroundContext = [self backgroundContextFromContext:self.context];
}

- (void) clearCachedData {
    //TODO: implement clearCachedData
}

- (void) updateData:(void (^)())completion {
    SSULogDebug(@"Update Resources NEW");
    NSDate * date = [[SSUConfiguration sharedInstance] dateForKey:SSUResourcesUpdatedDateKey];
    [SSUMoonlightCommunicator getJSONFromPath:@"resources.json" sinceDate:date completion:^(id json, NSError *error) {
        if (error != nil) {
            SSULogError(@"Error while attemping to update Resources: %@", error);
            if (completion) {
                completion();
            }
        }
        else {
            [self.backgroundContext performBlock:^{
                [[SSUConfiguration sharedInstance] setDate:[NSDate date] forKey:SSUResourcesUpdatedDateKey];
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
    SSUResourcesBuilder * builder = [[SSUResourcesBuilder alloc] init];
    builder.context = self.backgroundContext;
    [builder build:json];
}

@end
