//
//  Department.h
//  SSUMobile
//
//  Created by Eric Amorde on 3/26/14.
//  Copyright (c) 2014 Sonoma State University Department of Computer Science. All rights reserved.
//

@import Foundation;
@import CoreData;
#import "SSUDirectoryObject.h"

@class SSUBuilding, SSUPerson, SSUSchool;

@interface SSUDepartment : SSUDirectoryObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * fax;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * office;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * site;
@property (nonatomic, retain) SSUPerson *ac;
@property (nonatomic, retain) SSUBuilding *building;
@property (nonatomic, retain) SSUPerson *chair;
@property (nonatomic, retain) NSSet *people;
@property (nonatomic, retain) SSUSchool *school;
@end

@interface SSUDepartment (CoreDataGeneratedAccessors)

- (void)addPeopleObject:(SSUPerson *)value;
- (void)removePeopleObject:(SSUPerson *)value;
- (void)addPeople:(NSSet *)values;
- (void)removePeople:(NSSet *)values;

@end
