//
//  MQTTInspectorCoreDataTableViewController.h
//  MQTTInspector
//
//  Created by Christoph Krey on 27.01.14.
//  Copyright © 2014-2016 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface MQTTInspectorCoreDataTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) BOOL noupdate;

@end
