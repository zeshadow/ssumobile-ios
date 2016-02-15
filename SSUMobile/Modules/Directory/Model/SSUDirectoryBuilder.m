//
//  SSUDirectoryBuilder.m
//  SSUMobile
//
//  Created by Andrew Huss on 1/22/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUDirectoryBuilder.h"
#import "SSUDirectoryConstants.h"
#import "SSUPerson+properties.h"
#import "SSUDepartment.h"
#import "SSUBuilding.h"
#import "SSULogging.h"

@implementation SSUDirectoryBuilder

- (SSUPerson *) personWithID:(NSString *)personID {
    return [[self class] personWithID:personID inContext:self.context];
}

+ (SSUPerson *) personWithID:(NSString *)personID inContext:(NSManagedObjectContext *)context {
    if (personID.integerValue == 0)
        return nil;
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K = %@", SSUMoonlightManagerKeyID, personID];
    BOOL created = NO;
    SSUPerson * person = (SSUPerson*)[self objectWithEntityName:SSUDirectoryEntityPerson predicate:predicate context:context entityWasCreated:&created];
    if (created) {
        person.id = personID;
        person.sectionName = SSUDirectoryCategoryPeople;
    }

    return person;
}

- (SSUDepartment *) departmentWithID:(NSString *)departmentID {
    return [[self class] departmentWithID:departmentID inContext:self.context];
}

+ (SSUDepartment *) departmentWithID:(NSString *)departmentID inContext:(NSManagedObjectContext *)context {
    if (departmentID.integerValue == 0)
        return nil;
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K = %@", SSUMoonlightManagerKeyID, departmentID];
    BOOL created = NO;
    SSUDepartment* department = (SSUDepartment *)[self objectWithEntityName:SSUDirectoryEntityDepartment predicate:predicate context:context entityWasCreated:&created];
    if (created) {
        department.id = departmentID;
        department.sectionName = SSUDirectoryCategoryDepartments;
        department.name = @"Unknown";
    }

    return department;
}

- (SSUBuilding *) buildingWithID:(NSString *)buildingID {
    return [[self class] buildingWithID:buildingID inContext:self.context];
}

+ (SSUBuilding *) buildingWithID:(NSString*)buildingID inContext:(NSManagedObjectContext *)context {
    if (buildingID.integerValue == 0)
        return nil;
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", SSUMoonlightManagerKeyID, buildingID];
    BOOL created = NO;
    SSUBuilding* building = (SSUBuilding*)[self objectWithEntityName:SSUDirectoryEntityBuilding predicate:predicate context:context entityWasCreated:&created];
    if (created) {
        building.id = buildingID;
        building.sectionName = SSUDirectoryCategoryBuildings;
        building.name = @"Unknown";
    }

    return building;
}

- (SSUSchool *) schoolWithID:(NSNumber *)schoolID {
    return [[self class] schoolWithID:schoolID inContext:self.context];
}

+ (SSUSchool *) schoolWithID:(NSNumber *)schoolID inContext:(NSManagedObjectContext *)context {
    if (schoolID == nil || schoolID.integerValue <= 0) {
        return nil;
    }
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K = %@", SSUMoonlightManagerKeyID, schoolID];
    BOOL created = NO;
    SSUSchool * school = (SSUSchool *)[self objectWithEntityName:SSUDirectoryEntitySchool predicate:predicate context:context entityWasCreated:&created];
    if (created) {
        school.id = schoolID;
        school.sectionName = SSUDirectoryCategorySchools;
    }

    return school;
}

- (void) build:(NSDictionary*)results {
    // We renamed models with SSU prefix, but moonlight still uses entity names without SSU prefix
    [self buildDepartments:results[@"Department"]];
    [self buildPeople:results[@"Person"]];
    [self buildBuildings:results[@"Building"]];
    [self buildSchools:results[@"School"]];

    [self saveContext];
}

- (void) updatePersonProperties {
    NSArray * allPeople = [self allObjectsWithEntityName:SSUDirectoryEntityPerson];
    [allPeople makeObjectsPerformSelector:@selector(updateNameOrder)];
}

- (void) updateDepartmentProperties {
    NSArray * allDepartments = [self allObjectsWithEntityName:SSUDirectoryEntityDepartment];
    [allDepartments makeObjectsPerformSelector:@selector(updateSectionName)];
}

- (void) buildPeople:(NSArray*)people {
    SSULogDebug(@"Started People: %lu", (unsigned long)people.count);
    NSDate* start = [NSDate date];
    
    [self updatePersonProperties];
    
    for (NSDictionary* personData in people) {
        SSUMoonlightDataMode mode = [self modeFromJSONData:personData];
        
        NSString* personID = SSUMoonlightBuilderStringify(personData[SSUMoonlightManagerKeyID]);
        SSUPerson* person = [self personWithID:personID];
        if (person == nil)
            continue;
        if (mode == SSUMoonlightDataModeDeleted) {
            if ([person isInserted]) {
                [self.context deleteObject:person];
            }
            continue;
        }
        
        person.firstName = [personData[SSUDirectoryPersonKeyFirstName] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        person.lastName = [personData[SSUDirectoryPersonKeyLastName] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        [person updateNameOrder];
        
        person.email = personData[SSUDirectoryPersonKeyEmail];
        person.phone = personData[SSUDirectoryPersonKeyPhone];
        person.site = personData[SSUDirectoryPersonKeySite];
        person.title = personData[SSUDirectoryPersonKeyTitle];
        person.office = personData[SSUDirectoryPersonKeyOffice];
        
        NSString* buildingID = SSUMoonlightBuilderStringify(personData[SSUDirectoryPersonKeyBuilding]);
        person.building = [self buildingWithID:buildingID];
        
        NSString* departmentID = SSUMoonlightBuilderStringify(personData[SSUDirectoryPersonKeyDepartment]);
        person.department = [self departmentWithID:departmentID];
    }
    
    SSULogDebug(@"Finished People: %f", [[NSDate date] timeIntervalSinceDate:start]);
}

- (void) buildBuildings:(NSArray*)buildings {
    SSULogDebug(@"Started Buildings: %lu", (unsigned long)buildings.count);
    NSDate* start = [NSDate date];
    for (NSDictionary* buildingData in buildings) {
        SSUBuilding* building = [SSUDirectoryBuilder buildingWithID:buildingData[SSUMoonlightManagerKeyID] inContext:self.context];
        
        if (building == nil)
            continue;
        SSUMoonlightDataMode mode = [self modeFromJSONData:buildingData];
        if (mode == SSUMoonlightDataModeDeleted) {
            [self.context deleteObject:building];
            continue;
        }
        building.name = buildingData[SSUDirectoryBuildingKeyName];
        building.displayName = building.name;
        building.term = building.name;
    }
    
    SSULogDebug(@"Finished Buildings: %f", [[NSDate date] timeIntervalSinceDate:start]);
}

- (void) buildDepartments:(NSArray*)departments {
    SSULogDebug(@"Started Departments: %lu", (unsigned long)departments.count);
    NSDate* start = [NSDate date];
    
    [self updateDepartmentProperties];

    for (NSDictionary* departmentData in departments) {
        SSUDepartment* department = [SSUDirectoryBuilder departmentWithID:departmentData[SSUMoonlightManagerKeyID] inContext:self.context];
        if (department == nil)
            continue;
        SSUMoonlightDataMode mode = [self modeFromJSONData:departmentData];
        if (mode == SSUMoonlightDataModeDeleted) {
            [self.context deleteObject:department];
            continue;
        }
        
        department.name = departmentData[SSUDirectoryDepartmentKeyName];
        NSString * displayName = departmentData[SSUDirectoryDepartmentKeyDisplayName];
        department.displayName = (!SSUIsEmptyString(displayName)) ? displayName : department.name;

        department.term = department.displayName;
        
        department.phone = departmentData[SSUDirectoryDepartmentKeyPhone];
        department.site = departmentData[SSUDirectoryDepartmentKeySite];
        department.office = departmentData[SSUDirectoryDepartmentKeyRoomID];
        
        NSString * buildingID = SSUMoonlightBuilderStringify(departmentData[SSUDirectoryDepartmentKeyBuildingID]);
        department.building = [self buildingWithID:buildingID];
        
        NSString* chairID = SSUMoonlightBuilderStringify(departmentData[SSUDirectoryDepartmentKeyChairID]);
        department.chair = [self personWithID:chairID];
        
        NSString* acID = SSUMoonlightBuilderStringify(departmentData[SSUDirectoryDepartmentKeyACID]);
        department.ac = [self personWithID:acID];
        
        NSString * schoolID = SSUMoonlightBuilderStringify(departmentData[SSUDirectoryDepartmentKeySchoolID]);
        department.school = [self schoolWithID:[NSNumber numberWithInt:schoolID.intValue]];
    }
    
    SSULogDebug(@"Finished Department: %f", [[NSDate date] timeIntervalSinceDate:start]);
}

- (void) buildSchools:(NSArray *)schools {
    SSULogDebug(@"Started Schools: %lu", (unsigned long)schools.count);
    NSDate * start = [NSDate date];
    
    for (NSDictionary * data in schools) {
        NSString * schoolID = SSUMoonlightBuilderStringify(data[SSUMoonlightManagerKeyID]);
        SSUSchool * school = [self schoolWithID:@(schoolID.integerValue)];
        if (school == nil)
            continue;
        SSUMoonlightDataMode mode = [self modeFromJSONData:data];
        if (mode == SSUMoonlightDataModeDeleted) {
            [self.context deleteObject:school];
            continue;
        }
        
        school.name = data[SSUDirectorySchoolKeyName];
        school.term = school.name;
        school.displayName = school.name;
        
        NSString * deanID = SSUMoonlightBuilderStringify(data[SSUDirectorySchoolKeyDeanID]);
        school.dean = [self personWithID:deanID];
        
        NSString * adminID = SSUMoonlightBuilderStringify(data[SSUDirectorySchoolKeyAdminID]);
        school.admin = [self personWithID:adminID];
        
        NSString * assistantID = SSUMoonlightBuilderStringify(data[SSUDirectorySchoolKeyAssistantID]);
        school.assistant = [self personWithID:assistantID];
        
        NSString * buildingID = SSUMoonlightBuilderStringify(data[SSUDirectorySchoolKeyBuildingID]);
        school.building = [self buildingWithID:buildingID];

    }
    
    SSULogDebug(@"Finished Schools: %fs", [[NSDate date] timeIntervalSinceDate:start]);
}

@end
