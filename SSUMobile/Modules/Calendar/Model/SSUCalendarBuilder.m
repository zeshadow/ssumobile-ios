//
//  SSUCalendarBuilder.m
//  SSUMobile
//
//  Created by Andrew Huss on 1/31/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUCalendarBuilder.h"
#import "SSUCalendarConstants.h"
#import "SSULogging.h"

NSString * const SSUCalendarEventKeyID = @"Id";
NSString * const SSUCalendarEventKeyCreated = @"CreatedOn";
NSString * const SSUCalendarEventKeyStart = @"StartsOn";
NSString * const SSUCalendarEventKeyEnd = @"EndsOn";
NSString * const SSUCalendarEventKeyTitle = @"Title";
NSString * const SSUCalendarEventKeyOrganization = @"Organization";
NSString * const SSUCalendarEventKeyCategory = @"category";
NSString * const SSUCalendarEventKeyLocation = @"Location";
NSString * const SSUCalendarEventKeyDescription = @"Description";
NSString * const SSUCalendarEventKeyImgURL = @"ImgUrl";

@implementation SSUCalendarBuilder

+ (SSUEvent *) eventWithID:(NSNumber *)eventID inContext:(NSManagedObjectContext *)context {
    if (eventID == nil || eventID.integerValue == 0)
        return nil;
    
    BOOL created = NO;
    SSUEvent* event = (SSUEvent*)[self objectWithEntityName:SSUCalendarEntityEvent
                                                         ID:eventID
                                                    context:context
                                           entityWasCreated:&created];
    if (created) {
        event.id = eventID;
    }

    return event;
}

- (void) build:(NSDictionary*)results {
    SSULogDebug(@"Calendar: %lu", (unsigned long)results.count);
    [self buildEvents:results[@"Event"]];
    [self saveContext];
}

- (void) buildEvents:(NSArray *)events {
    SSULogDebug(@"Started events: %lu",(unsigned long)events.count);
    NSDate* buildStart = [NSDate date];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd H:mm:ss";
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.timeZone = [NSTimeZone systemTimeZone];
    
    NSMutableArray * ids = [NSMutableArray new];
    
    for (NSDictionary * eventData in events) {
        NSNumber * eventId = @([eventData[SSUCalendarEventKeyID] integerValue]);
        SSUEvent * event = [SSUCalendarBuilder eventWithID:eventId inContext:self.context];
        
        event.title = eventData[SSUCalendarEventKeyTitle];
        event.startDate = [dateFormatter dateFromString:eventData[SSUCalendarEventKeyStart]];
        event.endDate = [dateFormatter dateFromString:eventData[SSUCalendarEventKeyEnd]];
        event.summary = eventData[SSUCalendarEventKeyDescription];
        event.location = eventData[SSUCalendarEventKeyLocation];
        event.imgURL = eventData[SSUCalendarEventKeyImgURL];
        event.organization = eventData[SSUCalendarEventKeyOrganization];
        event.category = eventData[SSUCalendarEventKeyCategory];
        
        [ids addObject:[event id]];
    }
    
    // Calendar is no longer date delta-ed - instead, all events which have a start date
    // at most one month in the past and up until the indefinite future are sent.
    NSPredicate * deletePredicate = [NSPredicate predicateWithFormat:@"NOT (id  IN %@)", ids];
    [SSUMoonlightBuilder deleteObjectsWithEntityName:SSUCalendarEntityEvent matchingPredicate:deletePredicate context:self.context];
    SSULogDebug(@"Finished Events: %f",[[NSDate date] timeIntervalSinceDate:buildStart]);
}

@end
