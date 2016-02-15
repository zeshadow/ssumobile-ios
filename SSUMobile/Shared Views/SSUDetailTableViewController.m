//
//  SSUDetailTableViewController.m
//  SSUMobile
//
//  Created by Andrew Huss on 1/31/13.
//  Copyright (c) 2013 Sonoma State University Department of Computer Science. All rights reserved.
//

#import "SSUDetailTableViewController.h"
#import "SSULogging.h"

@interface SSUDetailTableViewController ()

@property (weak, nonatomic) SSUDetailTableViewController* container;
@property (strong, nonatomic) NSString* entityName;
@property (strong, nonatomic) NSString* attributeName;
@property (strong, nonatomic) id attributeValue;

@property (strong, nonatomic) NSManagedObjectContext* context;
@property (strong, nonatomic) NSManagedObject* object;

@property (strong, nonatomic) NSMutableSet * hiddenIndices;
@end

@implementation SSUDetailTableViewController

- (void) loadObject:(NSManagedObject*)object inContext:(NSManagedObjectContext*)context {
    [self setContext:context];
    [self setObject:object];
    [self updateObject];
}


- (void) setObject:(NSManagedObject *)object {
    _object = object;
    if ([_container respondsToSelector:@selector(setObject:)]) {
        SSULogDebug(@"Updating Container: %@", NSStringFromClass([_container class]));
        [_container performSelector:@selector(setObject:) withObject:_object];
    }
    
    _entityName = object.entity.name;
    _attributeName = @"self";
    _attributeValue = object;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateObject];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self.delegate respondsToSelector:@selector(detailTableViewDidAppear:)])
        [self.delegate detailTableViewDidAppear:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableSet *) hiddenIndices {
    if (_hiddenIndices) {
        return _hiddenIndices;
    }
    
    _hiddenIndices = [NSMutableSet new];
    return _hiddenIndices;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"container"]) {
        [self setContainer:(SSUDetailTableViewController*)segue.destinationViewController];
        return;
    }
    else {
        SSULogDebug(@"%@: Unknown Segue: %@", NSStringFromClass([self class]), segue.identifier);
    }
}

- (void) setContainer:(SSUDetailTableViewController *)container {
    _container = container;
    [_container setObject:_object];
}

- (void) updateObject {
    SSULogDebug(@"Update Object");
    [_container updateObject];
}

- (void) fetchObject {
    SSULogDebug(@"Fetching Object");
    [self setObject:[self managedObjectForEntity:_object.entity.name withAttributeName:@"self" attributeValue:_object]];
    [self updateObject];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self cellHiddenAtIndexPath:indexPath]) {
        cell.hidden = YES;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self cellHiddenAtIndexPath:indexPath]) {
        return 0;
    }
    return UITableViewAutomaticDimension;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    return cell.tag ? cell.textLabel.enabled : NO;
}

#pragma mark - IBActions

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    return (action == @selector(copy:) && (cell.textLabel || cell.detailTextLabel));
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)) {
        UIPasteboard *board = [UIPasteboard generalPasteboard];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString * pasteData = cell.textLabel.text;
        if (pasteData) {
            board.string = pasteData;
        }
        else if ((pasteData = cell.detailTextLabel.text)) {
            board.string = pasteData;
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (NSManagedObject*) managedObjectForEntity:(NSString*)entityName withAttributeName:(NSString*)attributeName attributeValue:(id)attributeValue {
    NSManagedObjectContext* context = _context;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setIncludesSubentities:NO];
    
    request.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"%K == %@", _attributeName, _attributeValue];
    
    SSULogDebug(@"Fetching object...");
    
    NSError *error = nil;
    NSArray* results = [context executeFetchRequest:request error:&error];
    if (error) {
        SSULogError(@"Error: %@", error.debugDescription);
    }
    return (NSManagedObject*)[results lastObject];
}


#pragma mark - Cell Hiding

- (void) hideCellAtIndexPath:(NSIndexPath *)indexPath {
    // indexPath is not guaranteed to be an NSIndexPath, ie can be a UIMutableIndexPath etc.
    // so the [NSMutableSet containsObject:] method will fail since isEqual: will always be false
    // To work around this, create a new NSIndexPath
    NSIndexPath * path = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    [self.hiddenIndices addObject:path];
}

- (void) unhideCellAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath * path = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    [self.hiddenIndices removeObject:path];
}

- (void) unhideAllCells {
    [self.hiddenIndices removeAllObjects];
}

- (BOOL) cellHiddenAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath * path = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    return [self.hiddenIndices containsObject:path];
}

@end
