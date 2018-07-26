//
//  MQTTInspectorUserPropertyTVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 31.08.17.
//  Copyright © 2017-2018 Christoph Krey. All rights reserved.
//

#import "UserPropertiesTVC.h"
#import "UserPropertyTVC.h"

@interface UserPropertiesTVC ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@end

@implementation UserPropertiesTVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.saveButton.enabled = self.edit.boolValue;
    self.addButton.enabled = self.edit.boolValue;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *tvc = (UITableViewCell *)sender;
        NSIndexPath *iP = [self.tableView indexPathForCell:tvc];
        if ([segue.destinationViewController respondsToSelector:@selector(setKeyValue:)]) {
            [segue.destinationViewController performSelector:@selector(setKeyValue:)
                                                  withObject:[self.userProperties[iP.row] mutableCopy]];
        }
        if ([segue.destinationViewController respondsToSelector:@selector(setPosition:)]) {
            [segue.destinationViewController performSelector:@selector(setPosition:)
                                                  withObject:@(iP.row)];
        }
    }
}

- (IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    NSDictionary <NSString *, NSString *> *keyValue;
    NSNumber *position;
    if ([segue.sourceViewController respondsToSelector:@selector(keyValue)]) {
        keyValue = [segue.sourceViewController performSelector:@selector(keyValue)
                                                    withObject:nil];
    }
    if ([segue.sourceViewController respondsToSelector:@selector(position)]) {
        position = [segue.sourceViewController performSelector:@selector(position)
                                                    withObject:nil];
    }

    if (keyValue && position) {
        NSMutableArray <NSDictionary <NSString *, NSString *> *> *m;
        if (self.userProperties) {
            m = self.userProperties.mutableCopy;
        } else {
            m = [[NSMutableArray alloc] init];
        }
        m[position.intValue] = keyValue;
        self.userProperties = m;
    }
    [self.tableView reloadData];
}


- (IBAction)addPressed:(UIBarButtonItem *)sender {
    NSMutableArray <NSDictionary <NSString *, NSString *> *> *m;

    if (self.userProperties) {
        m = self.userProperties.mutableCopy;
    } else {
        m = [[NSMutableArray alloc] init];
    }

    NSInteger size = self.userProperties.count + 1;
    NSString *nextKey = [NSString stringWithFormat:@"key%ld", (long)size];
    NSString *nextValue = [NSString stringWithFormat:@"value%ld", (long)size];

    [m addObject:[NSDictionary dictionaryWithObject:nextValue forKey:nextKey]];
    self.userProperties = m;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userProperties.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.edit.boolValue;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return false;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserPropertyCell" forIndexPath:indexPath];
    NSDictionary <NSString *, NSString *> *entry = self.userProperties[indexPath.row];
    NSString *name = entry.allKeys[0];
    cell.textLabel.text = entry[name];
    cell.detailTextLabel.text = name;
    cell.accessoryType = self.edit.boolValue ? UITableViewCellAccessoryDetailDisclosureButton : UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    NSMutableArray <NSDictionary <NSString *, NSString *> *> *m;
    if (self.userProperties) {
        m = self.userProperties.mutableCopy;
    } else {
        m = [[NSMutableArray alloc] init];
    }

    [m removeObjectAtIndex:indexPath.row];
    self.userProperties = m;
    [self.tableView reloadData];
}

@end
