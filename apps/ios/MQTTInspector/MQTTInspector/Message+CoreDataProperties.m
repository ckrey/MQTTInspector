//
//  Message+CoreDataProperties.m
//  MQTTInspector
//
//  Created by Christoph Krey on 22.12.15.
//  Copyright © 2015-2016 Christoph Krey. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Message+CoreDataProperties.h"

@implementation Message (CoreDataProperties)

@dynamic data;
@dynamic mid;
@dynamic qos;
@dynamic retained;
@dynamic state;
@dynamic timestamp;
@dynamic topic;
@dynamic belongsTo;

@end
