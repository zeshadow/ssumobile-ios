//
//  SSUNewsBuilder.h
//  SSUMobile
//
//  Created by Andrew Huss on 1/30/13.
//  Copyright (c) 2013 Computer Science. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSUMoonlightBuilder.h"
#import "SSUArticle.h"

@interface SSUNewsBuilder : SSUMoonlightBuilder

+ (SSUArticle *)articleWithID:(NSString*)articleId inContext:(NSManagedObjectContext*)context;

@end
