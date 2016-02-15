//
//  SSUDirectoryBuilder.h
//  SSUMobile
//
//  Created by Andrew Huss on 1/22/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSUMoonlightBuilder.h"
#import "SSUDirectoryConstants.h"
#import "SSUPerson.h"
#import "SSUDepartment.h"
#import "SSUBuilding.h"
#import "SSUSchool.h"

@interface SSUDirectoryBuilder : SSUMoonlightBuilder

- (SSUPerson *) personWithID:(NSString*)personID;
- (SSUDepartment *) departmentWithID:(NSString*)departmentID;
- (SSUBuilding *) buildingWithID:(NSString*)buildingID;
- (SSUSchool *) schoolWithID:(NSNumber *)schoolID;

+ (SSUPerson *) personWithID:(NSString*)personID inContext:(NSManagedObjectContext*)context;
+ (SSUDepartment *) departmentWithID:(NSString*)departmentID inContext:(NSManagedObjectContext*)context;
+ (SSUBuilding *) buildingWithID:(NSString*)buildingID inContext:(NSManagedObjectContext*)context;
+ (SSUSchool *) schoolWithID:(NSNumber *)schoolID inContext:(NSManagedObjectContext *)context;

@end
