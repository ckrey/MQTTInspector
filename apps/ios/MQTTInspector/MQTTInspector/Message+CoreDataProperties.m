//
//  Message+CoreDataProperties.m
//  MQTTInspector
//
//  Created by Christoph Krey on 21.10.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//
//

#import "Message+CoreDataProperties.h"

@implementation Message (CoreDataProperties)

+ (NSFetchRequest<Message *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Message"];
}

@dynamic contentType;
@dynamic correlationData;
@dynamic data;
@dynamic mid;
@dynamic payloadFormatIndicator;
@dynamic messageExpiryInterval;
@dynamic qos;
@dynamic responstTopic;
@dynamic retained;
@dynamic state;
@dynamic subscriptionIdentifiers;
@dynamic timestamp;
@dynamic topic;
@dynamic topicAlias;
@dynamic userProperties;
@dynamic belongsTo;

@end
