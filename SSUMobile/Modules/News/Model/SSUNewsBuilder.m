//
//  SSUNewsBuilder.m
//  SSUMobile
//
//  Created by Andrew Huss on 1/30/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUNewsBuilder.h"
#import "SSUNewsConstants.h"
#import "SSUArticle.h"
#import "SSULogging.h"

NSString * const SSUNewsKeyID = @"article_id";
NSString * const SSUNewsKeyAuthor = @"author";
NSString * const SSUNewsKeyCategory = @"category";
NSString * const SSUNewsKeyTitle = @"title";
NSString * const SSUNewsKeyImageURL = @"image_url";
NSString * const SSUNewsKeySummary = @"summary";
NSString * const SSUNewsKeyContent = @"content";
NSString * const SSUNewsKeyLink = @"url";
NSString * const SSUNewsKeyPublished = @"publish_date";

@interface SSUNewsBuilder()

@end

@implementation SSUNewsBuilder

+ (SSUArticle *)articleWithID:(NSString*)articleID inContext:(NSManagedObjectContext*)context {
    if (articleID.length == 0)
        return nil;
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", SSUMoonlightManagerKeyID, articleID];
    BOOL created = NO;
    SSUArticle* article = (SSUArticle*)[self objectWithEntityName:SSUNewsEntityArticle
                                                  predicate:predicate
                                                    context:context
                                           entityWasCreated:&created];
    if (created) {
        article.id = articleID;
    }

    return article;
}

- (void) removeOldArticles {
    NSDate * cutoffDate = [NSDate dateWithTimeIntervalSinceNow:-1*SSUNewsArticleFetchDateLimit];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"published <= %@",cutoffDate];
    [SSUMoonlightBuilder deleteObjectsWithEntityName:SSUNewsEntityArticle matchingPredicate:predicate context:self.context];
}

- (void) build:(NSArray *)stories {
    SSULogDebug(@"Building News Stories: %lu", (unsigned long)stories.count);
    for (NSDictionary * raw in stories) {
        NSDictionary * storyData = [self cleanJSON:raw];
        SSUMoonlightDataMode mode = [self modeFromJSONData:storyData];
        SSUArticle* article = [SSUNewsBuilder articleWithID:storyData[SSUNewsKeyID] inContext:self.context];
        if (mode == SSUMoonlightDataModeDeleted) {
            [self.context deleteObject:article];
            continue;
        }

        article.author = storyData[SSUNewsKeyAuthor];
        article.category = storyData[SSUNewsKeyCategory];
        article.title = storyData[SSUNewsKeyTitle];
        article.imageURL = SSUIsEmptyString(storyData[SSUNewsKeyImageURL]) ? nil : storyData[SSUNewsKeyImageURL];
        article.summary = storyData[SSUNewsKeySummary];
        article.content = storyData[SSUNewsKeyContent];
        article.link = storyData[SSUNewsKeyLink];
        
        NSDate * publishedDate = [self.dateFormatter dateFromString:storyData[SSUNewsKeyPublished]];
        if (publishedDate != nil) {
            article.published = publishedDate;
        } else {
            SSULogError(@"Error: unable to parse published date %@", storyData[SSUNewsKeyPublished]);
        }
    }
    
    [self removeOldArticles];
    [self saveContext];
}

@end
