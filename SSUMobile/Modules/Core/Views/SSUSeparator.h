//
//  SSUSeparator.h
//  SSUMobile
//
//  Created by Eric Amorde on 4/4/17.
//  Copyright © 2017 Sonoma State University Department of Computer Science. All rights reserved.
//

/**
 Defines edges of a cell separator in a table view or collection view
 
 @note This needs to be defined in Objective-C because a Swift struct cannot be imported into Objective-C.
 */
typedef NS_OPTIONS(NSUInteger, SSUCellSeparator) {
    SSUCellSeparatorTop     = 1 << 0,
    SSUCellSeparatorRight   = 1 << 1,
    SSUCellSeparatorBottom  = 1 << 2,
    SSUCellSeparatorLeft    = 1 << 3,
    SSUCellSeparatorNone    = 0
};
