//
//  Subscription+CoreDataClass.h
//  MQTTInspector
//
//  Created by Christoph Krey on 05.09.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <mqttc/MQTTMessage.h>

@class Session;

NS_ASSUME_NONNULL_BEGIN

@interface Subscription : NSManagedObject
+ (Subscription *)existsSubscriptionWithName:(NSString *)name
                                     session:(Session *)session
                      inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Subscription *)subscriptionWithName:(NSString *)name
                                 topic:(NSString *)topic
                                   qos:(MQTTQosLevel)qos
                               noLocal:(BOOL)noLocal
                     retainAsPublished:(BOOL)retainAsPublished
                        retainHandling:(MQTTRetainHandling)retainHandling
                subscriptionIdentifier:(UInt32)subscriptionIdentifier
                               session:(Session *)session
                inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@property (NS_NONATOMIC_IOSONLY, getter=getUIColor, readonly, copy) UIColor * _Nonnull UIcolor;

@end

NS_ASSUME_NONNULL_END

#import "Subscription+CoreDataProperties.h"
