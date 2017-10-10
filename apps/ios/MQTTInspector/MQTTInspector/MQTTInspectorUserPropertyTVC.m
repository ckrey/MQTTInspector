//
//  MQTTInspectorUserPropertyTVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 31.08.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//

#import "MQTTInspectorUserPropertyTVC.h"

@interface MQTTInspectorUserPropertyTVC ()

@end

@implementation MQTTInspectorUserPropertyTVC

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userProperties.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserPropertyCell" forIndexPath:indexPath];
    NSDictionary <NSString *, NSString *> *entry = self.userProperties[indexPath.row];
    NSString *name = entry.allKeys[0];
    cell.textLabel.text = entry[name];
    cell.detailTextLabel.text = name;
    
    return cell;
}

@end
