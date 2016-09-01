//
//  DirectoryObject.h
//  SSUMobile
//
//  Created by Andrew Huss on 4/14/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

@import Foundation;
@import CoreData;


@interface SSUDirectoryObject : NSManagedObject

@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSString * sectionName;
@property (nonatomic, retain) NSString * term;

@end
