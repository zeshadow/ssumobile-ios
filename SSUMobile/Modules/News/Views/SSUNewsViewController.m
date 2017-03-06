//
//  SSUNewsViewController.m
//  SSUMobile
//
//  Created by Andrew Huss on 2/1/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

@import SafariServices;

#import "SSUNewsViewController.h"
#import "SSUSelectionController.h"
#import "SSULogging.h"
#import "SSUNewsModule.h"
#import "SSUNewsConstants.h"
#import "SSUArticle.h"
#import "SSUNewsArticleTableViewCell.h"
#import "SSUWebViewController.h"
#import "SSUConfiguration.h"

@interface SSUNewsViewController () <SSUSelectionDelegate>

@property (nonatomic, strong) NSManagedObjectContext * context;
@property (nonatomic, strong) NSPredicate * predicate;
@property (nonatomic, strong) UIBarButtonItem * filterButton;

@end

@implementation SSUNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.context = [[SSUNewsModule sharedInstance] context];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    self.filterButton = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStyleDone target:self action:@selector(filterButtonPressed)];
    UIBarButtonItem * flexibleWidthButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    self.toolbarItems = @[flexibleWidthButton, self.filterButton, flexibleWidthButton];
    
    self.fetchedResultsController = [self makeFetchedResultsController];
    self.searchFetchedResultsController = [self makeFetchedResultsController];
    self.searchKey = @"title";
    
    [self.tableView registerClass:[SSUNewsArticleTableViewCell class]
           forCellReuseIdentifier:SSUNewsEntityArticle];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.rowHeight = (int)([UIScreen mainScreen].applicationFrame.size.height / 4);
    [self.tableView reloadData];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    const NSTimeInterval lastUpdate = [[[SSUConfiguration sharedInstance] dateForKey:SSUNewsUpdatedDateKey] timeIntervalSinceNow];
    const NSTimeInterval timeInterval = -1 * 60 * 5;
    if (lastUpdate <= timeInterval) {
        [self refresh];
    }
    self.navigationController.toolbarHidden = NO;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.toolbarHidden = YES;
}

- (void)refresh {
    SSULogDebug(@"Refresh News");
    if (!self.refreshControl.refreshing)
        [self.refreshControl beginRefreshing];
    [[SSUNewsModule sharedInstance] updateData:^{
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    }];
}

- (void) setPredicate:(NSPredicate *)predicate {
    _predicate = predicate;
    self.fetchedResultsController.fetchRequest.predicate = _predicate;
    [self.fetchedResultsController performFetch:nil];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = nil;
    if (!cellIdentifier) cellIdentifier = SSUNewsEntityArticle;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SSUArticle *article = (SSUArticle *)[self objectAtIndex:indexPath];
    if ([cell.reuseIdentifier isEqualToString:SSUNewsEntityArticle]) {
        SSUNewsArticleTableViewCell* articleCell = (SSUNewsArticleTableViewCell*)cell;
        articleCell.article = article;
        articleCell.separatorInset = UIEdgeInsetsZero;
        articleCell.layoutMargins = UIEdgeInsetsZero;
    }
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SSUArticle* article = [self.currentFetchedResultsController objectAtIndexPath:indexPath];
    NSURL * url = [NSURL URLWithString:article.link];
    SSULogDebug(@"%@",article);
    if (NSStringFromClass([SFSafariViewController class])) {
        SFSafariViewController * vc = [[SFSafariViewController alloc] initWithURL:url entersReaderIfAvailable:YES];
        vc.preferredBarTintColor = SSU_BLUE_COLOR;
        [self presentViewController:vc animated:YES completion:NULL];
    }
    else {
        SSUWebViewController* controller = [SSUWebViewController webViewController];
        controller.urlToLoad = [NSURL URLWithString:article.link];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (NSPredicate *) searchPredicateForText:(NSString *)searchText {
    NSPredicate * base = [self basePredicate];
    NSPredicate * search = [super searchPredicateForText:searchText];
    if (self.predicate != nil) {
        return [NSCompoundPredicate andPredicateWithSubpredicates:@[base, search, self.predicate]];
    } else {
        return [NSCompoundPredicate andPredicateWithSubpredicates:@[base, search]];
    }
}

#pragma mark - Actions

- (void) filterButtonPressed {
    NSArray * categories = [@[@"All Categories"] arrayByAddingObjectsFromArray:[self allCategories]];
    SSUSelectionController * selectionController = [[SSUSelectionController alloc] initWithItems:categories];
    selectionController.delegate = self;
    if (self.predicate == nil) {
        selectionController.defaultIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    else {
        NSString * current = [[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] category];
        NSInteger row = (NSInteger)[categories indexOfObject:current];
        selectionController.defaultIndex = [NSIndexPath indexPathForRow:row inSection:0];
    }
    [self.navigationController pushViewController:selectionController animated:YES];
}

- (void) userDidSelectItem:(id)item atIndexPath:(NSIndexPath *)indexPath fromController:(SSUSelectionController *)controller {
    if ([item isEqualToString:@"All Categories"]) {
        self.predicate = nil;
        self.filterButton.title = @"Filter";
    }
    else {
        NSString * categoryName = item;
        self.filterButton.title = categoryName;
        self.predicate = [NSPredicate predicateWithFormat:@"category = %@", categoryName];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) selectionControllerDismissed:(SSUSelectionController *)controller {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - private

- (NSPredicate *) basePredicate {
    // Don't fetch articles older than 6 months
    NSDate * oldestToFetch = [[NSDate date] dateByAddingTimeInterval:-1*ABS(SSUNewsArticleFetchDateLimit)];
    return [NSPredicate predicateWithFormat:@"published > %@",oldestToFetch];
}

- (NSFetchedResultsController *) makeFetchedResultsController {
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:SSUNewsEntityArticle inManagedObjectContext:self.context];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"published" ascending:NO]];
    fetchRequest.predicate = [self basePredicate];
    
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                 managedObjectContext:self.context
                                                                                   sectionNameKeyPath:@"published"
                                                                                            cacheName:nil];
    return controller;
}

- (NSArray *) allCategories {
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:SSUNewsEntityArticle];
    NSString * categoryKeyName = @"category";
    request.propertiesToFetch = @[categoryKeyName];
    request.returnsDistinctResults = YES;
    request.resultType = NSDictionaryResultType;
    
    NSArray * objects = [[SSUNewsModule sharedInstance].context executeFetchRequest:request error:nil];
    NSMutableArray * categories = [NSMutableArray arrayWithCapacity:objects.count];
    for (NSDictionary * dict in objects) {
        if (dict[categoryKeyName] != nil) {
            [categories addObject:dict[categoryKeyName]];
        }
    }
    return [categories sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

@end
