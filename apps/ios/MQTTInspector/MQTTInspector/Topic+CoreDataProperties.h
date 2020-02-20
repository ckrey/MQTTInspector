//
//  Topic+CoreDataProperties.h
//  MQTTInspector
//
//  Created by Christoph Krey on 21.10.17.
//  Copyright © 2017-2020 Christoph Krey. All rights reserved.
//
//

#import "Topic+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Topic (CoreDataProperties)

+ (NSFetchRequest<Topic *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *contentType;
@property (nullable, nonatomic, retain) NSData *correlationData;
@property (nullable, nonatomic, copy) NSNumber *count;
@property (nullable, nonatomic, retain) NSData *data;
@property (nullable, nonatomic, copy) NSNumber *justupdated;
@property (nullable, nonatomic, copy) NSNumber *mid;
@property (nullable, nonatomic, copy) NSNumber *payloadFormatIndicator;
@property (nullable, nonatomic, copy) NSNumber *messageExpiryInterval;
@property (nullable, nonatomic, copy) NSNumber *qos;
@property (nullable, nonatomic, copy) NSString *responseTopic;
@property (nullable, nonatomic, copy) NSNumber *retained;
@property (nullable, nonatomic, retain) NSData *subscriptionIdentifiers;
@property (nullable, nonatomic, copy) NSDate *timestamp;
@property (nullable, nonatomic, copy) NSString *topic;
@property (nullable, nonatomic, copy) NSNumber *topicAlias;
@property (nullable, nonatomic, retain) NSData *userProperties;
@property (nullable, nonatomic, retain) Session *belongsTo;

@end

NS_ASSUME_NONNULL_END
