//
//  MQTTInspectorAdHocPubTableViewController.h
//  MQTTInspector
//
//  Created by Christoph Krey on 15.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session+Create.h"
#import "MQTTInspectorDetailViewController.h"

@interface MQTTInspectorAdHocPubTableViewController : UITableViewController
@property (strong, nonatomic) MQTTInspectorDetailViewController *mother;
@end
