//
//  Publication+CoreDataProperties.h
//  MQTTInspector
//
//  Created by Christoph Krey on 09.10.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//
//

#import "Publication+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Publication (CoreDataProperties)

+ (NSFetchRequest<Publication *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSData *data;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSNumber *position;
@property (nullable, nonatomic, copy) NSNumber *qos;
@property (nullable, nonatomic, copy) NSNumber *retained;
@property (nullable, nonatomic, copy) NSString *topic;
@property (nullable, nonatomic, retain) Session *belongsTo;

@end

NS_ASSUME_NONNULL_END
