//
//  Command+CoreDataProperties.m
//  MQTTInspector
//
//  Created by Christoph Krey on 21.10.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//
//

#import "Command+CoreDataProperties.h"

@implementation Command (CoreDataProperties)

+ (NSFetchRequest<Command *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Command"];
}

@dynamic data;
@dynamic duped;
@dynamic inbound;
@dynamic mid;
@dynamic qos;
@dynamic retained;
@dynamic timestamp;
@dynamic type;
@dynamic belongsTo;

@end
