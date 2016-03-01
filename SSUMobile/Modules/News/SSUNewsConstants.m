//
//  SSUNewsConstants.m
//  SSUMobile
//
//  Created by Andrew Huss on 1/31/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUNewsConstants.h"

NSString* const SSUNewsUpdatedDateKey = @"NewsUpdatedDate";

NSString* const SSUNewsEntityArticle = @"SSUArticle";

NSString* const SSUNewsKeyAuthor = @"Author";
NSString* const SSUNewsKeyCategory = @"Category";
NSString* const SSUNewsKeyTitle = @"Title";
NSString* const SSUNewsKeyImageURL = @"ImageURL";
NSString* const SSUNewsKeySummary = @"Summary";
NSString* const SSUNewsKeyContent = @"Content";
NSString* const SSUNewsKeyLink = @"Link";
NSString* const SSUNewsKeyPublished = @"Published";

NSInteger const SSUNewsArticleFetchDateLimit = 60*60*24*180; // 6 months

NSString* const SSUNewsImageCacheDirectory = @"News_Cache";
