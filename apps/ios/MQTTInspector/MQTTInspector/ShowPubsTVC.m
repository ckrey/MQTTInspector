//
//  ShowPubsTVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 12.11.13.
//  Copyright © 2013-2019 Christoph Krey. All rights reserved.
//

#import "ShowPubsTVC.h"

#import "Model.h"

#import "DataVC.h"
#import "DetailVC.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

@interface ShowPubsTVC ()
@end

@implementation ShowPubsTVC
static const DDLogLevel ddLogLevel = DDLogLevelError;

- (void)setTableView:(UITableView *)tableView {
    super.tableView = tableView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)setupFRC {
    NSFetchedResultsController *aFetchedResultsController;
    if (self.mother.session) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Publication"
                                                  inManagedObjectContext:self.mother.session.managedObjectContext];
        fetchRequest.entity = entity;
        
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"belongsTo = %@", self.mother.session];
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20;
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
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

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return [NSString stringWithFormat:@"PUBs"];
    } else {
        return nil;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"publication" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath {
    Publication *publication = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = publication.name;
    
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        cell.textLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    }
    
}

- (BOOL)tableView:(UITableView *)tableView
canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath {
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

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Publication *publication = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (self.mother.mqttSession.status == MQTTSessionStatusConnected) {
        [self.mother publish:publication];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
