//
//  SSUMapModule.m
//  SSUMobile
//
//  Created by Eric Amorde on 9/8/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUMapModule.h"
#import "SSULogging.h"
#import "SSUPointsBuilder.h"
#import "SSUBuildingPerimetersBuilder.h"
#import "SSUConnectionsBuilder.h"
#import "SSUMoonlightCommunicator.h"
#import "SSUConfiguration.h"

@implementation SSUMapModule

+ (instancetype) sharedInstance {
    static SSUMapModule * instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - SSUModule

- (nonnull NSString *) title {
    return NSLocalizedString(@"Map",
                             @"The campus Map shows the location of campus buildings and provides directions");
}

- (nonnull NSString *) identifier {
    return @"campusmap";
}

- (UIView *) viewForHomeScreen {
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_icon"]];
}

- (UIImage *) imageForHomeScreen {
    return [UIImage imageNamed:@"map_icon"];
}

- (UIViewController *) initialViewController {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Map_iPhone"
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
    NSManagedObjectModel * model = [self modelWithName:@"Map"];
    NSPersistentStoreCoordinator * coordinator = [self persistentStoreCoordinatorWithName:@"Map" model:model];
    self.context = [self contextWithPersistentStoreCoordinator:coordinator];
    self.backgroundContext = [self backgroundContextFromContext:self.context];
}

- (void) clearCachedData {
    //TODO: implement clearCachedData
}

- (void) updateData:(void (^)())completion {
    SSULogDebug(@"Update Map NEW");
    __block int count = 0;
    int total = 3;
    [self updatePoints:^{
        count++;
        if (count == total && completion) {
            completion();
        }
    }];
    [self updatePerimeters:^{
        count++;
        if (count == total && completion) {
            completion();
        }
    }];
    [self updateConnections:^{
        count++;
        if (count == total && completion) {
            completion();
        }
    }];
}

- (void) updatePoints:(void (^)())completion {
    if (completion) completion();
    return;
    NSDate * date = [[SSUConfiguration sharedInstance] dateForKey:SSUMapPointsUpdatedDateKey];
    [SSUMoonlightCommunicator getJSONFromPath:@"points" sinceDate:date completion:^(id json, NSError *error) {
        if (error != nil) {
            SSULogError(@"Error while attemping to update Map points: %@", error);
            if (completion) {
                completion();
            }
        }
        else {
            [self.backgroundContext performBlock:^{
                [[SSUConfiguration sharedInstance] setDate:[NSDate date] forKey:SSUMapPointsUpdatedDateKey];
                [self buildPointsJSON:json];
                if (completion) {
                    completion();
                }
            }];
        }
        SSULogDebug(@"Finish %@",self.title);
    }];
}

- (void) updatePerimeters:(void (^)())completion {
    if (completion) completion();
    return;
    NSDate * date = [[SSUConfiguration sharedInstance] dateForKey:SSUMapPerimetersUpdatedDateKey];
    [SSUMoonlightCommunicator getJSONFromPath:@"perimeters" sinceDate:date completion:^(id json, NSError *error) {
        if (error != nil) {
            SSULogError(@"Error while attemping to update Map perimeters: %@", error);
            if (completion) {
                completion();
            }
        }
        else {
            [self.backgroundContext performBlock:^{
                [[SSUConfiguration sharedInstance] setDate:[NSDate date] forKey:SSUMapPerimetersUpdatedDateKey];
                [self buildPerimetersJSON:json];
                if (completion) {
                    completion();
                }
            }];
        }
    }];
}

- (void) updateConnections:(void (^)())completion {
    if (completion) completion();
    return;
    NSDate * date = [[SSUConfiguration sharedInstance] dateForKey:SSUMapPerimetersUpdatedDateKey];
    [SSUMoonlightCommunicator getJSONFromPath:@"connections" sinceDate:date completion:^(id json, NSError *error) {
        if (error != nil) {
            SSULogError(@"Error while attemping to update Map connections: %@", error);
            if (completion) {
                completion();
            }
        }
        else {
            [self.backgroundContext performBlock:^{
                [[SSUConfiguration sharedInstance] setDate:[NSDate date] forKey:SSUMapPerimetersUpdatedDateKey];
                [self buildConnectionsJSON:json];
                if (completion) {
                    completion();
                }
            }];
        }
    }];
}

#pragma mark - Private

- (void) buildPointsJSON:(id)json {
    SSUPointsBuilder * builder = [[SSUPointsBuilder alloc] init];
    builder.context = [self backgroundContextFromContext:self.context];
    [builder build:json];
}

- (void) buildPerimetersJSON:(id)json {
    SSUBuildingPerimetersBuilder * builder = [[SSUBuildingPerimetersBuilder alloc] init];
    builder.context = self.backgroundContext;
    [builder build:json];
}

- (void) buildConnectionsJSON:(id)json {
    SSUConnectionsBuilder * builder = [[SSUConnectionsBuilder alloc] init];
    builder.context = self.backgroundContext;
    [builder build:json];
}

@end
