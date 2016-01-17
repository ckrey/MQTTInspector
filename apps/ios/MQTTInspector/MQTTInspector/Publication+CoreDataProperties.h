//
//  Publication+CoreDataProperties.h
//  MQTTInspector
//
//  Created by Christoph Krey on 22.12.15.
//  Copyright © 2015-2016 Christoph Krey. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Publication.h"

NS_ASSUME_NONNULL_BEGIN

@interface Publication (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *data;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *position;
@property (nullable, nonatomic, retain) NSNumber *qos;
@property (nullable, nonatomic, retain) NSNumber *retained;
@property (nullable, nonatomic, retain) NSString *topic;
@property (nullable, nonatomic, retain) Session *belongsTo;

@end

NS_ASSUME_NONNULL_END
