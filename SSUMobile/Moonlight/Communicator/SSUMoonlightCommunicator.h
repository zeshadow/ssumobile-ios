//
//  SSUMoonlightCommunicator.h
//  SSUMobile
//
//  Created by Andrew Huss on 1/22/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const SSUMoonlightManagerKeyID;
extern NSString* const SSUMoonlightManagerKeyCreated;
extern NSString* const SSUMoonlightManagerKeyModified;
extern NSString* const SSUMoonlightManagerKeyDeleted;

typedef void(^DownloadCompletion)(id json, NSError * error);

@interface SSUMoonlightCommunicator : NSObject

@property (nonatomic,getter=isCommunicating) BOOL communicating;

+ (SSUMoonlightCommunicator*) fetchURL:(NSURL*)url completionHandler:(void(^)(NSData* data, NSError* error))completionBlock;
+ (SSUMoonlightCommunicator*) postURL:(NSURL *)url parameters:(NSDictionary *)params completionHandler:(void(^)(NSData* data, NSError* error))completionBlock;
+ (NSURLRequest *) postRequestWithURL:(NSURL *)url parameters:(NSDictionary *)params;

+ (SSUMoonlightCommunicator *) getJSONFromURL:(NSURL *)url
                                   completion:(DownloadCompletion)completion;

+ (SSUMoonlightCommunicator *) getJSONFromPath:(NSString *)path
                                    completion:(DownloadCompletion)completion;

+ (SSUMoonlightCommunicator *) getJSONFromPath:(NSString *)path
                                     sinceDate:(NSDate *)date
                                    completion:(DownloadCompletion)completion;

- (void) getJSONFromURL:(NSURL *)url completion:(DownloadCompletion)completion;
- (void) getJSONFromPath:(NSString *)path completion:(DownloadCompletion)completion;
- (void) getJSONFromPath:(NSString *)path sinceDate:(NSDate *)date completion:(DownloadCompletion)completion;

- (void) cancelAndDiscardURLConnection;

@end
