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

- (nonnull NSString *) title {
    return NSLocalizedString(@"Resources",
                             @"Campus resources, such as phone numbers and web links");
}

- (nonnull NSString *) identifier {
    return @"directory";
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
    SSULogDebug(@"Update Resources");
    [self updateSections:^{
        [self updateResources:^{
            if (completion) {
                completion();
            }
        }];
    }];
}


- (void) updateSections:(void (^)())completion {
    SSULogDebug(@"Update Resource Sections");
    NSDate * date = [[SSUConfiguration sharedInstance] dateForKey:SSUResourcesSectionsUpdatedDateKey];
    [SSUMoonlightCommunicator getJSONFromPath:@"ssumobile/resources/section" sinceDate:date completion:^(NSURLResponse * response, id json, NSError * error) {
        if (error != nil) {
            SSULogError(@"Error while attemping to update resource Sections: %@", error);
            if (completion) {
                completion();
            }
        }
        else {
            [[SSUConfiguration sharedInstance] setDate:[NSDate date] forKey:SSUResourcesSectionsUpdatedDateKey];
            [self.backgroundContext performBlock:^{
                [self buildSections:json];
                if (completion) {
                    completion();
                }
            }];
        }
        SSULogDebug(@"Finish %@",self.title);
    }];
}

- (void) updateResources:(void (^)())completion {
    SSULogDebug(@"Update Resource Sections");
    NSDate * date = [[SSUConfiguration sharedInstance] dateForKey:SSUResourcesResourcesUpdatedDateKey];
    [SSUMoonlightCommunicator getJSONFromPath:@"ssumobile/resources/resource" sinceDate:date completion:^(NSURLResponse * response, id json, NSError * error) {
        if (error != nil) {
            SSULogError(@"Error while attemping to update Resources: %@", error);
            if (completion) {
                completion();
            }
        }
        else {
            [[SSUConfiguration sharedInstance] setDate:[NSDate date] forKey:SSUResourcesResourcesUpdatedDateKey];
            [self.backgroundContext performBlock:^{
                [self buildResources:json];
                if (completion) {
                    completion();
                }
            }];
        }
        SSULogDebug(@"Finish %@",self.title);
    }];
}

#pragma mark - Private

- (void) buildResources:(id)json {
    SSUResourcesBuilder * builder = [[SSUResourcesBuilder alloc] init];
    builder.context = self.backgroundContext;
    [builder buildResources:json];
}


- (void) buildSections:(id)json {
    SSUResourcesBuilder * builder = [[SSUResourcesBuilder alloc] init];
    builder.context = self.backgroundContext;
    [builder buildSections:json];
}

@end
