//
//  TopicsTVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 11.11.13.
//  Copyright © 2013-2017 Christoph Krey. All rights reserved.
//

#import "TopicsTVC.h"

#import "Model.h"

#import "DataVC.h"

@interface TopicsTVC ()

@end

@implementation TopicsTVC

- (NSFetchRequest *)fetchRequestForTableView
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Topic"
                                              inManagedObjectContext:self.mother.session.managedObjectContext];
    fetchRequest.entity = entity;
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"belongsTo = %@", self.mother.session];
    
    
    // Set the batch size to a suitable number.
    fetchRequest.fetchBatchSize = 20;
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"topic" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor1];
    
    fetchRequest.sortDescriptors = sortDescriptors;
    
    return fetchRequest;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return [NSString stringWithFormat:@"Topics"];
    } else {
        return nil;
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Topic *topic = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UIFont *fontBold = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    NSDictionary *attributesBold = @{NSFontAttributeName: fontBold};
    
    UIFont *fontLight = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    NSDictionary *attributesLight = @{NSFontAttributeName: fontLight};
    

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
    
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
       if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    }
    
    
    cell.imageView.image = nil;
    cell.imageView.animationImages = nil;
    [cell.imageView stopAnimating];
    
    DDLogVerbose(@"topic %@ is %d", topic.topic, [topic.justupdated boolValue]);
    if (topic.justupdated.boolValue) {
        cell.imageView.image = [UIImage imageNamed:@"new.png"];
        cell.imageView.animationImages = @[[UIImage imageNamed:@"new.png"],
                                           [UIImage imageNamed:@"old.png"]];
        cell.imageView.animationDuration = 1.0;
        [cell.imageView startAnimating];
        [topic performSelector:@selector(setOld) withObject:nil afterDelay:3.0];
    } else  {
        cell.imageView.image = [UIImage imageNamed:@"old.png"];
    }
}

@end
