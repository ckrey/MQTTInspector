//
//  Publication+CoreDataProperties.m
//  MQTTInspector
//
//  Created by Christoph Krey on 09.10.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//
//

#import "Publication+CoreDataProperties.h"

@implementation Publication (CoreDataProperties)

+ (NSFetchRequest<Publication *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Publication"];
}

@dynamic data;
@dynamic name;
@dynamic position;
@dynamic qos;
@dynamic retained;
@dynamic topic;
@dynamic belongsTo;

@end
