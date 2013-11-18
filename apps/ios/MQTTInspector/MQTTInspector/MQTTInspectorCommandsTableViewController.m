//
//  MQTTInspectorCommandsTableViewController.m
//  MQTTInspector
//
//  Created by Christoph Krey on 12.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "MQTTInspectorCommandsTableViewController.h"
#import "Command+Create.h"

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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Command" inManagedObjectContext:self.mother.managedObjectContext];
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
    return [NSString stringWithFormat:@"Commands - %@://%@%@:%@",
            [self.mother.session.tls boolValue] ? @"mqtts" : @"mqtt",
            [self.mother.session.auth boolValue] ? [NSString stringWithFormat:@"%@@",
                                                    self.mother.session.user] : @"",
            self.mother.session.host,
            self.mother.session.port];
            
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Command *command = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc]
                                     initWithString:[command attributeTextPart1] attributes:@{}];
    
    UIFont *font = [UIFont boldSystemFontOfSize:16.0];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                                forKey:NSFontAttributeName];
    [as appendAttributedString:[[NSAttributedString alloc]
                                initWithString:[command attributeTextPart1] attributes:attributes]];
    
    
    [as appendAttributedString:[[NSAttributedString alloc]
                                initWithString:[command attributeTextPart3]
                                     attributes:@{}]];
    
    cell.detailTextLabel.attributedText = as;

    cell.textLabel.text = [command dataText];
    
    cell.backgroundColor = [UIColor lightGrayColor];
    
    [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
}

@end
