//
//  Session.m
//  MQTTInspector
//
//  Created by Christoph Krey on 27.01.14.
//  Copyright (c) 2014 Christoph Krey. All rights reserved.
//

#import "Session.h"
#import "Command.h"
#import "Message.h"
#import "Publication.h"
#import "Subscription.h"
#import "Topic.h"


@implementation Session

@dynamic attributefilter;
@dynamic auth;
@dynamic autoconnect;
@dynamic cleansession;
@dynamic clientid;
@dynamic datafilter;
@dynamic dnsdomain;
@dynamic dnssrv;
@dynamic host;
@dynamic keepalive;
@dynamic name;
@dynamic passwd;
@dynamic port;
@dynamic protocolLevel;
@dynamic state;
@dynamic tls;
@dynamic topicfilter;
@dynamic user;
@dynamic includefilter;
@dynamic hasCommands;
@dynamic hasMesssages;
@dynamic hasPubs;
@dynamic hasSubs;
@dynamic hasTopics;

@end
