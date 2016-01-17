//
//  MQTTInspectorCommandsTableViewController.m
//  MQTTInspector
//
//  Created by Christoph Krey on 12.11.13.
//  Copyright © 2013-2016 Christoph Krey. All rights reserved.
//

#import "MQTTInspectorCommandsTableViewController.h"

#import "Model.h"

@interface MQTTInspectorCommandsTableViewController ()

@end

@implementation MQTTInspectorCommandsTableViewController

- (void)setTableView:(UITableView *)tableView
{
    [super setTableView:tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
}

- (NSFetchRequest *)fetchRequestForTableView
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Command"
                                              inManagedObjectContext:self.mother.session.managedObjectContext];
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
        return [NSString stringWithFormat:@"Commands"];
    } else {
        return nil;
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Command *command = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UIFont *fontBold = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    NSDictionary *attributesBold = @{NSFontAttributeName: fontBold};
    
    UIFont *fontLight = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    NSDictionary *attributesLight = @{NSFontAttributeName: fontLight};
    
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc]
                                     initWithString:[command attributeTextPart1] attributes:attributesLight];
    
    [as appendAttributedString:[[NSAttributedString alloc]
                                initWithString:[command attributeTextPart2] attributes:attributesBold]];

    
    [as appendAttributedString:[[NSAttributedString alloc]
                                initWithString:[command attributeTextPart3]
                                     attributes:attributesLight]];
    
    cell.detailTextLabel.attributedText = as;

    cell.textLabel.text = [command dataText];
    
    if ([command.inbound boolValue]) {
        cell.backgroundColor = [UIColor colorWithHue:.666 saturation:0.333 brightness:1.0 alpha:1.0];
    } else {
        cell.backgroundColor = [UIColor colorWithHue:.333 saturation:0.333 brightness:1.0 alpha:1.0];
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
    
    [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    }

    cell.imageView.image = nil;
    cell.imageView.animationImages = nil;
    [cell.imageView stopAnimating];
}

@end
