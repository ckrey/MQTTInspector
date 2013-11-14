//
//  MQTTInspectorSetupPubTableViewController.h
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Publication+Create.h"

@interface MQTTInspectorSetupPubTableViewController : UITableViewController
@property (strong, nonatomic) Publication *pub;

@end
