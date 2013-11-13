//
//  Command.m
//  MQTTInspector
//
//  Created by Christoph Krey on 12.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "Command.h"
#import "Session.h"


@implementation Command

@dynamic timestamp;
@dynamic inbound;
@dynamic type;
@dynamic duped;
@dynamic qos;
@dynamic retained;
@dynamic data;
@dynamic belongsTo;

@end
