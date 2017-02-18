//
//  SSUNavigationController.m
//  SSUMobile
//
//  Created by Eric Amorde on 28/08/2016.
//  Copyright © 2016 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUNavigationController.h"

@interface SSUNavigationController () <UINavigationControllerDelegate>

@property (nonatomic, strong) UIView * barBackgroundView;

@end

@implementation SSUNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.barBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1.0)];
    self.barBackgroundView.backgroundColor = SSU_BLUE_COLOR;
    self.barBackgroundView.hidden = YES;
    [self.navigationBar addSubview:self.barBackgroundView];
    [self.navigationBar sendSubviewToBack:self.barBackgroundView];
    
    self.delegate = self;
    
    [self setNavigationBarTransparent:YES];
}

- (void) setNavigationBarTransparent:(BOOL)transparent {
    if (transparent) {
        [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.shadowImage = [UIImage new];
        self.navigationBar.barTintColor = [UIColor clearColor];
        self.navigationBar.translucent = YES;
    }
    else {
        UINavigationBar * appearance = [UINavigationBar appearance];
        [self.navigationBar setBackgroundImage:[appearance backgroundImageForBarMetrics:UIBarMetricsDefault]
                                 forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.shadowImage = appearance.shadowImage;
        self.navigationBar.barTintColor = appearance.barTintColor;
        self.navigationBar.translucent = NO;
    }
}

- (UIViewController *) popViewControllerAnimated:(BOOL)animated {
    if (self.viewControllers.count == 2) {
        [self setNavigationBarTransparent:YES];
    }
    return [super popViewControllerAnimated:animated];
}


- (void) navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (animated) {
        if (viewController == self.viewControllers.firstObject) {
            [self setNavigationBarTransparent:YES];
            [self.navigationBar layoutSubviews];
        }
        else {
            [self setNavigationBarTransparent:NO];
        }
    }
}


@end
