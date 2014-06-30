//
//  MQTTInspectorDNSSRVTableViewController.m
//  MQTTInspector
//
//  Created by Christoph Krey on 19.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "MQTTInspectorDNSSRVTableViewController.h"
#import "MQTTInspectorDetailViewController.h"

@interface MQTTInspectorDNSSRVTableViewController ()
@property (strong, nonatomic) SRVResolver *resolver;
@property (strong, nonatomic) NSMutableArray *resolverResults;

@end

@implementation MQTTInspectorDNSSRVTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.resolverResults = [[NSMutableArray alloc] init];
    [self getService:[self serviceName]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:
            ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ?
            @"DNS SRV for %@" : @"%@", [self serviceName]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.resolverResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dnssrv" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *result = self.resolverResults[indexPath.row];
    self.session.host = result[kSRVResolverTarget];
    self.session.port = result[kSRVResolverPort];
    return indexPath;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *result = self.resolverResults[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@:%@",
                           result[kSRVResolverTarget],
                           result[kSRVResolverPort]];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Priority:%@ Weight:%@",
                                 result[kSRVResolverPriority],
                                 result[kSRVResolverWeight]];
    
}



#pragma mark - dns srv
- (void)getService:(NSString *)srvName
{
    self.resolver = [[SRVResolver alloc] initWithSRVName:srvName];
    self.resolver.delegate = self;
    
    [self.resolver start];
}

- (NSString *)serviceName
{
    return [NSString stringWithFormat:@"%@._tcp.%@",
            [self.session.tls boolValue] ? @"_secure-mqtt" : @"_mqtt",
            self.session.dnsdomain];
}

- (void)srvResolver:(SRVResolver *)resolver didReceiveResult:(NSDictionary *)result
{
#ifdef DEBUG
    NSLog(@"didReceiveResult %@", result);
#endif
    [self.resolverResults addObject:result];
}

- (void)srvResolver:(SRVResolver *)resolver didStopWithError:(NSError *)error
{
#ifdef DEBUG
    NSLog(@"didStopWithError %@", error);
#endif
    [self.tableView reloadData];
    if (error) {
        [MQTTInspectorDetailViewController alert:
         [NSString stringWithFormat:@"DNS SRV Lookup %@", error]];
    }
}


@end
