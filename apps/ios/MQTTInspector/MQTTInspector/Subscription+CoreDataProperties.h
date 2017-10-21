//
//  Subscription+CoreDataProperties.h
//  MQTTInspector
//
//  Created by Christoph Krey on 21.10.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//
//

#import "Subscription+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Subscription (CoreDataProperties)

+ (NSFetchRequest<Subscription *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *color;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSNumber *noLocal;
@property (nullable, nonatomic, copy) NSNumber *position;
@property (nullable, nonatomic, copy) NSNumber *qos;
@property (nullable, nonatomic, copy) NSNumber *retainAsPublished;
@property (nullable, nonatomic, copy) NSNumber *retainHandling;
@property (nullable, nonatomic, copy) NSNumber *state;
@property (nullable, nonatomic, copy) NSNumber *susbscriptionIdentifier;
@property (nullable, nonatomic, copy) NSString *topic;
@property (nullable, nonatomic, retain) NSData *userProperties;
@property (nullable, nonatomic, retain) Session *belongsTo;

@end

NS_ASSUME_NONNULL_END
