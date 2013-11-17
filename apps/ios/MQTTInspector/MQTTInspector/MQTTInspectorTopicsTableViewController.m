//
//  MQTTInspectorTopicsViewController.m
//  MQTTInspector
//
//  Created by Christoph Krey on 11.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "MQTTInspectorTopicsTableViewController.h"
#import "Topic+Create.h"
#import "Subscription+Create.h"
#import "MQTTInspectorDataViewController.h"

@interface MQTTInspectorTopicsTableViewController ()

@end

@implementation MQTTInspectorTopicsTableViewController

- (NSFetchRequest *)fetchRequestForTableView
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Topic" inManagedObjectContext:self.mother.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"belongsTo = %@", self.mother.session];
    
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"topic" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor1];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    return fetchRequest;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Topics"];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Topic *topic = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSMutableAttributedString *as =
    [[NSMutableAttributedString alloc] initWithString:[NSDateFormatter localizedStringFromDate:topic.timestamp
                                                                                     dateStyle:NSDateFormatterShortStyle
                                                                                     timeStyle:NSDateFormatterMediumStyle]
                                           attributes:@{}];
    
    [as appendAttributedString:
     [[NSAttributedString alloc] initWithString:@" :"
                                     attributes:@{}]];
    
    UIFont *font = [UIFont boldSystemFontOfSize:16.0];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                                                                forKey:NSFontAttributeName];
    [as appendAttributedString:
     [[NSAttributedString alloc] initWithString:topic.topic attributes:attrsDictionary]];
    
    
    [as appendAttributedString:
     [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%d) #%@",
                                                 topic.data.length,
                                                 topic.count]
                                     attributes:@{}]];
    /*
     cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ :%@ (%d) #%@",
     [NSDateFormatter localizedStringFromDate:topic.timestamp
     dateStyle:NSDateFormatterShortStyle
     timeStyle:NSDateFormatterMediumStyle],
     topic.topic,
     topic.data.length,
     topic.count];
     */
    
    cell.detailTextLabel.attributedText = as;
    
    cell.textLabel.text = [MQTTInspectorDataViewController dataToString:topic.data];
    
    cell.backgroundColor = [self matchingSubscriptionColor:topic];
    
    [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
}

- (UIColor *)matchingSubscriptionColor:(Topic *)topic
{
    UIColor *color = [UIColor whiteColor];
    
    for (Subscription *subscription in topic.belongsTo.hasSubs) {
        NSArray *subscriptionComponents = [subscription.topic pathComponents];
        NSArray *topicComponents = [topic.topic pathComponents];
        for (int i = 0; i < [topicComponents count]; i++) {
            if ([subscriptionComponents[i] isEqualToString:@"#"]) {
                color = [subscription getColor];
                break;
            }
            if ([subscriptionComponents[i] isEqualToString:@"+"]) {
                continue;
            }
            if (![subscriptionComponents[i] isEqualToString:topicComponents[i]]) {
                break;
            } else {
                if (i == [topicComponents count] - 1) {
                    color = [subscription getColor];
                }
            }
        }
    }
    return color;
}


@end
