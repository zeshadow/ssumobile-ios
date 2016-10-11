//
//  SSUCalendarBuilder.h
//  SSUMobile
//
//  Created by Andrew Huss on 1/31/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUMoonlightBuilder.h"
#import "SSUEvent.h"

@interface SSUCalendarBuilder : SSUMoonlightBuilder

+ (SSUEvent *) eventWithID:(NSNumber *)eventID inContext:(NSManagedObjectContext *)context;
- (void) buildEvents:(NSArray *)events;

@end
