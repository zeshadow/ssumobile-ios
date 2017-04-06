//
//  SSULDAPController.h
//  SSUMobile
//
//  Created by Eric Amorde on 2/7/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

@import Foundation;

@interface SSULDAPCredentials : NSObject

+ (instancetype) sharedInstance;

@property (nonatomic) NSString * username;
@property (nonatomic) NSString * password;
@property (nonatomic) BOOL hasCredentials;
@property (nonatomic) BOOL rememberLogin;

/**
 Clear all stored credentials and set the 'remember' flag to false
 */
- (void) clearCredentials;

/**
 Save to disk
 */
- (void) save;

@end
