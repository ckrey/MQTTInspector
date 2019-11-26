//
//  AnyTVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 25.11.19.
//  Copyright © 2019 Christoph Krey. All rights reserved.
//

#import "AnyTVC.h"

@interface AnyTVC ()
@property (strong, nonatomic) UILabel *emptyLabel;
@property (strong, nonatomic) NSArray <NSLayoutConstraint *> *constraints;

@end

@implementation AnyTVC

- (void)empty {
    self.emptyLabel = [[UILabel alloc] init];
    self.emptyLabel.translatesAutoresizingMaskIntoConstraints = false;
    if (self.emptyText) {
        self.emptyLabel.text = self.emptyText;
    } else {
        self.emptyLabel.text = NSLocalizedString(@"Table is empty",
                                                 @"Table is empty");
    }
    self.tableView.backgroundView = self.emptyLabel;
    NSLayoutConstraint *center = [NSLayoutConstraint
                                  constraintWithItem:self.emptyLabel
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:self.tableView
                                  attribute:NSLayoutAttributeCenterX
                                  multiplier:1
                                  constant:0];
    NSLayoutConstraint *middle = [NSLayoutConstraint
                                  constraintWithItem:self.emptyLabel
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:self.tableView
                                  attribute:NSLayoutAttributeCenterY
                                  multiplier:1
                                  constant:0];
    self.constraints = @[center, middle];
    [NSLayoutConstraint activateConstraints:self.constraints];
}

- (void)nonempty {
    if (self.constraints) {
        [NSLayoutConstraint deactivateConstraints:self.constraints];
        self.constraints = nil;
    }
    self.emptyLabel = nil;
    self.tableView.backgroundView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
