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

@implementation SSUCalendarBuilder

+ (SSUEvent *) eventWithID:(NSNumber *)eventID inContext:(NSManagedObjectContext *)context {
    if (eventID == nil || eventID.integerValue == 0)
        return nil;
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", SSUMoonlightManagerKeyID, eventID];
    BOOL created = NO;
    SSUEvent* event = (SSUEvent*)[self objectWithEntityName:SSUCalendarEntityEvent
                                            predicate:predicate
                                              context:context
                                     entityWasCreated:&created];
    if (created) {
        event.id = eventID;
    }
    else {
        
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
    
    for (NSDictionary * eventData in events) {
        SSUMoonlightDataMode mode = [self modeFromJSONData:eventData];
        NSNumber * eventId = @([eventData[SSUCalendarEventKeyID] integerValue]);
        SSUEvent * event = [SSUCalendarBuilder eventWithID:eventId inContext:self.context];
        if (event == nil) {
            continue;
        }
        if (mode == SSUMoonlightDataModeDeleted) {
            [self.context deleteObject:event];
            continue;
        }
        
        event.title = eventData[SSUCalendarEventKeyTitle];
        event.startDate = [dateFormatter dateFromString:eventData[SSUCalendarEventKeyStart]];
        event.endDate = [dateFormatter dateFromString:eventData[SSUCalendarEventKeyEnd]];
        event.summary = eventData[SSUCalendarEventKeyDescription];
        event.location = eventData[SSUCalendarEventKeyLocation];
        event.imgURL = eventData[SSUCalendarEventKeyImgURL];
        event.organization = eventData[SSUCalendarEventKeyOrganization];
        event.category = eventData[SSUCalendarEventKeyCategory];
        
    }
    SSULogDebug(@"Finished Events: %f",[[NSDate date] timeIntervalSinceDate:buildStart]);
}

@end
