//
//  SSUNewsViewController.m
//  SSUMobile
//
//  Created by Andrew Huss on 2/1/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUNewsViewController.h"
#import "SSULogging.h"
#import "SSUNewsModule.h"
#import "SSUNewsConstants.h"
#import "SSUArticle.h"
#import "SSUNewsArticleTableViewCell.h"
#import "SSUWebViewController.h"
#import "SSUConfiguration.h"

@interface SSUNewsViewController ()

@property (nonatomic, strong) NSManagedObjectContext * context;

@end

@implementation SSUNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.context = [[SSUNewsModule sharedInstance] context];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:SSUNewsEntityArticle inManagedObjectContext:self.context];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"published" ascending:NO]];
    // Don't fetch articles older than 6 months
    NSDate * oldestToFetch = [[NSDate date] dateByAddingTimeInterval:-1*ABS(SSUNewsArticleFetchDateLimit)];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"published > %@",oldestToFetch];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:@"published" cacheName:nil];
    self.fetchedResultsController = aFetchedResultsController;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    const NSTimeInterval lastUpdate = [[[SSUConfiguration sharedInstance] dateForKey:SSUNewsUpdatedDateKey] timeIntervalSinceNow];
    const NSTimeInterval timeInterval = -1 * 60 * 5;
    if (lastUpdate <= timeInterval) {
        [self refresh];
    }
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

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = nil;
    if (!cellIdentifier) cellIdentifier = SSUNewsEntityArticle;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SSUArticle *article = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:SSUNewsEntityArticle]) {
        SSUNewsArticleTableViewCell* articleCell = (SSUNewsArticleTableViewCell*)cell;
        articleCell.article = article;
    }
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    static NSDateFormatter * dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterLongStyle;
        dateFormatter.timeStyle = NSDateFormatterLongStyle;
    }
    SSUArticle * article = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    return [dateFormatter stringFromDate:article.published];
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    SSUArticle * article = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    if (!SSUIsEmptyString(article.author))
        return [NSString stringWithFormat:@"by %@",article.author];
    else
        return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SSUArticle* article = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    SSUWebViewController* controller = [SSUWebViewController webViewControllerFromStoryboard];
    controller.urlToLoad = article.link;
    SSULogDebug(@"%@",article);
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Search Display

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    return YES;
}

@end