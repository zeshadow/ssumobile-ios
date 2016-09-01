//
//  Person.h
//  SSUMobile
//
//  Created by Eric Amorde on 3/26/14.
//  Copyright (c) 2014 Sonoma State University Department of Computer Science. All rights reserved.
//

@import Foundation;
@import CoreData;
#import "SSUDirectoryObject.h"

@class SSUBuilding, SSUDepartment, SSUSchool;

@interface SSUPerson : SSUDirectoryObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * office;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * site;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) SSUDepartment *ac_department;
@property (nonatomic, retain) SSUSchool *admin_school;
@property (nonatomic, retain) NSSet *assistant_school;
@property (nonatomic, retain) SSUBuilding *building;
@property (nonatomic, retain) SSUDepartment *chair_department;
@property (nonatomic, retain) SSUSchool *dean_school;
@property (nonatomic, retain) SSUDepartment *department;
@end

@interface SSUPerson (CoreDataGeneratedAccessors)

- (void)addAssistant_schoolObject:(SSUSchool *)value;
- (void)removeAssistant_schoolObject:(SSUSchool *)value;
- (void)addAssistant_school:(NSSet *)values;
- (void)removeAssistant_school:(NSSet *)values;

@end
