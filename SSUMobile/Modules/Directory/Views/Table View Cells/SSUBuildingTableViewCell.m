//
//  SSUBuildingTableViewCell.m
//  SSUMobile
//
//  Created by Eric Amorde on 8/3/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUBuildingTableViewCell.h"

@interface SSUBuildingTableViewCell()

@end

@implementation SSUBuildingTableViewCell

- (void) setDirectoryEntry:(SSUDirectoryObject *)directoryEntry {
    [super setDirectoryEntry:directoryEntry];
    self.building = (id)directoryEntry;
    [self updateDisplay];
}

- (void) updateDisplay {
    self.textLabel.text = self.building.displayName;
}


@end
