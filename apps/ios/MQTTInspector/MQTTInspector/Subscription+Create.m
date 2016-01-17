//
//  Subscription+Create.m
//  MQTTInspector
//
//  Created by Christoph Krey on 12.11.13.
//  Copyright © 2013-2016 Christoph Krey. All rights reserved.
//

#import "Subscription+Create.h"
#import "Session.h"

@implementation Subscription (Create)

+ (Subscription *)subscriptionWithTopic:(NSString *)topic
                            qos:(int)qos
                        session:(Session *)session
         inManagedObjectContext:(NSManagedObjectContext *)context
{
    Subscription *subscription = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Subscription"];
    request.predicate = [NSPredicate predicateWithFormat:@"topic = %@ AND belongsTo = %@", topic, session];
    
    NSError *error = nil;
    
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        // handle error
    } else {
        if (![matches count]) {
            subscription = [NSEntityDescription insertNewObjectForEntityForName:@"Subscription" inManagedObjectContext:context];
            
            subscription.topic = topic;
            subscription.qos = @(qos);
            
            subscription.color = @([Subscription uniqueHue:session]);
            subscription.position = @([Subscription newPosition:session]);
            subscription.belongsTo = session;
            subscription.state = @(false);
        } else {
            subscription = [matches lastObject];
            if (subscription.state == nil) {
                subscription.state = @(false);
            }
        }
    }

    return subscription;
}

+ (Subscription *)existsSubscriptionWithTopic:(NSString *)topic
                                   session:(Session *)session
                    inManagedObjectContext:(NSManagedObjectContext *)context
{
    Subscription *subscription = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Subscription"];
    request.predicate = [NSPredicate predicateWithFormat:@"topic = %@ AND belongsTo = %@", topic, session];
    
    NSError *error = nil;
    
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        // handle error
    } else {
        if ([matches count]) {
            subscription = [matches lastObject];
            for (Subscription *sub in session.hasSubs) {
                if (!sub.position) {
                    sub.position = @([Subscription newPosition:session]);
                }
            }
        }
    }
    
    return subscription;
}


+ (float)uniqueHue:(Session *)session
{
    float hue;
    for (int i = 2; TRUE ; i *= 2) {
        for (int j = 1; j < i; j += 2) {
            hue = (float)j / (float)i;
            BOOL exists = FALSE;
            for (Subscription *otherSubscription in session.hasSubs) {
                if ([otherSubscription.color floatValue] == hue) {
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

+ (NSUInteger)newPosition:(Session *)session
{
    NSUInteger position = 0;
    
    for (Subscription *sub in session.hasSubs) {
        if ([sub.position unsignedIntegerValue] >= position) {
            position = [sub.position unsignedIntegerValue] + 1;
        }
    }
    return position;
}

- (UIColor *)getColor
{
    DDLogInfo(@"getColor %@:%@", self.topic, self.color);
    return [UIColor colorWithHue:[self.color floatValue] saturation:0.3 brightness:1.0 alpha:1.0];
}

@end
