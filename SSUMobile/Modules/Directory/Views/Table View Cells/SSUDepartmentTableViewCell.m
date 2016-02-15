//
//  SSUDepartmentTableViewCell.m
//  SSUMobile
//
//  Created by Eric Amorde on 8/2/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUDepartmentTableViewCell.h"

@interface SSUDepartmentTableViewCell()

@end

@implementation SSUDepartmentTableViewCell

- (void) setDirectoryEntry:(SSUDirectoryObject *)directoryEntry {
    [super setDirectoryEntry:directoryEntry];
    self.department = (SSUDepartment *) directoryEntry;
    [self updateDisplay];
}

- (void) updateDisplay {
    self.textLabel.text = self.department.displayName;
    self.detailTextLabel.text = (self.department.school != nil) ? self.department.school.displayName : nil;
}



@end
