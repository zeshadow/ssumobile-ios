//
//  SSUHomeViewController.h
//  SSUMobile
//
//  Created by Eric Amorde on 7/30/14.
//  Copyright (c) 2014 Computer Science. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSUHomeViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic,weak) IBOutlet UICollectionView * collectionView;

@end
