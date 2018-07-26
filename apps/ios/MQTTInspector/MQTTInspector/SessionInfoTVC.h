//
//  SessionInfoTVC.h
//  MQTTInspector
//
//  Created by Christoph Krey on 30.08.17.
//  Copyright © 2017-2018 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session+CoreDataClass.h"
#import <mqttc/MQTTClient.h>

@interface SessionInfoTVC : UITableViewController
@property Session *session;
@property MQTTSession *mqttSession;
@end
