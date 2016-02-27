//
//  SSUEmailConstants.h
//  SSUMobile
//
//  Created by Eric Amorde on 2/7/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

@import Foundation;

extern NSString * const SSUEmailLDAPURLKey;
extern NSString * const SSUEmailLDAPLoginURLKey;
extern NSString * const SSUEmailMailURLKey;
extern NSString * const SSUEmailGoogleDocsURLKey;

extern NSString * const SSUEmailDomainKey;

extern NSString * const SSUEmailMySSULinkRangeKey;

extern NSString * const SSUEmailSessionIDRangeKey;
extern const NSInteger SSUEmailSessionIDLengthKey;

extern NSString * const SSUEmailCookieNameSessionIDKey;

/**
 Defines whether or not custom login is enabled. If disabled, the user
 should be taken to the login page on Sonoma's website instead of being
 shown a custom login interface.
 */
extern NSString * const SSUEmailLoginEnabledKey;