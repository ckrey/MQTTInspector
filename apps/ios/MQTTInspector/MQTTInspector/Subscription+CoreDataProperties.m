//
//  Subscription+CoreDataProperties.m
//  MQTTInspector
//
//  Created by Christoph Krey on 22.12.15.
//  Copyright © 2015-2016 Christoph Krey. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Subscription+CoreDataProperties.h"

@implementation Subscription (CoreDataProperties)

@dynamic color;
@dynamic position;
@dynamic qos;
@dynamic state;
@dynamic topic;
@dynamic belongsTo;

@end
