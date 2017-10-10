//
//  MQTTInspectorSubsTableViewController.m
//  MQTTInspector
//
//  Created by Christoph Krey on 12.11.13.
//  Copyright © 2013-2017 Christoph Krey. All rights reserved.
//

#import "MQTTInspectorSubsTableViewController.h"

#import "Model.h"

@interface MQTTInspectorSubsTableViewController ()
@end

@implementation MQTTInspectorSubsTableViewController

- (void)setTableView:(UITableView *)tableView
{
    super.tableView = tableView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)setupFRC
{
    NSFetchedResultsController *aFetchedResultsController;
    if (self.mother.session) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Subscription"
                                                  inManagedObjectContext:self.mother.session.managedObjectContext];
        fetchRequest.entity = entity;
        
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"belongsTo = %@", self.mother.session];
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20;
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"topic" ascending:YES];
        NSArray *sortDescriptors = @[sortDescriptor1, sortDescriptor2];
        
        fetchRequest.sortDescriptors = sortDescriptors;
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:self.mother.session.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
        aFetchedResultsController.delegate = self;
        
        
        NSError *error = nil;
        if (![aFetchedResultsController performFetch:&error]) {
            // Replace this implementation with code to handle     the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return aFetchedResultsController;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return [NSString stringWithFormat:@"SUBs"];
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"subscription" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Subscription *subscription = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", subscription.name];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"q%@ n%d r%d h%d i%u %@",
                                 subscription.qos,
                                 subscription.noLocal.boolValue,
                                 subscription.retainAsPublished.boolValue,
                                 subscription.retainHandling.intValue,
                                 subscription.susbscriptionIdentifier.unsignedIntValue,
                                 subscription.topic
                                 ];
    
    if ((subscription.state).boolValue) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.backgroundColor = subscription.UIcolor;
    
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        cell.detailTextLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    }
    
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    DDLogError(@"SUBs moveRowAtIndexPath %ld > %ld",
               (long)sourceIndexPath.row, (long)destinationIndexPath.row);
    self.noupdate = TRUE;
    for (NSUInteger i = 0; i < MIN(destinationIndexPath.row, sourceIndexPath.row); i++) {
        Subscription *sub = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (!sub.position || (sub.position).unsignedIntegerValue != i) {
            sub.position = @(i);
        }
    }

    if (sourceIndexPath.row < destinationIndexPath.row) {
        for (NSUInteger i = sourceIndexPath.row; i < destinationIndexPath.row; i++) {
            Subscription *sub = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:i + 1 inSection:0]];
            sub.position = @(i);
        }
    } else if (sourceIndexPath.row > destinationIndexPath.row) {
        for (NSUInteger i = sourceIndexPath.row; i > destinationIndexPath.row; i--) {
            Subscription *sub = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:i - 1 inSection:0]];
            sub.position = @(i);
        }
    }
    Subscription *sub = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:sourceIndexPath.row inSection:0]];
    sub.position = @(destinationIndexPath.row);
    
    id <NSFetchedResultsSectionInfo> sectionInfo = (self.fetchedResultsController).sections[0];
    for (NSUInteger i = MAX(destinationIndexPath.row, sourceIndexPath.row) + 1; i < sectionInfo.numberOfObjects; i++) {
        Subscription *sub = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (!sub.position || (sub.position).unsignedIntegerValue != i) {
            sub.position = @(i);
        }
    }
    
    self.noupdate = FALSE;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Subscription *subscription = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (self.mother.mqttSession.status == MQTTSessionStatusConnected) {
        if ((subscription.state).boolValue) {
            [self.mother.mqttSession unsubscribeTopicsV5:@[subscription.topic]
                                      unsubscribeHandler:nil
             ];
            subscription.state = @(false);
        } else {
            [self.mother.mqttSession subscribeToTopicV5:subscription.topic
                                                atLevel:subscription.qos.intValue
                                                noLocal:subscription.noLocal.boolValue
                                      retainAsPublished:subscription.retainAsPublished.boolValue
                                         retainHandling:subscription.retainHandling.intValue
                                 subscriptionIdentifier:subscription.susbscriptionIdentifier.unsignedShortValue
                                       subscribeHandler:nil
             ];
            subscription.state = @(true); // assuming subscribe works
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
