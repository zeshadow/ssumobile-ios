//
//  SSUSchoolTableViewCell.m
//  SSUMobile
//
//  Created by Eric Amorde on 8/3/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUSchoolTableViewCell.h"

@implementation SSUSchoolTableViewCell

- (void) setDirectoryEntry:(SSUDirectoryObject *)directoryEntry {
    [super setDirectoryEntry:directoryEntry];
    self.school = (id)directoryEntry;
    [self updateDisplay];
}

- (void) updateDisplay {
    self.textLabel.text = self.school.displayName;
}


@end
