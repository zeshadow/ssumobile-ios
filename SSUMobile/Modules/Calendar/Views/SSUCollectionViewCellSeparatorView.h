//
//  SSUCollectionViewCellSeparatorView.h
//  SSUMobile
//
//  Created by Eric Amorde on 8/31/15.
//  Copyright (c) 2015 Sonoma State University Department of Computer Science. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, SSUCellSeparator) {
    SSUCellSeparatorTop     = 1 << 0,
    SSUCellSeparatorRight   = 1 << 1,
    SSUCellSeparatorBottom  = 1 << 2,
    SSUCellSeparatorLeft    = 1 << 3,
    SSUCellSeparatorNone    = 0
};

/**
 *  A view which implements a separator line for UICollectionView cells.
 */
@interface SSUCollectionViewCellSeparatorView : UIView

@property (nonatomic) UIColor * separatorColor;
@property (nonatomic) SSUCellSeparator separator;
@property (nonatomic) CGFloat separatorLineWidth;

@end
