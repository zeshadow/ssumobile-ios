//
//  SSUPersonTableViewCell.m
//  SSUMobile
//
//  Created by Eric Amorde on 8/2/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUPersonTableViewCell.h"

@interface SSUPersonTableViewCell ()

@end

@implementation SSUPersonTableViewCell

- (void) setDirectoryEntry:(SSUDirectoryObject *)directoryEntry {
    [super setDirectoryEntry:directoryEntry];
    self.person = (SSUPerson *)directoryEntry;
    [self updateDisplay];
}

- (void) updateDisplay {
    self.textLabel.text = self.person.displayName;
    NSMutableString * detail = [NSMutableString new];
    if (!SSUIsEmptyString(self.person.title)) {
        [detail appendString:self.person.title];
        
    }
    SSUDepartment * department = self.person.department;
    if (department != nil) {
        NSString * dept = (SSUIsEmptyString(self.person.title)) ? @"" : @" - ";
        [detail appendString:dept];
        [detail appendString:department.displayName];
    }
    
    self.detailTextLabel.text = (detail.length > 0) ? detail : nil;
}

@end
