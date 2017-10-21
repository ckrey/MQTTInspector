//
//  Topic+CoreDataProperties.m
//  MQTTInspector
//
//  Created by Christoph Krey on 21.10.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//
//

#import "Topic+CoreDataProperties.h"

@implementation Topic (CoreDataProperties)

+ (NSFetchRequest<Topic *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Topic"];
}

@dynamic contentType;
@dynamic correlationData;
@dynamic count;
@dynamic data;
@dynamic justupdated;
@dynamic mid;
@dynamic payloadFormatIndicator;
@dynamic messageExpiryInterval;
@dynamic qos;
@dynamic responseTopic;
@dynamic retained;
@dynamic subscriptionIdentifiers;
@dynamic timestamp;
@dynamic topic;
@dynamic topicAlias;
@dynamic userProperties;
@dynamic belongsTo;

@end
