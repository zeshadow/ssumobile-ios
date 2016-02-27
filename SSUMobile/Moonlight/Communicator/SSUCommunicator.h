//
//  SSUCommunicator.h
//  SSUMobile
//
//  Created by Eric Amorde on 9/10/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SSUCommunicatorCompletion)(NSURLResponse * response, NSData * data, NSError * error);
typedef void(^SSUCommunicatorJSONCompletion)(NSURLResponse * response, id json, NSError * error);

@interface SSUCommunicator : NSObject

/**
 Create a POST request with form-encoded POST parameters
 */
+ (NSMutableURLRequest *) postRequestWithURL:(NSURL *)url parameters:(NSDictionary *)params;

/**
 Creates a GEt request with the given parameters encoded as a GET query string
 */
+ (NSMutableURLRequest *) getRequestWithURL:(NSURL *)url parameters:(NSDictionary *)params;

#pragma mark - Convenience

/**
 Get the contents at `url`
 */
+ (void) getURL:(NSURL *)url completion:(SSUCommunicatorCompletion)completion;

/**
 Retrieve the data from url and serialize it as JSON
 */
+ (void) getJSONFromURL:(NSURL *)url completion:(SSUCommunicatorJSONCompletion)completion;

/**
 Post the given parameters to the provided URL as form-encoded data
 */
+ (void) postURL:(NSURL *)url parameters:(NSDictionary *)params completion:(SSUCommunicatorCompletion)completion;

#pragma mark - Perform Request

/**
 Performs the given request and provides the NSURLResponse and data.
 */
+ (void) performRequest:(NSURLRequest *)request completion:(SSUCommunicatorCompletion)completion;

/**
 Performs the given request and serializes the response as JSON. The HTTP method of
 the request does not matter.
 */
+ (void) performJSONRequest:(NSURLRequest *)request completion:(SSUCommunicatorJSONCompletion)completion;

+ (id) serializeJSON:(NSData *)data;

@end
