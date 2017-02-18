//
//  SSUModuleServices.h
//  SSUMobile
//
//  Created by Eric Amorde on 08/17/2016.
//  Copyright © 2016 Sonoma State University Department of Computer Science. All rights reserved.
//

@import Foundation;
#import "SSUModuleBase.h"

extern NSString * const SSUModulesEnabledKey;
extern NSString * const SSUModulesDidLoadNotification;


@interface SSUModuleServices : NSObject

/** All SSUModule(UI) instances that were loaded on launch */
@property (nonatomic, readonly) NSArray * modules;

/** All SSUModuleUI instances */
@property (nonatomic, readonly) NSArray * modulesUI;

+ (instancetype) sharedInstance;
- (void) loadModules;

- (NSArray<id> *) modulesConformingToProtocol:(Protocol *)protocol;
- (id<SSUModule>) moduleWithIdentifier:(NSString *)identifier;

- (void) updateAll;
- (void) setupAll;

@end
