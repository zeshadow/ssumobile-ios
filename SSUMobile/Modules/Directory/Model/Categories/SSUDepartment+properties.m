//
//  Department+properties.m
//  SSUMobile
//
//  Created by Eric Amorde on 8/31/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUDepartment+properties.h"

@implementation SSUDepartment (properties)

- (void) updateSectionName {
    NSString * displayName = [self.displayName stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
    if (displayName.length > 0) {
        self.sectionName = [displayName substringToIndex:1];
    } else {
        self.sectionName = nil;
    }
}

@end
