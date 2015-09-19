//
//  MQTTInspectorSetupSubTableViewController.h
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Subscription+Create.h"

@interface MQTTInspectorSetupSubTableViewController : UITableViewController <UITextFieldDelegate>
@property (strong, nonatomic) Subscription *sub;

@end
