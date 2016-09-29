//
//  SSUDirectoryConstants.h
//  SSUMobile
//
//  Created by Andrew Huss on 1/30/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

typedef enum SSUDirectoryCategoryType {
    kSSUDirectoryCategoryPeople,
    kSSUDirectoryCategoryBuildings,
    kSSUDirectoryCategoryDepartments,
    kSSUDirectoryCategoryFavorites,
    kSSUDirectoryCategoryAll
} SSUDirectoryCategoryType;

extern NSString* const SSUDirectoryUpdatedDateKey;
extern NSString* const SSUDirectoryPersonUpdatedDateKey;
extern NSString* const SSUDirectoryDepartmentUpdatedDateKey;
extern NSString* const SSUDirectoryBuildingUpdatedDateKey;
extern NSString* const SSUDirectorySchoolUpdatedDateKey;

extern NSString* const SSUDirectoryCategoryPeople;
extern NSString* const SSUDirectoryCategoryBuildings;
extern NSString* const SSUDirectoryCategoryDepartments;
extern NSString* const SSUDirectoryCategorySchools;
extern NSString* const SSUDirectoryCategoryFavorites;
extern NSString* const SSUDirectoryCategoryAll;

typedef enum SSUDirectoryEntityType {
    kSSUDirectoryEntityPerson,
    kSSUDirectoryEntityBuilding,
    kSSUDirectoryEntityDepartment,
    kSSUDirectoryEntityDirectoryObject,
} SSUDirectoryEntityType;

extern NSString* const SSUDirectoryStoryboardiPhone;
extern NSString* const SSUDirectoryStoryboardiPad;

extern NSString* const SSUDirectoryUpdatedNotification;

extern NSString* const SSUDirectoryEntityPerson;
extern NSString* const SSUDirectoryEntityBuilding;
extern NSString* const SSUDirectoryEntityDepartment;
extern NSString* const SSUDirectoryEntitySchool;
extern NSString* const SSUDirectoryEntityDirectoryObject;
