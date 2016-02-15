//
//  SSUNewsBuilder.m
//  SSUMobile
//
//  Created by Andrew Huss on 1/30/13.
//  Copyright (c) 2013 Computer Science. All rights reserved.
//

#import "SSUNewsBuilder.h"
#import "SSUNewsConstants.h"
#import "SSUArticle.h"
#import "SSULogging.h"

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
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:SSUNewsEntityArticle];
    NSDate * cutoffDate = [NSDate dateWithTimeIntervalSinceNow:-1*SSUNewsArticleFetchDateLimit];
    request.predicate = [NSPredicate predicateWithFormat:@"published <= %@",cutoffDate];
    NSArray * oldArticles = [self.context executeFetchRequest:request error:nil];
    for (SSUArticle * article in oldArticles) {
        [self.context performBlockAndWait:^{
            [self.context deleteObject:article];
        }];
    }
}

- (void) build:(NSArray *)stories {
    SSULogDebug(@"Building News Stories: %lu", (unsigned long)stories.count);
    for (NSDictionary* storyData in stories) {
        SSUMoonlightDataMode mode = [self modeFromJSONData:storyData];
        // TODO: ID is uppercase instead of lowercase
        SSUArticle* article = [SSUNewsBuilder articleWithID:storyData[@"ID"] inContext:self.context];
        if (mode == SSUMoonlightDataModeDeleted) {
            [self.context deleteObject:article];
            continue;
        }
        else if (mode == SSUMoonlightDataModeCreate){
        }
        else if (mode == SSUMoonlightDataModeModified)  {
        }
        article.author = storyData[SSUNewsKeyAuthor];
        article.category = storyData[SSUNewsKeyCategory];
        article.title = storyData[SSUNewsKeyTitle];
        article.imageURL = SSUIsEmptyString(storyData[SSUNewsKeyImageURL]) ? nil : storyData[SSUNewsKeyImageURL];
        article.summary = storyData[SSUNewsKeySummary];
        article.content = storyData[SSUNewsKeyContent];
        article.link = storyData[SSUNewsKeyLink];
        
        // ex: 2010-12-22T17:39:51Z
        NSString *publishedString = storyData[SSUNewsKeyPublished];
        publishedString = [publishedString stringByReplacingOccurrencesOfString:@"T" withString:@" "];
        publishedString = [publishedString stringByReplacingOccurrencesOfString:@"Z" withString:@""];
        NSDate * result = [self.dateFormatter dateFromString:publishedString];
        if (result) {
            article.published = result;
        } else {
            SSULogError(@"Error: unable to parse published date %@", publishedString);
        }
    }
    
    [self removeOldArticles];
    [self saveContext];
}

@end
