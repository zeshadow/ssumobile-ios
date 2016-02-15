//
//  NewsObject.h
//  SSUMobile
//
//  Created by Andrew Huss on 2/7/13.
//  Copyright (c) 2013 Computer Science. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SSUNewsObject : NSManagedObject

@property (nonatomic, retain) NSString * sectionName;

@end
