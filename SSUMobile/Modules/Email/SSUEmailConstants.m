//
//  SSUEmailConstants.m
//  SSUMobile
//
//  Created by Eric Amorde on 2/7/15.
//  Copyright (c) 2015 Computer Science. All rights reserved.
//

#import "SSUEmailConstants.h"

const NSString * SSUEmailLDAPURL = @"https://login.sonoma.edu/cas-server/login?service=https://ldaps.sonoma.edu/portal/index.cgi";
const NSString * SSUEmailGmailURL = @"https://mail.google.com/a/seawolf.sonoma.edu";
const NSString * SSUEmailExchangeURL = @"https://ldaps.sonoma.edu/portal/redir_exchange.cgi";
const NSString * SSUEmailGoogleDocsURL = @"https://drive.google.com/a/sonoma.edu";

const NSString * SSUEmailExchangeDomain = @"sonoma.edu";
const NSString * SSUEmailGmailDomain = @"seawolf.sonoma.edu";
const NSString * SSUEmailDomain = @"sonoma.edu";

const NSString * SSUEmailMySSULinkRange = @"<!-- Begin MySSU link -->";

const NSString * SSUEmailSessionIDRange = @"jsessionid=";
const NSInteger SSUEmailSessionIDLength = 32;

const NSString * SSUEmailLoginTokenRange = @"\"lt\" value=\"";
const NSInteger SSUEmailLoginTokenLength = 76;

const NSString * SSUEmailCookieNameSessionID = @"JSESSIONID";
