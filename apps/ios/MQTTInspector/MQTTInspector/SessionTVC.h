//
//  SessionTVC.h
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright © 2013-2019 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session+CoreDataClass.h"

@interface SessionTVC : UITableViewController <UIDocumentInteractionControllerDelegate, UITextFieldDelegate>
@property (strong, nonatomic) Session *session;

@end
