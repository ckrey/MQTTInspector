//
//  MQTTInspectorSessionInfoTVC.h
//  MQTTInspector
//
//  Created by Christoph Krey on 30.08.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session+CoreDataClass.h"
#import <MQTTClient/MQTTClient.h>

@interface MQTTInspectorSessionInfoTVC : UITableViewController
@property Session *session;
@property MQTTSession *mqttSession;
@end
