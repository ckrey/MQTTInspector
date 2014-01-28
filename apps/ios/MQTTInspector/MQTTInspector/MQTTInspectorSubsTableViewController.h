//
//  MQTTInspectorSubsTableViewController.h
//  MQTTInspector
//
//  Created by Christoph Krey on 12.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MQTTInspectorDetailViewController.h"
#import "MQTTInspectorCoreDataTableViewController.h"

@interface MQTTInspectorSubsTableViewController : MQTTInspectorCoreDataTableViewController
@property (strong, nonatomic) MQTTInspectorDetailViewController *mother;

@end
