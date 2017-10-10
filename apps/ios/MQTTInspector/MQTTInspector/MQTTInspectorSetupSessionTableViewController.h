//
//  MQTTInspectorSetupSessionTableViewController.h
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright © 2013-2017 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session+CoreDataClass.h"

@interface MQTTInspectorSetupSessionTableViewController : UITableViewController <UIDocumentInteractionControllerDelegate, UITextFieldDelegate>
@property (strong, nonatomic) Session *session;

@end
