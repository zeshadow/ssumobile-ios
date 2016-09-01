//
//  SSUNewsBuilder.h
//  SSUMobile
//
//  Created by Andrew Huss on 1/30/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

@import Foundation;
#import "SSUMoonlightBuilder.h"
#import "SSUArticle.h"

@interface SSUNewsBuilder : SSUMoonlightBuilder

+ (SSUArticle *)articleWithID:(NSString*)articleId inContext:(NSManagedObjectContext*)context;

@end
