//
//  SubsTVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright © 2013-2020 Christoph Krey. All rights reserved.
//

#import "SubsTVC.h"
#import "SubTVC.h"

#import "Model.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

@interface SubsTVC ()
@property (strong, nonatomic) UIBarButtonItem *extraButton;

@end

@implementation SubsTVC
static const DDLogLevel ddLogLevel = DDLogLevelError;

- (void)viewDidAppear:(BOOL)animated {
    if (self.extraButton) {
        NSMutableArray<UIBarButtonItem *> *a = [self.navigationItem.rightBarButtonItems mutableCopy];
        if (a) {
            [a removeObject:self.extraButton];
            [self.navigationItem setRightBarButtonItems:a animated:FALSE];
        }
        self.extraButton = nil;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"setSub:"]) {
        
        NSIndexPath *indexPath = nil;
        
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            indexPath = [self.tableView indexPathForCell:sender];
        }
        
        if (indexPath) {
            Subscription *sub = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if ([segue.destinationViewController respondsToSelector:@selector(setSub:)]) {
                [segue.destinationViewController performSelector:@selector(setSub:)
                                                      withObject:sub];
            }
        }
    }
    
    if ([segue.identifier isEqualToString:@"newSub"]) {
        NSInteger i = 0;
        NSString *newName;
        do {
            i++;
            newName = [NSString stringWithFormat:@"new-sub-%ld",
                       i];
        } while ([Subscription existsSubscriptionWithName:newName
                                                   session:self.session
                                    inManagedObjectContext:self.session.managedObjectContext]);

        Subscription *sub = [Subscription subscriptionWithName:newName
                                                         topic:newName
                                                           qos:0
                                                       noLocal:false
                                             retainAsPublished:false
                                                retainHandling:MQTTSendRetained
                                        subscriptionIdentifier:0
                                                       session:self.session
                                        inManagedObjectContext:self.session.managedObjectContext];
        if ([segue.destinationViewController respondsToSelector:@selector(setSub:)]) {
            [segue.destinationViewController performSelector:@selector(setSub:)
                                                  withObject:sub];
        }
    }
}

- (IBAction)toggleEdit:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.editing = !self.editing;
    }
}

- (void)copyEntry {
    NSIndexPath *selected = self.tableView.indexPathForSelectedRow;
    Subscription *sub = [self.fetchedResultsController objectAtIndexPath:selected];

    NSInteger i = 0;
    NSString *newName;
    do {
        i++;
        newName = [NSString stringWithFormat:@"%@-%ld",
                   sub.name, i];
    } while ([Subscription existsSubscriptionWithName:newName
                                               session:self.session
                                inManagedObjectContext:self.session.managedObjectContext]);

    [Subscription subscriptionWithName:newName
                                 topic:sub.topic
                                   qos:sub.qos.unsignedCharValue
                               noLocal:sub.noLocal.boolValue
                     retainAsPublished:sub.retainAsPublished.boolValue
                        retainHandling:sub.retainHandling.unsignedCharValue
                subscriptionIdentifier:sub.susbscriptionIdentifier.unsignedShortValue
                               session:self.session
                inManagedObjectContext:self.session.managedObjectContext];
}

#pragma mark - Table View

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sub" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath {
    Subscription *sub = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (!sub.name || sub.name.length == 0) {
        sub.name = sub.topic;
    }
    cell.textLabel.text = sub.name;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.backgroundColor = sub.UIcolor;
}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath {
    DDLogVerbose(@"SUBs moveRowAtIndexPath %ld > %ld",
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

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.extraButton) {
        self.extraButton =
        [[UIBarButtonItem alloc] initWithTitle:@"Copy"
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(copyEntry)];
        NSMutableArray<UIBarButtonItem *> *a = [self.navigationItem.rightBarButtonItems mutableCopy];
        if (!a) {
            a = [[NSMutableArray alloc] init];
        }
        [a addObject:self.extraButton];
        [self.navigationItem setRightBarButtonItems:a animated:TRUE];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)setupFRC {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Subscription" inManagedObjectContext:self.session.managedObjectContext];
    fetchRequest.entity = entity;
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"belongsTo = %@", self.session];
    
    // Set the batch size to a suitable number.
    fetchRequest.fetchBatchSize = 20;
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor1, sortDescriptor2];
    
    fetchRequest.sortDescriptors = sortDescriptors;
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.session.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle     the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController;
}

@end
