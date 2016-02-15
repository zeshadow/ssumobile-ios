//
//  SSUCommunicator.m
//  SSUMobile
//
//  Created by Eric Amorde on 9/10/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUCommunicator.h"
#import "SSULogging.h"

@interface SSUCommunicator()

@property (nonatomic, strong) NSURLSession * session;

@end

@implementation SSUCommunicator

static inline NSString * URLEncodedDictionary(NSDictionary * dictionary) {
    NSMutableString * postData = [NSMutableString new];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [postData appendString:[NSString stringWithFormat:@"%@=%@&",key,obj]];
    }];
    
    return [postData stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSURLSession *) session {
    if (_session) return _session;
    
    _session = [NSURLSession sharedSession];
    
    return _session;
}

- (NSURLRequest *) postRequestWithURL:(NSURL *)url parameters:(NSDictionary *)params {
    NSString * postData = URLEncodedDictionary(params);
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[postData stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)request.HTTPBody.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    return request;
}

- (void) getURL:(NSURL *)url completion:(DownloadCompletion)completion {
    [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        completion(data, error);
    }];
}

- (void) getJSONFromURL:(NSURL *)url completion:(JSONDownloadCompletion)completion {
    if (completion == NULL) {
        // Downloading it without doing anything with it is worthless
        return;
    }
    [self getURL:url completion:^(NSData *data, NSError *error) {
        if (error) {
            SSULogError(@"Error while downloading JSON: %@",error);
            completion(nil, error);
        }
        else if (data) {
            id json = [self serializeJSON:data];
            completion(json, error);
        }
    }];
}

- (void) postURL:(NSURL *)url parameters:(NSDictionary *)params completion:(DownloadCompletion)completion {
    NSURLRequest * request = [self postRequestWithURL:url parameters:params];
    [self.session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
    }];
}

#pragma mark - Private

- (id) serializeJSON:(NSData *)data {
    NSError * error;
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        SSULogError(@"Error while attempting to serialize JSON object: %@", error);
    }
    return json;
}

@end
