//
//  MQTTInspectorAdHocPubTableViewController.h
//  MQTTInspector
//
//  Created by Christoph Krey on 15.11.13.
//  Copyright © 2013-2017 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MQTTInspectorDetailViewController.h"

@interface MQTTInspectorAdHocPubTableViewController : UITableViewController <UITextFieldDelegate>
@property (strong, nonatomic) MQTTInspectorDetailViewController *mother;
@end
