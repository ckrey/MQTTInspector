//
//  Session.m
//  MQTTInspector
//
//  Created by Christoph Krey on 09.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "Session.h"
#import "Message.h"


@implementation Session

@dynamic host;
@dynamic port;
@dynamic tls;
@dynamic auth;
@dynamic user;
@dynamic passwd;
@dynamic clientid;
@dynamic cleansession;
@dynamic keepalive;
@dynamic hasMesssages;

@end
