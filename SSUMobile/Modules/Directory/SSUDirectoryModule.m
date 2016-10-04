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
#import "SSUConfiguration.h"
#import "SSUDirectorySpotlightUtilities.h"
#import "SSUDirectoryViewController.h"

@import CoreSpotlight;
@import MobileCoreServices;

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

- (nonnull NSString *) title {
    return NSLocalizedString(@"Directory",
                             @"The campus directory containing the contact information of faculty and staff");
}

- (nonnull NSString *) identifier {
    return @"directory";
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

- (BOOL) shouldNavigateToModule {
    return YES;
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
    SSULogDebug(@"Update Directory");
    
    [self updateBuildings:^{
        [self updateSchools:^{
            [self updateDepartments:^{
                [self updatePeople:^{
                    if (completion != NULL) {
                        completion();
                    }
                    [SSUDirectorySpotlightUtilities populateIndex:[CSSearchableIndex defaultSearchableIndex] context:self.backgroundContext domain:nil];
                }];
            }];
        }];
    }];
}

- (void) updatePeople:(void(^)())completion {
    NSDate * date = [[SSUConfiguration sharedInstance] dateForKey:SSUDirectoryPersonUpdatedDateKey];
    [SSUMoonlightCommunicator getJSONFromPath:@"directory/person/" sinceDate:date completion:^(id json, NSError *error) {
        if (error != nil) {
            SSULogError(@"Error while attemping to update directory person: %@", error);
            if (completion) {
                completion();
            }
        }
        else {
            [self buildPerson:json completion:^{
                [[SSUConfiguration sharedInstance] setDate:[NSDate date] forKey:SSUDirectoryPersonUpdatedDateKey];
                if (completion) {
                    completion();
                }
            }];
        }
        SSULogDebug(@"Finish %@",self.title);
    }];
}

- (void) updateDepartments:(void(^)())completion {
    NSDate * date = [[SSUConfiguration sharedInstance] dateForKey:SSUDirectoryDepartmentUpdatedDateKey];
    [SSUMoonlightCommunicator getJSONFromPath:@"directory/department/" sinceDate:date completion:^(id json, NSError *error) {
        if (error != nil) {
            SSULogError(@"Error while attemping to update directory departments: %@", error);
            if (completion) {
                completion();
            }
        }
        else {
            [self buildDepartment:json completion:^{
                [[SSUConfiguration sharedInstance] setDate:[NSDate date] forKey:SSUDirectoryDepartmentUpdatedDateKey];
                if (completion) {
                    completion();
                }
            }];
        }
        SSULogDebug(@"Finish %@",self.title);
    }];
}

- (void) updateSchools:(void(^)())completion {
    NSDate * date = [[SSUConfiguration sharedInstance] dateForKey:SSUDirectorySchoolUpdatedDateKey];
    [SSUMoonlightCommunicator getJSONFromPath:@"directory/school/" sinceDate:date completion:^(id json, NSError *error) {
        if (error != nil) {
            SSULogError(@"Error while attemping to update directory schools: %@", error);
            if (completion) {
                completion();
            }
        }
        else {
            [self buildSchool:json completion:^{
                [[SSUConfiguration sharedInstance] setDate:[NSDate date] forKey:SSUDirectorySchoolUpdatedDateKey];
                if (completion) {
                    completion();
                }
            }];
        }
        SSULogDebug(@"Finish %@",self.title);
    }];
}

- (void) updateBuildings:(void(^)())completion {
    NSDate * date = [[SSUConfiguration sharedInstance] dateForKey:SSUDirectoryBuildingUpdatedDateKey];
    [SSUMoonlightCommunicator getJSONFromPath:@"directory/building/" sinceDate:date completion:^(id json, NSError *error) {
        if (error != nil) {
            SSULogError(@"Error while attemping to update directory buildings: %@", error);
            if (completion) {
                completion();
            }
        }
        else {
            [self buildBuilding:json completion:^{
                [[SSUConfiguration sharedInstance] setDate:[NSDate date] forKey:SSUDirectoryBuildingUpdatedDateKey];
                if (completion) {
                    completion();
                }
            }];
        }
        SSULogDebug(@"Finish %@",self.title);
    }];
}

#pragma mark - Private

- (void) buildPerson:(NSArray *)personData completion:(void(^)(void))completion {
    SSUDirectoryBuilder * builder = [[SSUDirectoryBuilder alloc] init];
    builder.context = [self newBackgroundContext];
    [builder.context performBlock:^{
        [builder buildPeople:personData];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    }];
}

- (void) buildDepartment:(NSArray *)departmentData completion:(void(^)(void))completion {
    SSUDirectoryBuilder * builder = [[SSUDirectoryBuilder alloc] init];
    builder.context = [self newBackgroundContext];
    [builder.context performBlock:^{
        [builder buildDepartments:departmentData];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    }];
}

- (void) buildSchool:(NSArray *)schoolData completion:(void(^)(void))completion {
    SSUDirectoryBuilder * builder = [[SSUDirectoryBuilder alloc] init];
    builder.context = [self newBackgroundContext];
    [builder.context performBlock:^{
        [builder buildSchools:schoolData];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    }];
}

- (void) buildBuilding:(NSArray *)buildingData completion:(void(^)(void))completion {
    SSUDirectoryBuilder * builder = [[SSUDirectoryBuilder alloc] init];
    builder.context = [self newBackgroundContext];
    [builder.context performBlock:^{
        [builder buildBuildings:buildingData];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    }];
}

#pragma mark - Spotlight

- (void) searchableIndex:(CSSearchableIndex *)index reindexItemWithIdentifier:(NSString *)identifier {
    [SSUDirectorySpotlightUtilities searchableIndex:index reindexItem:identifier inContext:self.backgroundContext domain:self.identifier];
}

- (void) searchAbleIndexRequestingUpdate:(CSSearchableIndex *)index {
    [SSUDirectorySpotlightUtilities populateIndex:index context:self.backgroundContext domain:self.identifier];
}

- (BOOL) recognizesIdentifier:(NSString *)identifier {
    return YES;
}

- (UIViewController *) viewControllerForSearchableItemWithIdentifier:(NSString *)identfier {
    SSUDirectoryViewController * vc = [SSUDirectoryViewController instantiateFromStoryboard];
    vc.objectToDisplay = [SSUDirectorySpotlightUtilities objectForIdentifier:identfier];
    return vc;
}

@end
