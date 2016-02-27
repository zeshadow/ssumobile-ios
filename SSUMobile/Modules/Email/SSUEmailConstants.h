//
//  SSUEmailConstants.h
//  SSUMobile
//
//  Created by Eric Amorde on 2/7/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

@import Foundation;

extern NSString * const SSUEmailLDAPURL;
extern NSString * const SSUEmailLDAPLoginURL;
extern NSString * const SSUEmailMailURL;
extern NSString * const SSUEmailGoogleDocsURL;

extern NSString * const SSUEmailDomain;

extern NSString * const SSUEmailMySSULinkRange;

extern NSString * const SSUEmailSessionIDRange;
extern const NSInteger SSUEmailSessionIDLength;

extern NSString * const SSUEmailLoginTokenRange;
extern const NSInteger SSUEmailLoginTokenLength;

extern NSString * const SSUEmailCookieNameSessionID;

/**
 Defines whether or not custom login is enabled. If disabled, the user
 should be taken to the login page on Sonoma's website instead of being
 shown a custom login interface.
 */
extern NSString * const SSUEmailLoginEnabledKey;