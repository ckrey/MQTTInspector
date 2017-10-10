//
//  Command+CoreDataProperties.h
//  MQTTInspector
//
//  Created by Christoph Krey on 09.10.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//
//

#import "Command+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Command (CoreDataProperties)

+ (NSFetchRequest<Command *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSData *data;
@property (nullable, nonatomic, copy) NSNumber *duped;
@property (nullable, nonatomic, copy) NSNumber *inbound;
@property (nullable, nonatomic, copy) NSNumber *mid;
@property (nullable, nonatomic, copy) NSNumber *qos;
@property (nullable, nonatomic, copy) NSNumber *retained;
@property (nullable, nonatomic, copy) NSDate *timestamp;
@property (nullable, nonatomic, copy) NSNumber *type;
@property (nullable, nonatomic, retain) Session *belongsTo;

@end

NS_ASSUME_NONNULL_END
