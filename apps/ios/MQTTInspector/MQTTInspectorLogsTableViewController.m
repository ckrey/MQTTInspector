//
//  MQTTInspectorLogsTableViewController.m
//  MQTTInspector
//
//  Created by Christoph Krey on 11.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "MQTTInspectorLogsTableViewController.h"
#import "Message+Create.h"
#import "Subscription+Create.h"
#import "MQTTInspectorDataViewController.h"

@interface MQTTInspectorLogsTableViewController ()

@end

@implementation MQTTInspectorLogsTableViewController

- (NSFetchRequest *)fetchRequestForTableView
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:self.mother.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"belongsTo = %@", self.mother.session];
    
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor1];
    
    [fetchRequest setSortDescriptors:sortDescriptors];

    return fetchRequest;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return [NSString stringWithFormat:@"Messages"];
    } else {
        return nil;
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UIFont *fontBold = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    NSDictionary *attributesBold = [NSDictionary dictionaryWithObject:fontBold
                                                                forKey:NSFontAttributeName];
    
    UIFont *fontLight = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    NSDictionary *attributesLight = [NSDictionary dictionaryWithObject:fontLight
                                                               forKey:NSFontAttributeName];

    
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc]
                                     initWithString:[message attributeTextPart1]
                                     attributes:attributesLight];
    
    [as appendAttributedString:[[NSAttributedString alloc]
                                initWithString:[message attributeTextPart2]
                                attributes:attributesBold]];
    
    [as appendAttributedString:[[NSAttributedString alloc]
                                initWithString:[message attributeTextPart3]
                                attributes:attributesLight]];
    
    cell.detailTextLabel.attributedText = as;
    
    cell.textLabel.text = [message dataText];
    
    cell.backgroundColor = [self matchingSubscriptionColor:message];
    
    [cell setAccessoryType:UITableViewCellAccessoryDetailButton];

    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    }

}

- (UIColor *)matchingSubscriptionColor:(Message *)message
{
    UIColor *color = [UIColor whiteColor];
    
    for (Subscription *subscription in message.belongsTo.hasSubs) {
        NSArray *subscriptionComponents = [subscription.topic pathComponents];
        NSArray *messageComponents = [message.topic pathComponents];
        for (int i = 0; i < [messageComponents count]; i++) {
            if ([subscriptionComponents[i] isEqualToString:@"#"]) {
                color = [subscription getColor];
                break;
            }
            if ([subscriptionComponents[i] isEqualToString:@"+"]) {
                if (i == [messageComponents count] - 1) {
                    color = [subscription getColor];
                }
                continue;
            }
            if (![subscriptionComponents[i] isEqualToString:messageComponents[i]]) {
                break;
            } else {
                if (i == [messageComponents count] - 1) {
                    color = [subscription getColor];
                }
            }
        }
    }
    return color;
}
                        
@end
