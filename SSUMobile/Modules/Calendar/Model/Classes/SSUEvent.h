//
//  Event.h
//  SSUMobile
//
//  Created by Eric Amorde on 10/5/14.
//  Copyright (c) 2014 Sonoma State University Department of Computer Science. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface SSUEvent : NSManagedObject

@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * imgURL;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * organization;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * category;

@end
