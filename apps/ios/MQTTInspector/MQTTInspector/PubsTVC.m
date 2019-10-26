//
//  PubsTVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright © 2013-2018 Christoph Krey. All rights reserved.
//

#import "PubsTVC.h"
#import "PubTVC.h"

#import "Model.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

@interface PubsTVC ()
@end

@implementation PubsTVC
static const DDLogLevel ddLogLevel = DDLogLevelError;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"setPub:"]) {
        
        NSIndexPath *indexPath = nil;
        
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            indexPath = [self.tableView indexPathForCell:sender];
        }
        
        if (indexPath) {
            Publication *pub = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if ([segue.destinationViewController respondsToSelector:@selector(setPub:)]) {
                [segue.destinationViewController performSelector:@selector(setPub:)
                                                      withObject:pub];
            }
        }
    }

    if ([segue.identifier isEqualToString:@"newPub"]) {
        int i = 1;
        NSString *newName;
        
        do {
            newName = [NSString stringWithFormat:@"new-pub-%d", i++];
        } while ([Publication existsPublicationWithName:newName
                                       session:self.session
                        inManagedObjectContext:self.session.managedObjectContext]);
        
        Publication *pub = [Publication publicationWithName:newName
                                                      topic:@"topic"
                                                        qos:0
                                                   retained:NO
                                                       data:[@"data" dataUsingEncoding:NSUTF8StringEncoding]
                                               session:self.session
                             inManagedObjectContext:self.session.managedObjectContext];
        if ([segue.destinationViewController respondsToSelector:@selector(setPub:)]) {
            [segue.destinationViewController performSelector:@selector(setPub:)
                                                  withObject:pub];
        }
    }
}

- (IBAction)toggleEdit:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.editing = !self.editing;
    }
}

#pragma mark - Table View

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pub" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Publication *pub = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = pub.name;
    cell.textLabel.textColor = [UIColor blackColor];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    DDLogVerbose(@"PUBs moveRowAtIndexPath %ld > %ld",
                 (long)sourceIndexPath.row, (long)destinationIndexPath.row);
    self.noupdate = TRUE;
    for (NSUInteger i = 0; i < MIN(destinationIndexPath.row, sourceIndexPath.row); i++) {
        Publication *pub = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (!pub.position || (pub.position).unsignedIntegerValue != i) {
            pub.position = @(i);
        }
    }

    if (sourceIndexPath.row < destinationIndexPath.row) {
        for (NSUInteger i = sourceIndexPath.row; i < destinationIndexPath.row; i++) {
            Publication *pub = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:i + 1 inSection:0]];
            pub.position = @(i);
        }
    } else if (sourceIndexPath.row > destinationIndexPath.row) {
        for (NSUInteger i = sourceIndexPath.row; i > destinationIndexPath.row; i--) {
            Publication *pub = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:i - 1 inSection:0]];
            pub.position = @(i);
        }
    }
    Publication *pub = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:sourceIndexPath.row inSection:0]];
    pub.position = @(destinationIndexPath.row);
    
    id <NSFetchedResultsSectionInfo> sectionInfo = (self.fetchedResultsController).sections[0];
    for (NSUInteger i = MAX(destinationIndexPath.row, sourceIndexPath.row) + 1; i < sectionInfo.numberOfObjects; i++) {
        Publication *pub = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (!pub.position || (pub.position).unsignedIntegerValue != i) {
            pub.position = @(i);
        }
    }
    self.noupdate = FALSE;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)setupFRC {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Publication" inManagedObjectContext:self.session.managedObjectContext];
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
