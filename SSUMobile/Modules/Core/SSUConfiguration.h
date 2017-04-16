//
//  SSUConfiguration.h
//  SSUMobile
//
//  Created by Eric Amorde on 9/16/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kSSUConfigLastLoadDateKey;

@interface SSUConfiguration : NSObject

+ (instancetype) sharedInstance;

#pragma mark - Getters

- (id) objectForKey:(NSString *)key;
- (NSString * _Nullable) stringForKey:(NSString *)key;
- (NSDate * _Nullable) dateForKey:(NSString *)key;
- (NSArray <NSString *> *  _Nullable) stringArrayForKey:(NSString *)key;
- (NSInteger) integerForKey:(NSString *)key;
- (float) floatForKey:(NSString *)key;
- (double) doubleForKey:(NSString *)key;
- (BOOL) boolForKey:(NSString *)key;
- (NSURL * _Nullable) URLForKey:(NSString *)key;
- (NSDictionary *) dictionaryRepresentation;

#pragma mark - Setters

- (void) setObject:(id)value forKey:(NSString *)key;
- (void) setArray:(NSArray * _Nullable)array forKey:(NSString *)key;
- (void) setDate:(NSDate * _Nullable)date forKey:(NSString *)key;
- (void) setString:(NSString * _Nullable)string forKey:(NSString *)key;
- (void) setStringArray:(NSArray <NSString *> * _Nullable)stringArray forKey:(NSString *)key;
- (void) setInteger:(NSInteger)value forKey:(NSString *)key;
- (void) setFloat:(float)value forKey:(NSString *)key;
- (void) setDouble:(double)value forKey:(NSString *)key;
- (void) setBool:(BOOL)value forKey:(NSString *)key;
- (void) setURL:(NSURL * _Nullable)value forKey:(NSString *)key;
- (void) removeObjectForKey:(NSString *)key;

#pragma mark - Helper

- (void) registerDefaults:(NSDictionary *)defaults;
- (void) loadDictionary:(NSDictionary *)data;
- (void) loadFromURL:(NSURL *)url completion:(void(^)(NSError * _Nullable error))completion;
- (void) loadDefaultsFromFilePath:(NSString *)filePath;
- (void) save;

@end

NS_ASSUME_NONNULL_END
