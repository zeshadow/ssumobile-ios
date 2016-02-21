//
//  SSUEmailConstants.m
//  SSUMobile
//
//  Created by Eric Amorde on 2/7/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUEmailConstants.h"

NSString * const SSUEmailLDAPURL = @"https://login.sonoma.edu/";
NSString * const SSUEmailLDAPLoginURL = @"https://login.sonoma.edu/idp/profile/cas/login?execution=e3s1";
NSString * const SSUEmailMailURL = @"https://ldaps.sonoma.edu/portal/redir_exchange.cgi";
NSString * const SSUEmailGoogleDocsURL = @"https://drive.google.com/a/sonoma.edu";

NSString * const SSUEmailDomain = @"sonoma.edu";

NSString * const SSUEmailMySSULinkRange = @"<!-- Begin MySSU link -->";

NSString * const SSUEmailSessionIDRange = @"jsessionid=";
const NSInteger SSUEmailSessionIDLength = 32;

NSString * const SSUEmailLoginTokenRange = @"\"lt\" value=\"";
const NSInteger SSUEmailLoginTokenLength = 76;

NSString * const SSUEmailCookieNameSessionID = @"JSESSIONID";
