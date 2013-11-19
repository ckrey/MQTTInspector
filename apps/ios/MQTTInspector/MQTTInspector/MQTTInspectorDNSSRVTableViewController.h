//
//  MQTTInspectorDNSSRVTableViewController.h
//  MQTTInspector
//
//  Created by Christoph Krey on 19.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session+Create.h"
#include "SRVResolver.h"

@interface MQTTInspectorDNSSRVTableViewController : UITableViewController <SRVResolverDelegate>
@property (strong, nonatomic) Session *session;
@end
