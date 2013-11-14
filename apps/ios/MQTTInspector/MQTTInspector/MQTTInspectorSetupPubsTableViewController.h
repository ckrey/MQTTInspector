//
//  MQTTInspectorSetupPubsTableViewController.h
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session+Create.h"

@interface MQTTInspectorSetupPubsTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) Session *session;
@end
