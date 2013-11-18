//
//  Subscription+Create.m
//  MQTTInspector
//
//  Created by Christoph Krey on 12.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "Subscription+Create.h"

@implementation Subscription (Create)
+ (Subscription *)subscriptionWithTopic:(NSString *)topic
                            qos:(int)qos
                        session:(Session *)session
         inManagedObjectContext:(NSManagedObjectContext *)context
{
    float r = rand();

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

            float f = r / INT_MAX;
            float hue = fmod(f,1);
            subscription.color = @(hue);

            subscription.belongsTo = session;
        } else {
            subscription = [matches lastObject];

        }
        subscription.state = @(0);
    }

    return subscription;
}

- (UIColor *)getColor
{
#ifdef DEBUG
    NSLog(@"getColor %@:%@", self.topic, self.color);
#endif
    return [UIColor colorWithHue:[self.color floatValue] saturation:0.3 brightness:1.0 alpha:1.0];
}

@end
