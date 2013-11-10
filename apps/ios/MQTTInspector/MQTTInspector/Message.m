//
//  Message.m
//  MQTTInspector
//
//  Created by Christoph Krey on 09.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "Message.h"


@implementation Message

@dynamic timestamp;
@dynamic outbound;
@dynamic type;
@dynamic dup;
@dynamic qos;
@dynamic retained;
@dynamic length;
@dynamic data;
@dynamic belongsTo;

@end
