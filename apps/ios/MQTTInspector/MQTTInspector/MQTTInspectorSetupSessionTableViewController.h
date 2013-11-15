//
//  MQTTInspectorSetupSessionTableViewController.h
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session+Create.h"
#include "SRVResolver.h"

@interface MQTTInspectorSetupSessionTableViewController : UITableViewController <SRVResolverDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) Session *session;

@end
