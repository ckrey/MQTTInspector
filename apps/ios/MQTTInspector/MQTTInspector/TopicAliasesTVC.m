//
//  TopicAliasesTVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 16.10.17.
//  Copyright © 2017-2019 Christoph Krey. All rights reserved.
//

#import "TopicAliasesTVC.h"

@interface TopicAliasesTVC ()

@end

@implementation TopicAliasesTVC

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.topicAliases.count == 0) {
        [self empty];
    } else {
        [self nonempty];
    }
    return self.topicAliases.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"topicAliasCell" forIndexPath:indexPath];
    NSNumber *key = [self.topicAliases.allKeys sortedArrayUsingSelector:@selector(compare:)][indexPath.row];
    cell.textLabel.text = key.stringValue;
    cell.detailTextLabel.text = self.topicAliases[key];
    return cell;
}

@end
