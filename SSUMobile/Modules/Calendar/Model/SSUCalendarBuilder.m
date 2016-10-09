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


NSString * const SSUCalendarEventKeyID = @"id";
NSString * const SSUCalendarEventKeyStart = @"start_date";
NSString * const SSUCalendarEventKeyEnd = @"end_date";
NSString * const SSUCalendarEventKeyTitle = @"title";
NSString * const SSUCalendarEventKeyOrganization = @"organization";
NSString * const SSUCalendarEventKeyCategory = @"category";
NSString * const SSUCalendarEventKeyLocation = @"location";
NSString * const SSUCalendarEventKeyDescription = @"description";
NSString * const SSUCalendarEventKeyImgURL = @"image_url";

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

- (void) buildEvents:(NSArray *)events {
    SSULogDebug(@"Started events: %lu",(unsigned long)events.count);
    NSDate* buildStart = [NSDate date];
    
    for (NSDictionary * raw in events) {
        NSDictionary * eventData = [self cleanJSON:raw];
        NSNumber * eventId = @([eventData[SSUCalendarEventKeyID] integerValue]);
        SSUEvent * event = [SSUCalendarBuilder eventWithID:eventId inContext:self.context];
        
        event.title = eventData[SSUCalendarEventKeyTitle];
        event.startDate = [self.dateFormatter dateFromString:eventData[SSUCalendarEventKeyStart]];
        event.endDate = [self.dateFormatter dateFromString:eventData[SSUCalendarEventKeyEnd]];
        event.summary = eventData[SSUCalendarEventKeyDescription];
        event.location = eventData[SSUCalendarEventKeyLocation];
        event.imgURL = eventData[SSUCalendarEventKeyImgURL];
        event.organization = eventData[SSUCalendarEventKeyOrganization];
        event.category = eventData[SSUCalendarEventKeyCategory];
        
    }
    [self saveContext];
    
    SSULogDebug(@"Finished Events: %f",[[NSDate date] timeIntervalSinceDate:buildStart]);
}

@end
