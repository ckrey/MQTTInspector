//
//  MQTTInspectorMessagesTableViewController.m
//  MQTTInspector
//
//  Created by Christoph Krey on 17.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "MQTTInspectorMessagesTableViewController.h"
#import "Session.h"
#import "Subscription+Create.h"

@interface MQTTInspectorMessagesTableViewController ()
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (NSFetchRequest *)fetchRequestForTableView;
@end

@implementation MQTTInspectorMessagesTableViewController

- (void)setTableView:(UITableView *)tableView
{
    [super setTableView:tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
}

#pragma mark - Fetched results controller

- (NSFetchRequest *)fetchRequestForTableView
{
    // abstract
    return nil;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
                                                             initWithFetchRequest:[self fetchRequestForTableView]
                                                             managedObjectContext:self.mother.managedObjectContext
                                                             sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle     the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"message" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // abstract
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // abstract
    return nil;
}

- (UIColor *)matchingTopicColor:(NSString *)topic inSession:(Session *)session
{
    UIColor *color = [UIColor whiteColor];
    int best = -1;
    
    for (Subscription *subscription in session.hasSubs) {
        
        int points = [self pointsTopic:topic matchingSub:subscription.topic];
        if (points > best) {
            color = [subscription getColor];
            best = points;
        }
    }
    return color;
}

- (int)pointsTopic:(NSString *)topic matchingSub:(NSString *)subscription
{
    int points = -1;
    
    NSArray *topicComponents = [topic pathComponents];
    NSArray *subscriptionComponents = [subscription pathComponents];
    
    int i;
    int match = 0;
    
    for (i = 0; (i < [topicComponents count]) && (i < [subscriptionComponents count]); i++) {
        if ([subscriptionComponents[i] isEqualToString:topicComponents[i]]) {
            if ((i == [subscriptionComponents count] - 1) && (i == [topicComponents count] - 1)) {
                match = 5;
            } else {
                match = 3;
            }
            continue;
        }
        
        if ([subscriptionComponents[i] isEqualToString:@"+"]) {
            match = 2;
            continue;
        }
        
        if ([subscriptionComponents[i] isEqualToString:@"#"]) {
            match = 1;
            break;
        }
        
        if (![subscriptionComponents[i] isEqualToString:topicComponents[i]]) {
            match = 0;
            break;
        }
    }
    
    if (match) {
        if (((i == [subscriptionComponents count] - 1) && ([subscriptionComponents[i] isEqualToString:@"#"])) ||
            ((match > 1) && (i == [subscriptionComponents count]) && (i == [topicComponents count]))) {
            points = i * 10 + match;
        }
    }
    NSLog(@"topic %@(%lu) matches %@(%lu) specific:%d match:%d",
          topic, (unsigned long)[topicComponents count], subscription, (unsigned long)[subscriptionComponents count], i, match);

    return points;
}


@end
