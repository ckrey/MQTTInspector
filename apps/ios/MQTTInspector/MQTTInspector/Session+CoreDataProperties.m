//
//  Session+CoreDataProperties.m
//  MQTTInspector
//
//  Created by Christoph Krey on 15.10.17.
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
@dynamic authData;
@dynamic authMethod;
@dynamic autoconnect;
@dynamic cleansession;
@dynamic clientid;
@dynamic datafilter;
@dynamic host;
@dynamic includefilter;
@dynamic keepalive;
@dynamic maximumPacketSize;
@dynamic name;
@dynamic passwd;
@dynamic port;
@dynamic protocolLevel;
@dynamic receiveMaximum;
@dynamic requestProblemInformation;
@dynamic requestResponseInformatino;
@dynamic sessionExpiryInterval;
@dynamic sizelimit;
@dynamic state;
@dynamic tls;
@dynamic topicAliasMaximum;
@dynamic topicfilter;
@dynamic user;
@dynamic userProperties;
@dynamic websocket;
@dynamic willDelay;
@dynamic hasCommands;
@dynamic hasMesssages;
@dynamic hasPubs;
@dynamic hasSubs;
@dynamic hasTopics;

@end
