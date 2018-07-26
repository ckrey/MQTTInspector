//
//  Publication+CoreDataProperties.m
//  MQTTInspector
//
//  Created by Christoph Krey on 21.10.17.
//  Copyright © 2017-2018 Christoph Krey. All rights reserved.
//
//

#import "Publication+CoreDataProperties.h"

@implementation Publication (CoreDataProperties)

+ (NSFetchRequest<Publication *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Publication"];
}

@dynamic contentType;
@dynamic correlationData;
@dynamic data;
@dynamic name;
@dynamic payloadFormatIndicator;
@dynamic position;
@dynamic messageExpiryInterval;
@dynamic qos;
@dynamic responseTopic;
@dynamic retained;
@dynamic topic;
@dynamic topicAlias;
@dynamic userProperties;
@dynamic belongsTo;

@end
