//
//  MQTTInspectorMessagesTableViewController.h
//  MQTTInspector
//
//  Created by Christoph Krey on 17.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MQTTInspectorDetailViewController.h"

@interface MQTTInspectorMessagesTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) MQTTInspectorDetailViewController *mother;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) BOOL running;

@end
