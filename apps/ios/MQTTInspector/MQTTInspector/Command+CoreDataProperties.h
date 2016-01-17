//
//  Command+CoreDataProperties.h
//  MQTTInspector
//
//  Created by Christoph Krey on 22.12.15.
//  Copyright © 2015-2016 Christoph Krey. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Command.h"

NS_ASSUME_NONNULL_BEGIN

@interface Command (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *data;
@property (nullable, nonatomic, retain) NSNumber *duped;
@property (nullable, nonatomic, retain) NSNumber *inbound;
@property (nullable, nonatomic, retain) NSNumber *mid;
@property (nullable, nonatomic, retain) NSNumber *qos;
@property (nullable, nonatomic, retain) NSNumber *retained;
@property (nullable, nonatomic, retain) NSDate *timestamp;
@property (nullable, nonatomic, retain) NSNumber *type;
@property (nullable, nonatomic, retain) Session *belongsTo;

@end

NS_ASSUME_NONNULL_END
