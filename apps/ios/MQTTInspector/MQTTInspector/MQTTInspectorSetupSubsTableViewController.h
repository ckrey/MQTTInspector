//
//  MQTTInspectorSetupSubsTableViewController.h
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session+Create.h"
#import "MQTTInspectorCoreDataTableViewController.h"

@interface MQTTInspectorSetupSubsTableViewController : MQTTInspectorCoreDataTableViewController
@property (strong, nonatomic) Session *session;

@end
