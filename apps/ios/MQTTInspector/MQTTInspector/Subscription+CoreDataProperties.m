//
//  Subscription+CoreDataProperties.m
//  MQTTInspector
//
//  Created by Christoph Krey on 09.10.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//
//

#import "Subscription+CoreDataProperties.h"

@implementation Subscription (CoreDataProperties)

+ (NSFetchRequest<Subscription *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Subscription"];
}

@dynamic color;
@dynamic noLocal;
@dynamic position;
@dynamic qos;
@dynamic retainAsPublished;
@dynamic retainHandling;
@dynamic state;
@dynamic susbscriptionIdentifier;
@dynamic topic;
@dynamic name;
@dynamic belongsTo;

@end
