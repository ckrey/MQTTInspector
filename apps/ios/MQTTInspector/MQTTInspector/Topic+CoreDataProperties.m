//
//  Topic+CoreDataProperties.m
//  MQTTInspector
//
//  Created by Christoph Krey on 10.10.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//
//

#import "Topic+CoreDataProperties.h"

@implementation Topic (CoreDataProperties)

+ (NSFetchRequest<Topic *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Topic"];
}

@dynamic count;
@dynamic data;
@dynamic justupdated;
@dynamic mid;
@dynamic qos;
@dynamic retained;
@dynamic timestamp;
@dynamic topic;
@dynamic payloadFormatIndicator;
@dynamic publicationExpiryInterval;
@dynamic topicAlias;
@dynamic responseTopic;
@dynamic correlationData;
@dynamic userProperties;
@dynamic contentType;
@dynamic subscriptionIdentifiers;
@dynamic belongsTo;

@end
