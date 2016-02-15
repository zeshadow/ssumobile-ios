//
//  SSUCalendarBuilder.h
//  SSUMobile
//
//  Created by Andrew Huss on 1/31/13.
//  Copyright (c) 2013 Computer Science. All rights reserved.
//

#import "SSUMoonlightBuilder.h"
#import "SSUEvent.h"

@interface SSUCalendarBuilder : SSUMoonlightBuilder

+ (SSUEvent *) eventWithID:(NSNumber *)eventID inContext:(NSManagedObjectContext *)context;

@end
