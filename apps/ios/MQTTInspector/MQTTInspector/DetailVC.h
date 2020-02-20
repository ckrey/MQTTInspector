//
//  DetailVC.h
//  MQTTInspector
//
//  Created by Christoph Krey on 09.11.13.
//  Copyright © 2013-2020 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session+CoreDataClass.h"
#import "Session+CoreDataProperties.h"
#import "Publication+CoreDataClass.h"
#import <mqttc/MQTTClient.h>

@interface DetailVC : UIViewController <MQTTSessionDelegate, UISplitViewControllerDelegate>

@property (strong, nonatomic) Session *session;
@property (strong, nonatomic) MQTTSession *mqttSession;
@property (weak, nonatomic) id selectedObject;

+ (void)alert:(NSString *)message;
- (void)publish:(Publication *)pub;

@end
