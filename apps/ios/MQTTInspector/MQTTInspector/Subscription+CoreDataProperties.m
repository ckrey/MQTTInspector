//
//  Subscription+CoreDataProperties.m
//  MQTTInspector
//
//  Created by Christoph Krey on 21.10.17.
//  Copyright © 2017-2018 Christoph Krey. All rights reserved.
//
//

#import "Subscription+CoreDataProperties.h"

@implementation Subscription (CoreDataProperties)

+ (NSFetchRequest<Subscription *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Subscription"];
}

@dynamic color;
@dynamic name;
@dynamic noLocal;
@dynamic position;
@dynamic qos;
@dynamic retainAsPublished;
@dynamic retainHandling;
@dynamic state;
@dynamic susbscriptionIdentifier;
@dynamic topic;
@dynamic userProperties;
@dynamic belongsTo;

@end
