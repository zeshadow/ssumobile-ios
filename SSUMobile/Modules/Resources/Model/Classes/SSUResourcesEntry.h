//
//  Resource.h
//  SSUMobile
//
//  Created by Eric Amorde on 11/19/14.
//  Copyright (c) 2014 Computer Science. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SSUResourcesSection;

@interface SSUResourcesEntry : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) SSUResourcesSection *section;

@end
