//
//  MQTTInspectorDataViewController.h
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Topic+Create.h"
#import "Message+Create.h"
#import "Command+Create.h"

@interface MQTTInspectorDataViewController : UIViewController
+ (NSString *)dataToString:(NSData *)data;

@property (strong, nonatomic) id object;
@end
