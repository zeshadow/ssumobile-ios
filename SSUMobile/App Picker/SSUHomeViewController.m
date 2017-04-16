//
//  SSUHomeViewController.m
//  SSUMobile
//
//  Created by Eric Amorde on 7/30/14.
//  Copyright (c) 2014 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUHomeViewController.h"
#import "SSUGlobalNavigationController.h"
#import "SSUAppPickerModuleCell.h"
#import "SSUSpotlightServices.h"
#import "SSUMobile-Swift.h"

#import <Masonry/Masonry.h>

static NSInteger COLS = 3;
static CGFloat MARGIN = 5.0;
static NSInteger BLANK_CELL_INDEX = 7;

@interface SSUHomeViewController () <UICollectionViewDelegate,UICollectionViewDataSource, SSUModuleCellDelegate>

@property (nonatomic, strong) NSArray * modules;
@property (nonatomic, strong) id navBarModule;
@property (nonatomic, strong) NSIndexPath * blankCellIndexPath;
@property (nonatomic) CGSize cellSize;

@property (nonatomic, strong) UIViewController * controllerToPresent;

@property (nonatomic, strong) IBOutlet UIImageView * backgroundImageView;
@property (nonatomic, strong) UIView * barBackgroundView;

@end

@implementation SSUHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self resetCellSize];
    
    self.barBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1.0)];
    self.barBackgroundView.backgroundColor = SSU_BLUE_COLOR;
    self.barBackgroundView.hidden = YES;
    
    [self.backgroundImageView addSubview:self.barBackgroundView];
    
    self.blankCellIndexPath = [NSIndexPath indexPathForItem:7 inSection:0];
    
    [self loadModules];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"edu.sonoma.modules.loaded.notification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [self loadModules];
        [self.collectionView reloadData];
    }];
    
    // TODO: Move this to a global navigation controller
    [[NSNotificationCenter defaultCenter] addObserverForName:SSUSpotlightActivityRequestingDisplayNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        UIViewController * controller = note.object;
        self.controllerToPresent = controller;
        if (self.navigationController.viewControllers.lastObject != self) {
            [self.navigationController popToViewController:self animated:YES];
        }
        else {
            [self.navigationController pushViewController:self.controllerToPresent animated:YES];
            self.controllerToPresent = nil;
        }
    }];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[SSUGlobalNavigationController sharedInstance] setNavigationBarTransparent:YES];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.controllerToPresent != nil) {
        [self.navigationController pushViewController:self.controllerToPresent animated:YES];
        self.controllerToPresent = nil;
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[SSUGlobalNavigationController sharedInstance] setNavigationBarTransparent:NO];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void) loadModules {
    NSMutableArray * modules = [[[SSUModuleServices sharedInstance] modulesUI] mutableCopy];
    id<SSUModuleUI> navBarModule = nil;
    for (id<SSUModuleUI> module in modules) {
        if ([module respondsToSelector:@selector(showModuleInNavigationBar)] &&
            [module showModuleInNavigationBar]) {
            navBarModule = module;
            break;
        }
    }
    
    if (navBarModule) {
        UIButton * navView = (UIButton *)[navBarModule viewForHomeScreen];
        UIBarButtonItem * barItem = [[UIBarButtonItem alloc] initWithCustomView:navView];
        [navView addTarget:self action:@selector(navBarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = barItem;
        self.navBarModule = navBarModule;
        [modules removeObject:navBarModule];
    }
    
    self.modules = modules;
}

- (void) resetCellSize {
    // Create a CGSize that will fit the cells to the number of columns we want
    CGFloat margin = MARGIN * (COLS+1);
    CGRect screen = [[UIScreen mainScreen] applicationFrame];
    CGFloat width = roundf((screen.size.width - margin)/COLS);
    if (screen.size.height <= 480) {
        width = 82; // iPhone 4/4Ss are tiny, make the cells a bit smaller
    }
    self.cellSize = CGSizeMake(width, width);;
    UICollectionViewFlowLayout * layout = (id)self.collectionView.collectionViewLayout;
    layout.itemSize = self.cellSize;
}

#pragma mark - Collection View

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.modules.count + 1; // + 1 for blank cell
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == BLANK_CELL_INDEX) {
        UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BlankCell" forIndexPath:indexPath];
        return cell;
    }
    NSString * cellName = @"ModuleCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellName forIndexPath:indexPath];
    // In iOS 7, the contentView property is broken and shrinks for some reason. Force it to be the size
    // that we want
    CGRect newFrame = cell.contentView.frame;
    newFrame.size = self.cellSize;
    cell.contentView.frame = newFrame;
    
    id<SSUModuleUI> module = [self moduleAtIndexPath:indexPath];
    SSUAppPickerModuleCell * moduleCell = (SSUAppPickerModuleCell *)cell;
    moduleCell.module = module;
    moduleCell.delegate = self;
    
    return cell;
}

- (CGSize) collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)layout
   sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellSize;
}

- (void) moduleCellWasSelected:(SSUAppPickerModuleCell *)cell {
    id<SSUModuleUI> module = cell.module;
    if ([module shouldNavigateToModule]) {
        UIViewController * viewController = [module initialViewController];
        [self.navigationController pushViewController:viewController animated:YES];
        [UIView animateWithDuration:0.75 animations:^{
            self.barBackgroundView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height);
        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma mark - Button Actions

- (void) navBarButtonPressed:(id)sender {
    UIViewController * viewController = [self.navBarModule initialViewController];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Helper

- (NSIndexPath *) translateIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= BLANK_CELL_INDEX && indexPath.section == 0) {
        return [NSIndexPath indexPathForItem:indexPath.item-1 inSection:indexPath.section];
    }
    return indexPath;
}

- (id<SSUModuleUI>) moduleAtIndexPath:(NSIndexPath *) indexPath {
    indexPath = [self translateIndexPath:indexPath];
    return self.modules[indexPath.item];
}

/** 
 Attempts to trigger a selection animation, whether by calling setSelected:animated:
 or by calling setHighlighted:animated:
 */
- (void) selectView:(UIView *)view {
    id generic = view;
    if ([generic respondsToSelector:@selector(sendActionsForControlEvents:)]) {
        // UIButton
        [generic setHighlighted:YES];
        [generic sendActionsForControlEvents:UIControlEventTouchUpInside];
        [generic setHighlighted:NO];
    }
    else if ([generic respondsToSelector:@selector(setSelected:animated:)]) {
        [generic setSelected:YES animated:YES];
    }
    else if ([generic respondsToSelector:@selector(setHighlighted:animated:)]) {
        [generic setHighlighted:YES animated:YES];
    }
}

@end
