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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return [NSString stringWithFormat:@"Topics"];
    } else {
        return nil;
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Topic *topic = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc]
                                     initWithString:[topic attributeTextPart1] attributes:@{}];
    
    UIFont *font = [UIFont boldSystemFontOfSize:16.0];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                                                                forKey:NSFontAttributeName];
    [as appendAttributedString:[[NSAttributedString alloc]
                                initWithString:[topic attributeTextPart2]
                                attributes:attrsDictionary]];
    
    
    [as appendAttributedString:[[NSAttributedString alloc]
                                initWithString:[topic attributeTextPart3]
                                attributes:@{}]];
    
    cell.detailTextLabel.attributedText = as;
    
    cell.textLabel.text = [topic dataText];
    
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
                if (i == [topicComponents count] - 1) {
                    color = [subscription getColor];
                }
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
