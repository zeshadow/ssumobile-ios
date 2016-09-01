//
//  Building.h
//  SSUMobile
//
//  Created by Eric Amorde on 3/26/14.
//  Copyright (c) 2014 Sonoma State University Department of Computer Science. All rights reserved.
//

@import Foundation;
@import CoreData;
#import "SSUDirectoryObject.h"

@class SSUDepartment, SSUPerson, SSUSchool;

@interface SSUBuilding : SSUDirectoryObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *departments;
@property (nonatomic, retain) NSSet *people;
@property (nonatomic, retain) NSSet *schools;
@end

@interface SSUBuilding (CoreDataGeneratedAccessors)

- (void)addDepartmentsObject:(SSUDepartment *)value;
- (void)removeDepartmentsObject:(SSUDepartment *)value;
- (void)addDepartments:(NSSet *)values;
- (void)removeDepartments:(NSSet *)values;

- (void)addPeopleObject:(SSUPerson *)value;
- (void)removePeopleObject:(SSUPerson *)value;
- (void)addPeople:(NSSet *)values;
- (void)removePeople:(NSSet *)values;

- (void)addSchoolsObject:(SSUSchool *)value;
- (void)removeSchoolsObject:(SSUSchool *)value;
- (void)addSchools:(NSSet *)values;
- (void)removeSchools:(NSSet *)values;

@end
