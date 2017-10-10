//
//  Message+CoreDataProperties.m
//  MQTTInspector
//
//  Created by Christoph Krey on 10.10.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//
//

#import "Message+CoreDataProperties.h"

@implementation Message (CoreDataProperties)

+ (NSFetchRequest<Message *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Message"];
}

@dynamic data;
@dynamic mid;
@dynamic qos;
@dynamic retained;
@dynamic state;
@dynamic timestamp;
@dynamic topic;
@dynamic payloadFormatIndicator;
@dynamic publicationExpiryInterval;
@dynamic topicAlias;
@dynamic subscriptionIdentifiers;
@dynamic userProperties;
@dynamic responstTopic;
@dynamic correlationData;
@dynamic contentType;
@dynamic belongsTo;

@end
