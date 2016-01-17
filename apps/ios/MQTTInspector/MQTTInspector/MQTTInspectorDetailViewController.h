//
//  MQTTInspectorDetailViewController.h
//  MQTTInspector
//
//  Created by Christoph Krey on 09.11.13.
//  Copyright © 2013-2016 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session.h"
#import "Session+CoreDataProperties.h"
#import "Publication.h"
#import <MQTTClient/MQTTClient.h>

@interface MQTTInspectorDetailViewController : UIViewController <MQTTSessionDelegate>

@property (strong, nonatomic) Session *session;
@property (strong, nonatomic) MQTTSession *mqttSession;

+ (void)alert:(NSString *)message;
- (void)publish:(Publication *)pub;

@end
