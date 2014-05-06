//
//  Message.m
//  MQTTInspector
//
//  Created by Christoph Krey on 05.05.14.
//  Copyright (c) 2014 Christoph Krey. All rights reserved.
//

#import "Message.h"
#import "Session.h"


@implementation Message

@dynamic data;
@dynamic mid;
@dynamic qos;
@dynamic retained;
@dynamic state;
@dynamic timestamp;
@dynamic topic;
@dynamic belongsTo;

@end
