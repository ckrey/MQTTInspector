//
//  MQTTInspectorMasterViewController.m
//  MQTTInspector
//
//  Created by Christoph Krey on 09.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "MQTTInspectorMasterViewController.h"

#import "MQTTInspectorDetailViewController.h"

#import "Session+Create.h"
#import "Subscription+Create.h"
#import "Publication+Create.h"

@interface MQTTInspectorMasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MQTTInspectorMasterViewController

- (void)viewDidLoad
{
    /* DEMO DB SETUP */
    Session *session1 = [Session sessionWithName:@"roo" host:@"roo.jpmens.net" port:1883 tls:NO auth:YES user:@"abc" passwd:@"xyz" clientid:nil cleansession:NO keepalive:60 inManagedObjectContext:self.managedObjectContext];
    Session *session2 = [Session sessionWithName:@"cky" host:@"http://fzvtoshindhfdqqo.myfritz.net" port:8883 tls:YES auth:YES user:@"abc" passwd:@"xyz" clientid:nil cleansession:NO keepalive:60 inManagedObjectContext:self.managedObjectContext];
    Session *session3 = [Session sessionWithName:@"mosquitto" host:@"test.mosquitto.org" port:1883 tls:NO auth:NO user:@"" passwd:@"" clientid:nil cleansession:YES keepalive:60 inManagedObjectContext:self.managedObjectContext];
    
    Subscription *subscription;
    subscription = [Subscription subscriptionWithTopic:@"#" qos:0 session:session1 inManagedObjectContext:self.managedObjectContext];
    subscription = [Subscription subscriptionWithTopic:@"loc/#" qos:1 session:session1 inManagedObjectContext:self.managedObjectContext];
    subscription = [Subscription subscriptionWithTopic:@"mqttitude/#" qos:2 session:session1 inManagedObjectContext:self.managedObjectContext];
    
    subscription = [Subscription subscriptionWithTopic:@"mqttitude/#" qos:2 session:session2 inManagedObjectContext:self.managedObjectContext];

    subscription = [Subscription subscriptionWithTopic:@"#" qos:0 session:session3 inManagedObjectContext:self.managedObjectContext];
    subscription = [Subscription subscriptionWithTopic:@"loc/#" qos:1 session:session3 inManagedObjectContext:self.managedObjectContext];
    subscription = [Subscription subscriptionWithTopic:@"mqttitude/#" qos:2 session:session3 inManagedObjectContext:self.managedObjectContext];
    subscription = [Subscription subscriptionWithTopic:@"system/+/chronos/#" qos:0 session:session3 inManagedObjectContext:self.managedObjectContext];

    Publication *publication;
    publication = [Publication publicationWithName:@"a1" topic:@"mqttitude/dt27/inspector1" qos:0 retained:NO data:[@"MQTTInspector" dataUsingEncoding:NSUTF8StringEncoding] session:session1 inManagedObjectContext:self.managedObjectContext];
    publication = [Publication publicationWithName:@"a2" topic:@"mqttitude/dt27/inspector2" qos:0 retained:NO data:[@"MQTTInspector" dataUsingEncoding:NSUTF8StringEncoding] session:session1 inManagedObjectContext:self.managedObjectContext];
    publication = [Publication publicationWithName:@"a3" topic:@"mqttitude/dt27/inspector3" qos:0 retained:NO data:[@"MQTTInspector" dataUsingEncoding:NSUTF8StringEncoding] session:session1 inManagedObjectContext:self.managedObjectContext];
    
    publication = [Publication publicationWithName:@"b" topic:@"mqttitude/dt27/inspector" qos:0 retained:NO data:[@"MQTTInspector" dataUsingEncoding:NSUTF8StringEncoding] session:session2 inManagedObjectContext:self.managedObjectContext];
    
    publication = [Publication publicationWithName:@"c1" topic:@"mqttitude/dt27/inspector3" qos:0 retained:NO data:[@"MQTTInspector" dataUsingEncoding:NSUTF8StringEncoding] session:session3 inManagedObjectContext:self.managedObjectContext];
    publication = [Publication publicationWithName:@"c2" topic:@"mqttitude/dt27/inspector1" qos:0 retained:NO data:[@"MQTTInspector" dataUsingEncoding:NSUTF8StringEncoding] session:session3 inManagedObjectContext:self.managedObjectContext];
    publication = [Publication publicationWithName:@"c3" topic:@"mqttitude/dt27/inspector2" qos:0 retained:NO data:[@"MQTTInspector" dataUsingEncoding:NSUTF8StringEncoding] session:session3 inManagedObjectContext:self.managedObjectContext];

    self.detailViewController.managedObjectContext = self.managedObjectContext;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    
    if (indexPath) {
        if ([segue.identifier isEqualToString:@"setSession:"]) {
            Session *session = [[self fetchedResultsController] objectAtIndexPath:indexPath];
            if ([segue.destinationViewController respondsToSelector:@selector(setSession:)]) {
                [segue.destinationViewController performSelector:@selector(setSession:)
                                                      withObject:session];
            }
        }
    }
}

#pragma mark - Table View

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"session" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Session *session = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    self.detailViewController.session = session;
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

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Session" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"host" ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"port" ascending:NO];
    NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"user" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor1, sortDescriptor2, sortDescriptor3];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
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

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Session *session = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = session.name;
}

@end
