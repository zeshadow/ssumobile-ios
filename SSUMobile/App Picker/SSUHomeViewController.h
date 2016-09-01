//
//  SSUHomeViewController.h
//  SSUMobile
//
//  Created by Eric Amorde on 7/30/14.
//  Copyright (c) 2014 Sonoma State University Department of Computer Science. All rights reserved.
//

@import UIKit;

@interface SSUHomeViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic,weak) IBOutlet UICollectionView * collectionView;

@end
