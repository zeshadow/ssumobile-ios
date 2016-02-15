//
//  SSUConfiguration.h
//  SSUMobile
//
//  Created by Eric Amorde on 9/16/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSUConfiguration : NSObject

+ (instancetype) sharedInstance;

- (id) objectForKey:(NSString *)key;
- (NSArray *) stringArrayForKey:(NSString *)key;
- (NSInteger) integerForKey:(NSString *)key;
- (float) floatForKey:(NSString *)key;
- (double) doubleForKey:(NSString *)key;
- (BOOL) boolForKey:(NSString *)key;
- (NSURL *) URLForKey:(NSString *)key;


- (void) setObject:(id)value forKey:(NSString *)key;
- (void) setInteger:(NSInteger)value forKey:(NSString *)key;
- (void) setFloat:(float)value forKey:(NSString *)key;
- (void) setDouble:(double)value forKey:(NSString *)key;
- (void) setBool:(BOOL)value forKey:(NSString *)key;
- (void) setURL:(NSURL *)value forKey:(NSString *)key;

- (void) removeObjectForKey:(NSString *)key;

@end
