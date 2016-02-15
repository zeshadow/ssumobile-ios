//
//  SSUDirectoryDetailController.m
//  SSUMobile
//
//  Created by Eric Amorde on 1/9/15.
//  Copyright (c) 2015 Computer Science. All rights reserved.
//

#import "SSUDirectoryDetailController.h"
#import "SSUDirectoryConstants.h"

@interface SSUDirectoryDetailController ()

@end

@implementation SSUDirectoryDetailController

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.navigationItem.rightBarButtonItem == nil) {
        UIImage * buttonImage = [UIImage imageNamed:@"directory_home"];
        UIBarButtonItem * homeButton = [[UIBarButtonItem alloc] initWithImage:buttonImage style:UIBarButtonItemStylePlain target:self action:@selector(homeButtonPressed:)];
        self.navigationItem.rightBarButtonItem = homeButton;
    }
}

- (void) homeButtonPressed:(UIBarButtonItem *)button {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/**
 So we don't have to maintain segues between all of the directory detail views
 and to avoid having to add 4-5 segues if we add a new entity, load and push
 the view controllers from the storyboard instead. Or just use segues.
 */
- (void) showDetailForObject:(SSUDirectoryObject *)object animated:(BOOL)animated {
    if (object == nil) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(detailTableView:didSelectObject:)]) {
        [self.delegate detailTableView:self didSelectObject:object];
        return;
    }
    
    UIStoryboard * storyBoard;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        storyBoard = [UIStoryboard storyboardWithName:SSUDirectoryStoryboardiPhone bundle:nil];
    } else {
        storyBoard = [UIStoryboard storyboardWithName:SSUDirectoryStoryboardiPad bundle:nil];
    }
    NSString * identifier = NSStringFromClass([object class]);
    SSUDirectoryDetailController * detail = [storyBoard instantiateViewControllerWithIdentifier:identifier];
    [detail loadObject:object inContext:object.managedObjectContext];
    if (self.navigationController) {
        [self.navigationController pushViewController:detail animated:animated];
    } else {
        [self presentViewController:detail animated:animated completion:NULL];
    }
}

@end
