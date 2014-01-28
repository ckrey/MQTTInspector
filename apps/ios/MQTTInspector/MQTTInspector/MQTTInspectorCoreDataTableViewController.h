//
//  MQTTInspectorCoreDataTableViewController.h
//  MQTTInspector
//
//  Created by Christoph Krey on 27.01.14.
//  Copyright (c) 2014 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MQTTInspectorCoreDataTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) BOOL noupdate;

@end
