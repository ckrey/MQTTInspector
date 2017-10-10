//
//  MQTTInspectorPubsTableViewController.h
//  MQTTInspector
//
//  Created by Christoph Krey on 12.11.13.
//  Copyright © 2013-2017 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MQTTInspectorDetailViewController.h"
#import "MQTTInspectorCoreDataTableViewController.h"

@interface MQTTInspectorPubsTableViewController : MQTTInspectorCoreDataTableViewController
@property (strong, nonatomic) MQTTInspectorDetailViewController *mother;

@end
