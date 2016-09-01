//
//  Location.h
//  SSUMobile
//
//  Created by Andrew Huss on 4/10/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

@import Foundation;
@import CoreData;


@interface SSUMapLocation : NSManagedObject

@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * longitude;

@end
