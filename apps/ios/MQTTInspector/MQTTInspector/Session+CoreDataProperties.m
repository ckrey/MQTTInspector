//
//  Session+CoreDataProperties.m
//  MQTTInspector
//
//  Created by Christoph Krey on 22.12.15.
//  Copyright © 2015-2016 Christoph Krey. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Session+CoreDataProperties.h"

@implementation Session (CoreDataProperties)

@dynamic allowUntrustedCertificates;
@dynamic attributefilter;
@dynamic auth;
@dynamic autoconnect;
@dynamic cleansession;
@dynamic clientid;
@dynamic datafilter;
@dynamic host;
@dynamic includefilter;
@dynamic keepalive;
@dynamic name;
@dynamic passwd;
@dynamic port;
@dynamic protocolLevel;
@dynamic sizelimit;
@dynamic state;
@dynamic tls;
@dynamic topicfilter;
@dynamic user;
@dynamic websocket;
@dynamic hasCommands;
@dynamic hasMesssages;
@dynamic hasPubs;
@dynamic hasSubs;
@dynamic hasTopics;

@end
