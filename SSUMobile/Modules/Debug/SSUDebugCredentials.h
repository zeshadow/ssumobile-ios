//
//  SSUDebugCredentials.h
//  SSUMobile
//
//  Created by Eric Amorde on 2/8/16.
//  Copyright © 2016 Sonoma State University Department of Computer Science. All rights reserved.
//

@import Foundation;

@interface SSUDebugCredentials : NSObject

/**
 If not already requested, will prompt the user for credentials to be submitted for authorization.
 If authorization is successfull, the `token` static property will be available for use in future API requests.
 */
+ (void) requestCredentials;

/**
 API token, if authorization was successfull
 */
+ (NSString *) token;

/** 
 Returns a new request with the necessary headers for a request to be authenticated, if a token is available 
 */
+ (NSURLRequest *) authenticatedRequestFromRequest:(NSURLRequest *)request;

@end
