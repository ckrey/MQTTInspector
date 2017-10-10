//
//  Session+CoreDataProperties.m
//  MQTTInspector
//
//  Created by Christoph Krey on 09.10.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//
//

#import "Session+CoreDataProperties.h"

@implementation Session (CoreDataProperties)

+ (NSFetchRequest<Session *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Session"];
}

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
@dynamic sessionExpiryInterval;
@dynamic receiveMaximum;
@dynamic maximumPacketSize;
@dynamic willDelay;
@dynamic topicAliasMaximum;
@dynamic requestProblemInformation;
@dynamic requestReplyInfo;
@dynamic userProperties;
@dynamic authMethod;
@dynamic authData;
@dynamic hasCommands;
@dynamic hasMesssages;
@dynamic hasPubs;
@dynamic hasSubs;
@dynamic hasTopics;

@end
