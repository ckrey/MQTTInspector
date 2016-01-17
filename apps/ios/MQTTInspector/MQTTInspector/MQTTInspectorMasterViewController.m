//
//  MQTTInspectorMasterViewController.m
//  MQTTInspector
//
//  Created by Christoph Krey on 09.11.13.
//  Copyright © 2013-2016 Christoph Krey. All rights reserved.
//

#import "MQTTInspectorMasterViewController.h"
#import "MQTTInspectorDetailViewController.h"
#import "MQTTInspectorAppDelegate.h"

#import "Model.h"

@interface MQTTInspectorMasterViewController ()
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation MQTTInspectorMasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.splitViewController.delegate = self;
    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
    
    MQTTInspectorAppDelegate *appDelegate = (MQTTInspectorAppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSArray<Session *> *sessions = [Session allSessions:appDelegate.managedObjectContext];
    
    if (sessions.count) {
        //
    } else {
        /* DEMO DB SETUP only if DB is empty */
        Session *session;
        
        /* mosquitto.org */
        session = [Session sessionWithName:@"mosquitto.org"
                                      host:@"test.mosquitto.org"
                                      port:1883
                                       tls:NO
                                      auth:NO
                                      user:@""
                                    passwd:@""
                                  clientid:nil
                              cleansession:YES
                                 keepalive:60
                               autoconnect:YES
                                    dnssrv:YES
                                 dnsdomain:@"mosquitto.org"
                             protocolLevel:4
                           attributefilter:@".*"
                               topicfilter:@".*"
                                datafilter:@".*"
                             includefilter:YES
                                 sizelimit:0
                    inManagedObjectContext:appDelegate.managedObjectContext];
        [Subscription subscriptionWithTopic:@"MQTTInspector/#"
                                        qos:1
                                    session:session
                     inManagedObjectContext:appDelegate.managedObjectContext];
        [Subscription subscriptionWithTopic:@"test/+"
                                        qos:2
                                    session:session
                     inManagedObjectContext:appDelegate.managedObjectContext];
        [Subscription subscriptionWithTopic:@"system/+/chronos/#"
                                        qos:0 session:session
                     inManagedObjectContext:appDelegate.managedObjectContext];
        [Subscription subscriptionWithTopic:@"loc/#"
                                        qos:2
                                    session:session
                     inManagedObjectContext:appDelegate.managedObjectContext];
        
        [Publication publicationWithName:@"ping"
                                   topic:@"MQTTInspector"
                                     qos:0
                                retained:NO
                                    data:[@"ping %t %c" dataUsingEncoding:NSUTF8StringEncoding]
                                 session:session inManagedObjectContext:appDelegate.managedObjectContext];
        
        /* eclipse.org */
        session = [Session sessionWithName:@"eclipse.org"
                                      host:@"m2m.eclipse.org"
                                      port:1883
                                       tls:NO
                                      auth:NO
                                      user:@""
                                    passwd:@""
                                  clientid:nil
                              cleansession:YES
                                 keepalive:60
                               autoconnect:NO
                                    dnssrv:NO
                                 dnsdomain:@"eclipse.org"
                             protocolLevel:4
                           attributefilter:@".*"
                               topicfilter:@".*"
                                datafilter:@".*"
                             includefilter:YES
                                 sizelimit:0
                    inManagedObjectContext:appDelegate.managedObjectContext];
        [Subscription subscriptionWithTopic:@"MQTTInspector/#"
                                        qos:1
                                    session:session
                     inManagedObjectContext:appDelegate.managedObjectContext];
        
        [Subscription subscriptionWithTopic:@"test/+"
                                        qos:2
                                    session:session
                     inManagedObjectContext:appDelegate.managedObjectContext];
        [Publication publicationWithName:@"ping"
                                   topic:@"MQTTInspector"
                                     qos:0
                                retained:NO
                                    data:[@"ping %t %c" dataUsingEncoding:NSUTF8StringEncoding]
                                 session:session inManagedObjectContext:appDelegate.managedObjectContext];
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"newSession"]) {
        int i = 1;
        NSString *newName;
        MQTTInspectorAppDelegate *appDelegate = (MQTTInspectorAppDelegate *)[UIApplication sharedApplication].delegate;

        do {
            newName = [NSString stringWithFormat:@"new-session-%d", i++];
        } while ([Session existSessionWithName:newName inManagedObjectContext:appDelegate.managedObjectContext]);
        
        Session *session = [Session sessionWithName:newName
                                               host:@"host"
                                               port:1883
                                                tls:NO
                                               auth:NO
                                               user:@""
                                             passwd:@""
                                           clientid:@""
                                       cleansession:YES
                                          keepalive:60
                                        autoconnect:YES
                                             dnssrv:NO
                                             dnsdomain:@""
                                      protocolLevel:4
                                    attributefilter:@".*"
                                        topicfilter:@".*"
                                         datafilter:@".*"
                                      includefilter:YES
                                          sizelimit:0
                             inManagedObjectContext:appDelegate.managedObjectContext];
        if ([segue.destinationViewController respondsToSelector:@selector(setSession:)]) {
            [segue.destinationViewController performSelector:@selector(setSession:)
                                                  withObject:session];
        }
    }
    
    if ([segue.identifier isEqualToString:@"setSession:"] || [segue.identifier isEqualToString:@"setSessionForEdit:"]) {
        
        NSIndexPath *indexPath = nil;
        
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            indexPath = [self.tableView indexPathForCell:sender];
        }
        
        if (indexPath) {
            Session *session = [[self fetchedResultsController] objectAtIndexPath:indexPath];
            if ([segue.destinationViewController respondsToSelector:@selector(setSession:)]) {
                [segue.destinationViewController performSelector:@selector(setSession:)
                                                      withObject:session];
            }
        }
    }
    
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        MQTTInspectorDetailViewController *controller = (MQTTInspectorDetailViewController *)[[segue destinationViewController] topViewController];
        [controller setSession:(Session *)object];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"session" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    MQTTInspectorAppDelegate *appDelegate = (MQTTInspectorAppDelegate *)[UIApplication sharedApplication].delegate;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Session" inManagedObjectContext:appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor1];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:appDelegate.managedObjectContext
                                                                                                  sectionNameKeyPath:nil
                                                                                                           cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Session *session = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = session.name;
}

#pragma mark - UISplitViewControllerDelegate
- (BOOL)splitViewController:(UISplitViewController *)splitViewController
collapseSecondaryViewController:(UIViewController *)secondaryViewController
  ontoPrimaryViewController:(UIViewController *)primaryViewController {
    
    if ([secondaryViewController isKindOfClass:[UINavigationController class]]
        && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[MQTTInspectorDetailViewController class]]
        && ([(MQTTInspectorDetailViewController *)[(UINavigationController *)secondaryViewController topViewController] session] == nil)) {
        
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
        
    } else {
        
        return NO;
        
    }
}

@end
