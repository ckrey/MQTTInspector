//
//  MQTTInspectorMessagesTableViewController.h
//  MQTTInspector
//
//  Created by Christoph Krey on 17.11.13.
//  Copyright © 2013-2017 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MQTTInspectorDetailViewController.h"
#import "Session+CoreDataClass.h"

@interface MQTTInspectorMessagesTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) MQTTInspectorDetailViewController *mother;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (UIColor *)matchingTopicColor:(NSString *)topic inSession:(Session *)session;

@end
