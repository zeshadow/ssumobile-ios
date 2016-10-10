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
#import "SSUGlobalNavigationController.h"

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
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Please login" message:@"Login is required for write-access to dev tools" preferredStyle:UIAlertControllerStyleAlert];
    enum {
        UsernameTextField,
        PasswordTextField
    };
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Username";
        textField.tag = UsernameTextField;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Password";
        textField.secureTextEntry = YES;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:NULL];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString * username = alert.textFields[0].text;
        NSString * password = alert.textFields[1].text;
        [self loginWithUsername:username password:password];
    }]];
    
    UIViewController * vc = [[[SSUGlobalNavigationController sharedInstance] viewControllers] lastObject];
    [vc presentViewController:alert animated:YES completion:NULL];
}

+ (void) loginWithUsername:(NSString *)username password:(NSString *)password {
    NSDictionary * params = @{
                              @"username": username,
                              @"password": password
                              };
    [SSUMoonlightCommunicator postJSONPath:@"token-auth/" parameters:params completion:^(NSURLResponse *response, NSDictionary* json, NSError *error) {
        if (error) {
            [self requestCredentials];
        }
        else {
            token = json[@"token"];
            if (token == nil || token == (id)[NSNull null]) {
                SSULogDebug(@"Received an unexpected response: %@", json);
                token = nil;
            }
            else {
                SSULogDebug(@"Retrieved token: %@", token);
            }
        }
    }];
}

+ (NSString *) authorizationHeaderValue {
    return [NSString stringWithFormat:@"Token %@", [self token]];
}

+ (NSURLRequest *) authenticatedRequestFromRequest:(NSURLRequest *)request {
    NSMutableURLRequest * result = [request mutableCopy];
    [result addValue:[self authorizationHeaderValue] forHTTPHeaderField:@"Authorization"];
    
    return result;
}

@end
