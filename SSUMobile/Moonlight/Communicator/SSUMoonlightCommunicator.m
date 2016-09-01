//
//  SSUMoonlightCommunicator.m
//  SSUMobile
//
//  Created by Andrew Huss on 1/22/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

@import UIKit;

#import "SSUMoonlightCommunicator.h"
#import "SSULogging.h"

static NSString* const SSUMoonlightCommunicatorErrorDomain = @"SSUMoonlightCommunicatorErrorDomain";

@interface SSUMoonlightCommunicator()

@property (nonatomic, copy) void (^successHandler)(NSData*);
@property (nonatomic, copy) void (^errorHandler)(NSError*);

@property (strong, nonatomic) NSURL* fetchingURL;
@property (strong, nonatomic) NSURLConnection* fetchingConnection;
@property (strong, nonatomic) NSMutableData* receivedData;
@property (strong, nonatomic) NSDateFormatter * dateFormatter;

@end

@implementation SSUMoonlightCommunicator

+ (NSArray*) trustedHosts {
    //TODO: Separate moonlight communication and LDAP
    static NSArray * hosts = nil;
    if (hosts == nil) {
        hosts = @[
                  @"moonlight.cs.sonoma.edu",
                  @"login.sonoma.edu",
                  @"ldaps.sonoma.edu",
                  ];
    }
    return hosts;
}

static inline NSString * URLEncodedDictionary(NSDictionary * dictionary) {
    NSMutableString * postData = [NSMutableString new];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [postData appendString:[NSString stringWithFormat:@"%@=%@&",key,obj]];
    }];
    
    return [postData stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSDateFormatter *) dateFormatter {
    if (_dateFormatter) return _dateFormatter;
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.dateStyle = NSDateFormatterNoStyle;
    _dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    _dateFormatter.locale = [NSLocale currentLocale];
    _dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    return _dateFormatter;
}

#pragma mark - Network Activity Indicator

+ (void) setNetworkActivityIndicatorVisible:(BOOL)visible {
    static int count = 0;
    count += (visible) ? 1 : -1;
    count = MAX(count,0);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(count > 0)];
}

- (void) setCommunicating:(BOOL)communicating {
    // Only activate the indicator if the value has changed
    if (_communicating != communicating) {
        [SSUMoonlightCommunicator setNetworkActivityIndicatorVisible:communicating];
        _communicating = communicating;
    }
}

#pragma mark - Downloads
+ (SSUMoonlightCommunicator*) fetchURL:(NSURL*)url completionHandler:(void(^)(NSData* data, NSError* error))completionBlock {
    NSParameterAssert(url);
    SSUMoonlightCommunicator* communicator = [[SSUMoonlightCommunicator alloc] init];
    [communicator fetchContentAtURL:url
               errorHandler:^(NSError* error) {
                   completionBlock(nil, error);
               }
             successHandler:^(NSData* data) {
                 completionBlock(data, nil);
             }];
    return communicator;
}

+ (SSUMoonlightCommunicator*) postURL:(NSURL *)url parameters:(NSDictionary *)params completionHandler:(void(^)(NSData* data, NSError* error))completionBlock {
    NSParameterAssert(url);
    SSUMoonlightCommunicator* communicator = [[SSUMoonlightCommunicator alloc] init];
    [communicator postURL:url parameters:params errorHandler:^(NSError *error) {
        completionBlock(nil,error);
    } successHandler:^(NSData *data) {
        completionBlock(data,nil);
    }];
    return communicator;
}

- (void) fetchContentAtURL:(NSURL*)url
              errorHandler:(void(^)(NSError*))errorBlock
            successHandler:(void(^)(NSData*))successBlock {
    self.fetchingURL = url;
    self.errorHandler = errorBlock;
    self.successHandler = successBlock;
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:_fetchingURL];
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    [self launchConnectionForRequest:request];
}

- (void) postURL:(NSURL *)url
      parameters:(NSDictionary *)params
    errorHandler:(void(^)(NSError* error))errorBlock
  successHandler:(void(^)(NSData* data))successBlock {
    self.fetchingURL = url;
    self.errorHandler = errorBlock;
    self.successHandler = successBlock;
    
    self.communicating = YES;
    NSURLRequest * request = [SSUMoonlightCommunicator postRequestWithURL:url parameters:params];
    [self launchConnectionForRequest:request];
}

+ (NSURLRequest *) postRequestWithURL:(NSURL *)url parameters:(NSDictionary *)params {
    NSString * postData = URLEncodedDictionary(params);
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[postData stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)request.HTTPBody.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    return request;
}

- (void) getJSONFromPath:(NSString *)path completion:(DownloadCompletion)completion {
    [self getJSONFromPath:path sinceDate:nil completion:completion];
}

/**
 Downloads JSON from the given path, relative to the base moonlight URL.
 */
- (void) getJSONFromPath:(NSString *)path
               sinceDate:(NSDate *)lastUpdate
              completion:(DownloadCompletion)completion {
    
    NSString * urlBase = [SSUMoonlightBaseURL stringByAppendingPathComponent:path];
    NSString * fullURL = urlBase;
    if (lastUpdate != nil) {
        NSString * dateString = [self.dateFormatter stringFromDate:lastUpdate];
        if (dateString != nil) {
            fullURL = [fullURL stringByAppendingFormat:@"?date=%@", [dateString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    NSURL* url = [NSURL URLWithString:fullURL];
    [self getJSONFromURL:url completion:completion];
    
}

- (void) getJSONFromURL:(NSURL *)url completion:(DownloadCompletion)completion {
    if (completion == NULL) {
        // Downloading it without doing anything with it is worthless
        return;
    }
    [SSUMoonlightCommunicator fetchURL:url completionHandler:^(NSData *data, NSError *error) {
        if (error) {
            SSULogError(@"Error while downloading JSON: %@",error);
            completion(nil, error);
        }
        else if (data) {
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            completion(json, error);
        }
    }];
}

+ (SSUMoonlightCommunicator *) getJSONFromURL:(NSURL *)url completion:(DownloadCompletion)completion {
    SSUMoonlightCommunicator * communicator = [SSUMoonlightCommunicator new];
    [communicator getJSONFromURL:url completion:completion];
    return communicator;
}

+ (SSUMoonlightCommunicator *) getJSONFromPath:(NSString *)path completion:(DownloadCompletion)completion {
    SSUMoonlightCommunicator * communicator = [SSUMoonlightCommunicator new];
    [communicator getJSONFromPath:path completion:completion];
    return communicator;
}

+ (SSUMoonlightCommunicator *) getJSONFromPath:(NSString *)path sinceDate:(NSDate *)date completion:(DownloadCompletion)completion {
    SSUMoonlightCommunicator * communicator = [SSUMoonlightCommunicator new];
    [communicator getJSONFromPath:path sinceDate:date completion:completion];
    return communicator;
}

- (void) launchConnectionForRequest:(NSURLRequest*)request {
    self.communicating = YES;
    self.fetchingConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - NSURLConnectionDelegate

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void) connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([[SSUMoonlightCommunicator trustedHosts] containsObject:challenge.protectionSpace.host]) {
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        }
        else {
            self.errorHandler([NSError errorWithDomain:[NSString stringWithFormat:@"Connection From Unkown Host: %@", challenge.protectionSpace.host] code:0 userInfo:nil]);
        }
    }
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void) connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
    self.receivedData = nil;
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    if (httpResponse.statusCode != 200) {
        NSError* error = [NSError errorWithDomain:SSUMoonlightCommunicatorErrorDomain
                                             code:httpResponse.statusCode
                                         userInfo:@{
                                                    @"URL" : response.URL
                                                    }];
       self.errorHandler(error);
        [self cancelAndDiscardURLConnection];
    }
    else {
        self.receivedData = [[NSMutableData alloc] init];
    }
}

- (void) connection:(NSURLConnection*)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void) connection:(NSURLConnection*)connection didFailWithError:(NSError *)error {
    self.receivedData = nil;
    self.fetchingConnection = nil;
    self.fetchingURL = nil;
    self.communicating = NO;
    self.errorHandler(error);
}

- (void) connectionDidFinishLoading:(NSURLConnection*)connection {
    self.fetchingConnection = nil;
    self.fetchingURL = nil;
    self.communicating = NO;
    
    self.successHandler(self.receivedData);
}

- (void) cancelAndDiscardURLConnection {
    [self.fetchingConnection cancel];
    self.communicating = NO;
    
    self.receivedData = nil;
    self.fetchingConnection = nil;
    self.fetchingURL = nil;
}

@end
