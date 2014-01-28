//
//  MQTTInspectorFilterTVC.h
//  MQTTInspector
//
//  Created by Christoph Krey on 27.01.14.
//  Copyright (c) 2014 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MQTTInspectorDetailViewController.h"

@interface MQTTInspectorFilterTVC : UITableViewController
@property (strong, nonatomic) MQTTInspectorDetailViewController *mother;

@end
