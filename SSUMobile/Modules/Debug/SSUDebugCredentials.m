//
//  SSUDebugCredentials.m
//  SSUMobile
//
//  Created by Eric Amorde on 2/8/16.
//  Copyright © 2016 Sonoma State University Department of Computer Science. All rights reserved.
//

@import UIKit;

#import "SSUDebugCredentials.h"
#import "SSUMoonlightCommunicator.h"
#import "SSULogging.h"

static NSString * token = nil;

@interface SSUDebugCredentials() <UIAlertViewDelegate>

@end

@implementation SSUDebugCredentials

+ (NSString *) token {
    return token;
}

+ (void) requestCredentials {
    if ([self token] != nil) {
        return;
    }
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Please provide access token" message:@"An access token is required for dev tools" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Go", nil];
    alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alertView show];
}

+ (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    UITextField * field = [alertView textFieldAtIndex:0];
    NSString * key = field.text;
    NSString * baseURL = [SSUMoonlightBaseURL stringByAppendingPathComponent:@"/auth"];
    NSURL * url = [NSURL URLWithString:baseURL];
    [SSUMoonlightCommunicator postURL:url parameters:@{@"key":key} completionHandler:^(NSData *data, NSError *error) {
        if (error) {
            [self requestCredentials];
        }
        else {
            SSULogDebug(@"Successfully retrived token");
            token = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }];
}

@end
