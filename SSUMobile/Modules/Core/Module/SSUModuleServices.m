//
//  SSUModuleServices.m
//  SSUMobile
//
//  Created by Eric Amorde on 08/17/2016.
//  Copyright © 2016 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUModuleServices.h"
#import "SSUConfiguration.h"

NSString * const SSUModulesEnabledKey = @"edu.sonoma.modules.enabled";
NSString * const SSUModulesDidLoadNotification = @"edu.sonoma.modules.loaded.notification";

@interface SSUModuleServices()

/** All SSUModule(UI) instances that were loaded on launch */
@property (nonatomic, readwrite) NSArray * modules;
/** All SSUModuleUI instances */
@property (nonatomic, readwrite) NSArray * modulesUI;

@end

@implementation SSUModuleServices

+ (instancetype) sharedInstance {
    static SSUModuleServices * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void) loadModules {
    NSMutableArray * moduleObjects = (id)[NSMutableArray new];
    for (NSString * className in [self moduleClasses]) {
        Class cls = NSClassFromString(className);
        SSUModuleBase<SSUModule> * module = [cls sharedInstance];
        NSAssert([module conformsToProtocol:@protocol(SSUModule)], @"Module with name %@ does not conform to the %@ protocol", className, NSStringFromProtocol(@protocol(SSUModule)));
        [moduleObjects addObject:module];
    }
    
    self.modules = moduleObjects;
    self.modulesUI = [self modulesConformingToProtocol:@protocol(SSUModuleUI)];
    [[NSNotificationCenter defaultCenter] postNotificationName:SSUModulesDidLoadNotification object:self.modules];
}

- (void) reloadModules {
    self.modules = nil;
    self.modulesUI = nil;
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

- (NSArray *) modules {
    if (_modules) return _modules;
    
    NSMutableArray * moduleObjects = (id)[NSMutableArray new];
    for (NSString * className in [self moduleClasses]) {
        Class cls = NSClassFromString(className);
        SSUModuleBase<SSUModule> * module = [cls sharedInstance];
        NSAssert([module conformsToProtocol:@protocol(SSUModule)], @"Module with name %@ does not conform to the %@ protocol", className, NSStringFromProtocol(@protocol(SSUModule)));
        [moduleObjects addObject:module];
    }
    
    _modules = [moduleObjects copy];
    
    return _modules;
}

- (NSArray *) modulesUI {
    if (_modulesUI) return _modulesUI;
    
    NSMutableArray * moduleObjects = [NSMutableArray new];
    for (SSUModuleBase<SSUModule> * module in self.modules) {
        if ([module conformsToProtocol:@protocol(SSUModuleUI)]) {
            [moduleObjects addObject:module];
        }
    }
    
    _modulesUI = (id)[self modulesConformingToProtocol:@protocol(SSUModuleUI)];
    
    return _modulesUI;
}

- (id<SSUModule>) moduleWithIdentifier:(NSString *)identifier {
    for (SSUModuleBase<SSUModule> * module in self.modules) {
        if ([module.identifier isEqualToString:identifier]) {
            return module;
        }
    }
    return nil;
}

- (NSArray *) modulesConformingToProtocol:(Protocol *)protocol {
    NSMutableArray * conformingModules = [NSMutableArray new];
    for (id<SSUModule> module in self.modules) {
        if ([module conformsToProtocol:protocol]) {
            [conformingModules addObject:module];
        }
    }
    return conformingModules;
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


@end
