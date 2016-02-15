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

extern NSString* const SSUUserDefaultsDirectoryUpdatedDate;

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

extern NSString* const SSUDirectoryPersonKeyCreated;
extern NSString* const SSUDirectoryPersonKeyDeleted;
extern NSString* const SSUDirectoryPersonKeyEmail;
extern NSString* const SSUDirectoryPersonKeyFirstName;
extern NSString* const SSUDirectoryPersonKeyID;
extern NSString* const SSUDirectoryPersonKeyLastName;
extern NSString* const SSUDirectoryPersonKeyModified;
extern NSString* const SSUDirectoryPersonKeyPhone;
extern NSString* const SSUDirectoryPersonKeySite;
extern NSString* const SSUDirectoryPersonKeyTitle;
extern NSString* const SSUDirectoryPersonKeyOffice;
extern NSString* const SSUDirectoryPersonKeyBuilding;
extern NSString* const SSUDirectoryPersonKeyDepartment;

extern NSString* const SSUDirectoryDepartmentKeyName;
extern NSString* const SSUDirectoryDepartmentKeyDisplayName;
extern NSString* const SSUDirectoryDepartmentKeyPhone;
extern NSString* const SSUDirectoryDepartmentKeySite;
extern NSString* const SSUDirectoryDepartmentKeyChairID;
extern NSString* const SSUDirectoryDepartmentKeyACID;
extern NSString* const SSUDirectoryDepartmentKeyBuildingID;
extern NSString* const SSUDirectoryDepartmentKeyRoomID;
extern NSString* const SSUDirectoryDepartmentKeySchoolID;

extern NSString* const SSUDirectoryBuildingKeyName;

extern NSString* const SSUDirectorySchoolKeyName;
extern NSString* const SSUDirectorySchoolKeyDeanID;
extern NSString* const SSUDirectorySchoolKeyAdminID;
extern NSString* const SSUDirectorySchoolKeyAssistantID;
extern NSString* const SSUDirectorySchoolKeyBuildingID;
