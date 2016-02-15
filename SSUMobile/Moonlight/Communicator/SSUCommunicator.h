//
//  SSUCommunicator.h
//  SSUMobile
//
//  Created by Eric Amorde on 9/10/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DownloadCompletion)(NSData * data, NSError * error);
typedef void(^JSONDownloadCompletion)(id json, NSError * error);

@interface SSUCommunicator : NSObject

@end
