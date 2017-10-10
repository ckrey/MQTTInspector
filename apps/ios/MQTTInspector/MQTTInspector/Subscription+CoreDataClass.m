//
//  Subscription+CoreDataClass.m
//  MQTTInspector
//
//  Created by Christoph Krey on 05.09.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//

#import "Subscription+CoreDataClass.h"
#import "Session+CoreDataClass.h"

@implementation Subscription

+ (Subscription *)subscriptionWithName:(NSString *)name
                                 topic:(NSString *)topic
                                   qos:(MQTTQosLevel)qos
                               noLocal:(BOOL)noLocal
                     retainAsPublished:(BOOL)retainAsPublished
                        retainHandling:(MQTTRetainHandling)retainHandling
                subscriptionIdentifier:(UInt32)subscriptionIdentifier
                               session:(Session *)session
                inManagedObjectContext:(NSManagedObjectContext *)context {
    Subscription *subscription = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Subscription"];
    request.predicate = [NSPredicate predicateWithFormat:@"topic = %@ AND belongsTo = %@", topic, session];
    
    NSError *error = nil;
    
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        // handle error
    } else {
        if (!matches.count) {
            subscription = [NSEntityDescription insertNewObjectForEntityForName:@"Subscription" inManagedObjectContext:context];
            
            subscription.topic = topic;
            subscription.qos = @(qos);
            
            subscription.color = @([Subscription uniqueHue:session]);
            subscription.position = @([Subscription newPosition:session]);
            subscription.belongsTo = session;
            subscription.state = @(false);
        } else {
            subscription = matches.lastObject;
            if (subscription.state == nil) {
                subscription.state = @(false);
            }
        }
    }
    
    return subscription;
}

+ (Subscription *)existsSubscriptionWithName:(NSString *)name
                                     session:(Session *)session
                      inManagedObjectContext:(NSManagedObjectContext *)context {
    Subscription *subscription = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Subscription"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@ AND belongsTo = %@",
                         name, session];
    
    NSError *error = nil;
    
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        // handle error
    } else {
        if (matches.count) {
            subscription = matches.lastObject;
            for (Subscription *sub in session.hasSubs) {
                if (!sub.position) {
                    sub.position = @([Subscription newPosition:session]);
                }
            }
        }
    }
    
    return subscription;
}


+ (float)uniqueHue:(Session *)session {
    float hue;
    for (int i = 2; TRUE ; i *= 2) {
        for (int j = 1; j < i; j += 2) {
            hue = (float)j / (float)i;
            BOOL exists = FALSE;
            for (Subscription *otherSubscription in session.hasSubs) {
                if ((otherSubscription.color).floatValue == hue) {
                    exists = TRUE;
                    break;
                }
            }
            if (!exists) {
                return hue;
            }
        }
    }
}

+ (NSUInteger)newPosition:(Session *)session {
    NSUInteger position = 0;
    
    for (Subscription *sub in session.hasSubs) {
        if ((sub.position).unsignedIntegerValue >= position) {
            position = (sub.position).unsignedIntegerValue + 1;
        }
    }
    return position;
}

- (UIColor *)getUIColor {
    DDLogInfo(@"getColor %@:%@", self.topic, self.color);
    return [UIColor colorWithHue:(self.color).floatValue saturation:0.3 brightness:1.0 alpha:1.0];
}


@end
