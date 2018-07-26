//
//  LogsTVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 11.11.13.
//  Copyright © 2013-2018 Christoph Krey. All rights reserved.
//

#import "LogsTVC.h"

#import "Model.h"

#import "DataVC.h"

@interface LogsTVC ()

@end

@implementation LogsTVC

- (NSFetchRequest *)fetchRequestForTableView
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message"
                                              inManagedObjectContext:self.mother.session.managedObjectContext];
    fetchRequest.entity = entity;
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"belongsTo = %@", self.mother.session];
    
    
    // Set the batch size to a suitable number.
    fetchRequest.fetchBatchSize = 20;
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor1];
    
    fetchRequest.sortDescriptors = sortDescriptors;

    return fetchRequest;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return [NSString stringWithFormat:@"Messages"];
    } else {
        return nil;
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UIFont *fontBold = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    NSDictionary *attributesBold = @{NSFontAttributeName: fontBold};
    
    UIFont *fontLight = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    NSDictionary *attributesLight = @{NSFontAttributeName: fontLight};

    
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
    
    cell.accessoryType = UITableViewCellAccessoryDetailButton;

    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    }
    
    cell.imageView.image = nil;
    cell.imageView.animationImages = nil;
    [cell.imageView stopAnimating];

}
                        
@end
