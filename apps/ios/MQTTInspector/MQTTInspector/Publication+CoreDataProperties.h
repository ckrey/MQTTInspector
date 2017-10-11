//
//  Publication+CoreDataProperties.h
//  MQTTInspector
//
//  Created by Christoph Krey on 11.10.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//
//

#import "Publication+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Publication (CoreDataProperties)

+ (NSFetchRequest<Publication *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *contentType;
@property (nullable, nonatomic, retain) NSData *correlationData;
@property (nullable, nonatomic, retain) NSData *data;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSNumber *payloadFormatIndicator;
@property (nullable, nonatomic, copy) NSNumber *position;
@property (nullable, nonatomic, copy) NSNumber *qos;
@property (nullable, nonatomic, copy) NSString *responseTopic;
@property (nullable, nonatomic, copy) NSNumber *retained;
@property (nullable, nonatomic, copy) NSString *topic;
@property (nullable, nonatomic, copy) NSNumber *topicAlias;
@property (nullable, nonatomic, retain) NSData *userProperties;
@property (nullable, nonatomic, copy) NSNumber *publicationExpiryInterval;
@property (nullable, nonatomic, retain) Session *belongsTo;

@end

NS_ASSUME_NONNULL_END
