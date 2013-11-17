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
    
    const NSArray *commandNames = @[
                                    @"Reserved0",
                                    @"CONNECT",
                                    @"CONNACK",
                                    @"PUBLISH",
                                    @"PUBACK",
                                    @"PUBREC",
                                    @"PUBREL",
                                    @"PUBCOMP",
                                    @"SUBSCRIBE",
                                    @"SUBACK",
                                    @"UNSUBSCRIBE",
                                    @"UNSUBACK",
                                    @"PINGREQ",
                                    @"PINGRESP",
                                    @"DISCONNECT",
                                    @"Reserved15"
                                    ];
    
    NSMutableAttributedString *as =
    [[NSMutableAttributedString alloc] initWithString:[NSDateFormatter localizedStringFromDate:command.timestamp
                                                                                     dateStyle:NSDateFormatterShortStyle
                                                                                     timeStyle:NSDateFormatterMediumStyle]
                                           attributes:@{}];
    
    [as appendAttributedString:
     [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ :",
                                                 [command.inbound boolValue] ? @">" : @"<"]
                                     attributes:@{}]];
    
    UIFont *font = [UIFont boldSystemFontOfSize:16.0];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                                                                forKey:NSFontAttributeName];
    [as appendAttributedString:
     [[NSAttributedString alloc] initWithString:commandNames[[command.type intValue]] attributes:attrsDictionary]];
    
    
    [as appendAttributedString:
     [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" d%@ q%@ r%@ i%d",
                                                 command.duped,
                                                 command.qos,
                                                 command.retained,
                                                 -1]
                                     attributes:@{}]];
    cell.detailTextLabel.attributedText = as;

    cell.textLabel.text = [NSString stringWithFormat:@"(%d) %@",
                                 command.data.length,
                                 [command.data description]];
    cell.backgroundColor = [UIColor lightGrayColor];
    
    [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
}

@end
