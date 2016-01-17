//
//  MQTTInspectorSetupPubTableViewController.h
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright © 2013-2016 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Publication.h"

@interface MQTTInspectorSetupPubTableViewController : UITableViewController <UITextFieldDelegate>
@property (strong, nonatomic) Publication *pub;

@end
