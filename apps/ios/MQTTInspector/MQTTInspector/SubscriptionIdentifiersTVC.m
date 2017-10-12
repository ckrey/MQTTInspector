//
//  SubscriptionIdentifiersTVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 12.10.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//

#import "SubscriptionIdentifiersTVC.h"

@interface SubscriptionIdentifiersTVC ()
@property (strong, nonatomic) NSArray <NSNumber *> *subscriptionIdentifiersArray;

@end

@implementation SubscriptionIdentifiersTVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.subscriptionIdentifiersArray) {
        self.subscriptionIdentifiersArray = [NSJSONSerialization JSONObjectWithData:self.subscriptionIdentifiers
                                                                            options:0
                                                                              error:nil];
    } else {
        self.subscriptionIdentifiersArray = [[NSArray alloc] init];
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.subscriptionIdentifiersArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"subscriptionIdentifier" forIndexPath:indexPath];
    
    cell.textLabel.text = self.subscriptionIdentifiersArray[indexPath.row].stringValue;
    
    return cell;
}

@end
