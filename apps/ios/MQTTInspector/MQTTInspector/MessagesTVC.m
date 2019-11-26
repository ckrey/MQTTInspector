//
//  MessagesTVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 17.11.13.
//  Copyright © 2013-2018 Christoph Krey. All rights reserved.
//

#import "MessagesTVC.h"

#import "Model.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

@interface MessagesTVC ()
@end

@implementation MessagesTVC
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.messagesType = MessagesTopics;
        self.fetchedResultsController = nil;
    }
    return self;
}

- (void)setTableView:(UITableView *)tableView
{
    [super setTableView:tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
}

- (void)setMessagesType:(MessagesType)messagesType {
    self.fetchedResultsController = nil;
    _messagesType = messagesType;
    [self.tableView reloadData];
}

#pragma mark - Fetched results controller

- (NSFetchRequest *)fetchRequestForTableView {
    NSFetchRequest *fetchRequest;
    if (!self.mother.session) {
        return nil;
    }

    switch (self.messagesType) {
        case MessagesCommands:
            fetchRequest = [[NSFetchRequest alloc] init];
            fetchRequest.entity = [NSEntityDescription entityForName:@"Command"
                                              inManagedObjectContext:self.mother.session.managedObjectContext];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"belongsTo = %@", self.mother.session];
            fetchRequest.fetchBatchSize = 20;
            fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO]];
            break;
        case MessagesLogs:
            fetchRequest = [[NSFetchRequest alloc] init];
            fetchRequest.entity = [NSEntityDescription entityForName:@"Message"
                                                      inManagedObjectContext:self.mother.session.managedObjectContext];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"belongsTo = %@", self.mother.session];
            fetchRequest.fetchBatchSize = 20;
            fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO]];
            break;
        case MessagesTopics:
        default:
            fetchRequest = [[NSFetchRequest alloc] init];
            fetchRequest.entity = [NSEntityDescription entityForName:@"Topic"
                                              inManagedObjectContext:self.mother.session.managedObjectContext];;
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"belongsTo = %@", self.mother.session];
            fetchRequest.fetchBatchSize = 20;
            fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"topic" ascending:YES]];
            break;
    }

    return fetchRequest;
}

- (NSFetchedResultsController *)setupFRC {
    if (!self.mother.session) {
        return nil;
    }

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequestForTableView
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
    
    return aFetchedResultsController;
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

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"message" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = (self.fetchedResultsController).managedObjectContext;
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.mother.selectedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.mother.selectedObject = nil;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    UIFont *fontBold = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    NSDictionary *attributesBold = @{NSFontAttributeName: fontBold};

    UIFont *fontLight = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    NSDictionary *attributesLight = @{NSFontAttributeName: fontLight};

    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    }

    cell.imageView.image = nil;
    cell.imageView.animationImages = nil;
    [cell.imageView stopAnimating];

    cell.accessoryType = UITableViewCellAccessoryDetailButton;

    switch (self.messagesType) {
        case MessagesCommands:
        {
            Command *command = [self.fetchedResultsController objectAtIndexPath:indexPath];

            NSMutableAttributedString *as = [[NSMutableAttributedString alloc]
                                             initWithString:command.attributeTextPart1 attributes:attributesLight];

            [as appendAttributedString:[[NSAttributedString alloc]
                                        initWithString:command.attributeTextPart2 attributes:attributesBold]];


            [as appendAttributedString:[[NSAttributedString alloc]
                                        initWithString:command.attributeTextPart3
                                             attributes:attributesLight]];

            cell.detailTextLabel.attributedText = as;
            cell.textLabel.text = command.dataText;
            if ((command.inbound).boolValue) {
                cell.backgroundColor = [UIColor colorWithHue:.666 saturation:0.333 brightness:1.0 alpha:1.0];
            } else {
                cell.backgroundColor = [UIColor colorWithHue:.333 saturation:0.333 brightness:1.0 alpha:1.0];
            }
            break;
        }
        case MessagesLogs:
        {
            Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];

            NSMutableAttributedString *as = [[NSMutableAttributedString alloc]
                                             initWithString:message.attributeTextPart1
                                             attributes:attributesLight];

            [as appendAttributedString:[[NSAttributedString alloc]
                                        initWithString:message.attributeTextPart2
                                        attributes:attributesBold]];

            [as appendAttributedString:[[NSAttributedString alloc]
                                        initWithString:message.attributeTextPart3
                                        attributes:attributesLight]];

            cell.detailTextLabel.attributedText = as;
            cell.textLabel.text = message.dataText;
            cell.backgroundColor = [self matchingTopicColor:message.topic inSession:self.mother.session];
            break;
        }
        case MessagesTopics:
        default:
        {
            Topic *topic = [self.fetchedResultsController objectAtIndexPath:indexPath];

            NSMutableAttributedString *as = [[NSMutableAttributedString alloc]
                                             initWithString:topic.attributeTextPart1 attributes:attributesLight];

            [as appendAttributedString:[[NSAttributedString alloc]
                                        initWithString:topic.attributeTextPart2
                                        attributes:attributesBold]];


            [as appendAttributedString:[[NSAttributedString alloc]
                                        initWithString:topic.attributeTextPart3
                                        attributes:attributesLight]];

            cell.detailTextLabel.attributedText = as;
            cell.textLabel.text = topic.dataText;
            cell.backgroundColor = [self matchingTopicColor:topic.topic inSession:self.mother.session];

            DDLogVerbose(@"topic %@ is %d", topic.topic, [topic.justupdated boolValue]);
            cell.imageView.image = [UIImage imageNamed:@"old.png"];

            if (topic.justupdated.boolValue) {
                if ([topic.timestamp timeIntervalSinceNow] > -1.0) {
                    cell.imageView.animationImages = @[[UIImage imageNamed:@"new.png"],
                                                       [UIImage imageNamed:@"old.png"]];
                    cell.imageView.animationDuration = 1.0;
                    cell.imageView.animationRepeatCount = 1;
                    [cell.imageView startAnimating];
                }
            }
            break;
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        switch (self.messagesType) {
            case MessagesCommands:
                return [NSString stringWithFormat:@"Commands"];
            case MessagesLogs:
                return [NSString stringWithFormat:@"Messages"];
            case MessagesTopics:
            default:
                return [NSString stringWithFormat:@"Topics"];
        }
    } else {
        return nil;
    }
}

- (UIColor *)matchingTopicColor:(NSString *)topic inSession:(Session *)session {
    UIColor *color = [UIColor whiteColor];
    int best = -1;
    
    for (Subscription *subscription in [session.hasSubs
                                        sortedArrayUsingDescriptors:@[
                                            [NSSortDescriptor sortDescriptorWithKey:@"position"
                                                                          ascending:YES]
                                        ]
                                        ]) {
        int points = [self pointsTopic:topic matchingSub:subscription.topic];
        if (points > best) {
            color = subscription.UIcolor;
            best = points;
        }
    }
    return color;
}

- (int)pointsTopic:(NSString *)topic matchingSub:(NSString *)subscription {
    int points = -1;
    
    NSArray *topicComponents = topic.pathComponents;
    NSArray *subscriptionComponents = subscription.pathComponents;
    
    int i;
    int match = 0;
    
    for (i = 0; (i < topicComponents.count) && (i < subscriptionComponents.count); i++) {
        if ([subscriptionComponents[i] isEqualToString:topicComponents[i]]) {
            if ((i == subscriptionComponents.count - 1) && (i == topicComponents.count - 1)) {
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
        if (((i == subscriptionComponents.count - 1) && ([subscriptionComponents[i] isEqualToString:@"#"])) ||
            ((match > 1) && (i == subscriptionComponents.count) && (i == topicComponents.count))) {
            points = i * 10 + match;
        }
    }
    DDLogInfo(@"topic %@(%lu) matches %@(%lu) specific:%d match:%d",
              topic, (unsigned long)[topicComponents count],
              subscription, (unsigned long)[subscriptionComponents count],
              i, match);
    return points;
}

@end
