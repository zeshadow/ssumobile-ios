//
//  Department+properties.m
//  SSUMobile
//
//  Created by Eric Amorde on 8/31/15.
//  Copyright (c) 2015 Computer Science. All rights reserved.
//

#import "SSUDepartment+properties.h"

@implementation SSUDepartment (properties)

- (void) updateSectionName {
    NSString * displayName = [[self displayName] stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
    self.sectionName = [displayName substringToIndex:1];
}

@end
