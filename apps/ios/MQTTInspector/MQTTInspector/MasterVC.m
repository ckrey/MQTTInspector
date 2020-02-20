//
//  MasterVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 09.11.13.
//  Copyright © 2013-2020 Christoph Krey. All rights reserved.
//

#import "MasterVC.h"
#import "DetailVC.h"
#import "AppDelegate.h"

#import "Model.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

@interface MasterVC ()
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@end

@implementation MasterVC
static const DDLogLevel ddLogLevel = DDLogLevelError;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;

    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    NSArray<Session *> *sessions = [Session allSessions:appDelegate.managedObjectContext];

    if (sessions.count) {
        //
    } else {
        /* DEMO DB SETUP only if DB is empty */
        Session *session;

        /* mosquitto.org */
        session = [Session sessionWithName:@"mosquitto.org"
                    inManagedObjectContext:appDelegate.managedObjectContext];
        session.host = @"test.mosquitto.org";
        [Subscription subscriptionWithName:@"MQTTInspector"
                                     topic:@"MQTTInspector/#"
                                       qos:1
                                   noLocal:false
                         retainAsPublished:false
                            retainHandling:MQTTSendRetained
                    subscriptionIdentifier:0
                                   session:session
                    inManagedObjectContext:appDelegate.managedObjectContext];
        [Subscription subscriptionWithName:@"test"
                                     topic:@"test/+"
                                       qos:2
                                   noLocal:false
                         retainAsPublished:false
                            retainHandling:MQTTSendRetained
                    subscriptionIdentifier:0
                                   session:session
                    inManagedObjectContext:appDelegate.managedObjectContext];
        [Subscription subscriptionWithName:@"chronos"
                                     topic:@"system/+/chronos/#"
                                       qos:0
                                   noLocal:false
                         retainAsPublished:false
                            retainHandling:MQTTSendRetained
                    subscriptionIdentifier:0
                                   session:session
                    inManagedObjectContext:appDelegate.managedObjectContext];
        [Subscription subscriptionWithName:@"loc"
                                     topic:@"loc/#"
                                       qos:2
                                   noLocal:false
                         retainAsPublished:false
                            retainHandling:MQTTSendRetained
                    subscriptionIdentifier:0
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
                                      host:@"mqtt.eclipse.org"
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
                                 dnsdomain:nil
                             protocolLevel:4
                           attributefilter:@".*"
                               topicfilter:@".*"
                                datafilter:@".*"
                             includefilter:YES
                                 sizelimit:0
                    inManagedObjectContext:appDelegate.managedObjectContext];
        session.host = @"iot.eclipse.org";

        [Subscription subscriptionWithName:@"MQTTInspector"
                                      topic:@"MQTTInspector/#"
                                        qos:1
                                    noLocal:false
                          retainAsPublished:false
                             retainHandling:MQTTSendRetained
                     subscriptionIdentifier:0
                                    session:session
                     inManagedObjectContext:appDelegate.managedObjectContext];

        [Subscription subscriptionWithName:@"test"
                                     topic:@"test/+"
                                       qos:2
                                   noLocal:false
                         retainAsPublished:false
                            retainHandling:MQTTSendRetained
                    subscriptionIdentifier:0
                                   session:session
                    inManagedObjectContext:appDelegate.managedObjectContext];
        [Publication publicationWithName:@"ping"
                                   topic:@"MQTTInspector"
                                     qos:0
                                retained:NO
                                    data:[@"ping %t %c" dataUsingEncoding:NSUTF8StringEncoding]
                                 session:session inManagedObjectContext:appDelegate.managedObjectContext];
        /* mosca */
        session = [Session sessionWithName:@"mosca.io"
                    inManagedObjectContext:appDelegate.managedObjectContext];
        session.host = @"test.mosca.io";
        [Subscription subscriptionWithName:@"MQTTInspector"
                                     topic:@"MQTTInspector/#"
                                       qos:1
                                   noLocal:false
                         retainAsPublished:false
                            retainHandling:MQTTSendRetained
                    subscriptionIdentifier:0
                                   session:session
                    inManagedObjectContext:appDelegate.managedObjectContext];

        [Subscription subscriptionWithName:@"test"
                                     topic:@"test/+"
                                       qos:2
                                   noLocal:false
                         retainAsPublished:false
                            retainHandling:MQTTSendRetained
                    subscriptionIdentifier:0
                                   session:session
                    inManagedObjectContext:appDelegate.managedObjectContext];
        [Publication publicationWithName:@"ping"
                                   topic:@"MQTTInspector"
                                     qos:0
                                retained:NO
                                    data:[@"ping %t %c" dataUsingEncoding:NSUTF8StringEncoding]
                                 session:session inManagedObjectContext:appDelegate.managedObjectContext];

        /* HiveMQ */
        session = [Session sessionWithName:@"hivemq.com"
                    inManagedObjectContext:appDelegate.managedObjectContext];
        session.host = @"broker.hivemq.com";
        [Subscription subscriptionWithName:@"MQTTInspector"
                                     topic:@"MQTTInspector/#"
                                       qos:1
                                   noLocal:false
                         retainAsPublished:false
                            retainHandling:MQTTSendRetained
                    subscriptionIdentifier:0
                                   session:session
                    inManagedObjectContext:appDelegate.managedObjectContext];

        [Subscription subscriptionWithName:@"test"
                                     topic:@"test/+"
                                       qos:2
                                   noLocal:false
                         retainAsPublished:false
                            retainHandling:MQTTSendRetained
                    subscriptionIdentifier:0
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

- (IBAction)toggleEdit:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.editing = !self.editing;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate saveContext];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"newSession"]) {
        int i = 1;
        NSString *newName;
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

        do {
            newName = [NSString stringWithFormat:@"new-session-%d", i++];
        } while ([Session existSessionWithName:newName inManagedObjectContext:appDelegate.managedObjectContext]);

        Session *session = [Session sessionWithName:newName
                             inManagedObjectContext:appDelegate.managedObjectContext];
        session.host = @"host";
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
            Session *session = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if ([segue.destinationViewController respondsToSelector:@selector(setSession:)]) {
                [segue.destinationViewController performSelector:@selector(setSession:)
                                                      withObject:session];
            }
        }
    }

    if ([segue.identifier isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = (self.tableView).indexPathForSelectedRow;
        NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationViewController = (UINavigationController *)segue.destinationViewController;
            DetailVC *controller = (DetailVC *)navigationViewController.topViewController;
            controller.session = (Session *)object;
        }
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.fetchedResultsController).sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = (self.fetchedResultsController).sections[section];
    return sectionInfo.numberOfObjects;
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
        NSManagedObjectContext *context = (self.fetchedResultsController).managedObjectContext;
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

    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Session" inManagedObjectContext:appDelegate.managedObjectContext];
    fetchRequest.entity = entity;

    // Set the batch size to a suitable number.
    fetchRequest.fetchBatchSize = 20;

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor1];

    fetchRequest.sortDescriptors = sortDescriptors;

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

@end
