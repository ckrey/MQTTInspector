//
//  Message.m
//  MQTTInspector
//
//  Created by Christoph Krey on 18.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "Message.h"
#import "Session.h"


@implementation Message

@dynamic data;
@dynamic state;
@dynamic timestamp;
@dynamic topic;
@dynamic mid;
@dynamic qos;
@dynamic retained;
@dynamic belongsTo;

@end
