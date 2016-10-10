//
//  SSUCommunicator.h
//  SSUMobile
//
//  Created by Eric Amorde on 9/10/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

@import Foundation;

typedef void(^SSUCommunicatorCompletion)(NSURLResponse * response, NSData * data, NSError * error);
typedef void(^SSUCommunicatorJSONCompletion)(NSURLResponse * response, id json, NSError * error);

@interface SSUCommunicator : NSObject

#pragma mark - Accessor

+ (NSDateFormatter *) dateFormatter;

#pragma mark Creating URL Requests

/**
Creates a GET request with the given parameters encoded as a GET query string
 */
+ (NSMutableURLRequest *) getRequestWithURL:(NSURL *)url parameters:(NSDictionary *)params;

/**
 Create a POST request with form-encoded POST parameters
 */
+ (NSMutableURLRequest *) postRequestWithURL:(NSURL *)url parameters:(NSDictionary *)params;

/**
 Create a PUT request with form-encoded POST parameters
 */
+ (NSMutableURLRequest *) putRequestWithURL:(NSURL *)url parameters:(NSDictionary *)params;

/**
 Create a UPDATE request with form-encoded POST parameters
 */
+ (NSMutableURLRequest *) updateRequestWithURL:(NSURL *)url parameters:(NSDictionary *)params;

/**
 Create a DELETE request with form-encoded POST parameters
 */
+ (NSMutableURLRequest *) deleteRequestWithURL:(NSURL *)url parameters:(NSDictionary *)params;

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
 Retrieve the data from url and serialize it as JSON, retrieving only the records having changed since date
 */
+ (void) getJSONFromURL:(NSURL *)url sinceDate:(NSDate *)date completion:(SSUCommunicatorJSONCompletion)completion;

/**
 Retrieve the data from url and serialize it as JSON, retrieving only the records having changed since date
 */
+ (void) getJSONFromURL:(NSURL *)url sinceDate:(NSDate *)date params:(NSDictionary *)params completion:(SSUCommunicatorJSONCompletion)completion;

/**
 Posts the given parameters to the provided URL as form-encoded data
 */
+ (void) postURL:(NSURL *)url parameters:(NSDictionary *)params completion:(SSUCommunicatorCompletion)completion;

/**
 Posts the given parameters to the provided URL as form-encoded data and parses the response as JSON
 */
+ (void) postJSONURL:(NSURL *)url parameters:(NSDictionary *)params completion:(SSUCommunicatorJSONCompletion)completion;

+ (void) putURL:(NSURL *)url parameters:(NSDictionary *)params completion:(SSUCommunicatorCompletion)completion;
+ (void) putJSONURL:(NSURL *)url parameters:(NSDictionary *)params completion:(SSUCommunicatorJSONCompletion)completion;

+ (void) updateURL:(NSURL *)url parameters:(NSDictionary *)params completion:(SSUCommunicatorCompletion)completion;
+ (void) updateJSONURL:(NSURL *)url parameters:(NSDictionary *)params completion:(SSUCommunicatorJSONCompletion)completion;

+ (void) deleteURL:(NSURL *)url parameters:(NSDictionary *)params completion:(SSUCommunicatorCompletion)completion;
+ (void) deleteJSONURL:(NSURL *)url parameters:(NSDictionary *)params completion:(SSUCommunicatorJSONCompletion)completion;

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
