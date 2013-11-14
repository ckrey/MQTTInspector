//
//  MQTTInspectorDataViewController.h
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MQTTInspectorDataViewController : UIViewController
@property (strong, nonatomic) NSString *topic;
@property (strong, nonatomic) NSData *data;
@end
