//
//  SSUDirectoryTableViewCell.m
//  SSUMobile
//
//  Created by Eric Amorde on 7/31/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUDirectoryTableViewCell.h"

@interface SSUDirectoryTableViewCell()

@property (nonatomic) CAShapeLayer * maskLayer;

@end

@implementation SSUDirectoryTableViewCell

- (void) prepareForReuse {
    [super prepareForReuse];
    self.directoryEntry = nil;
}

@end
