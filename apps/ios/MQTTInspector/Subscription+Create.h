//
//  Subscription+Create.h
//  MQTTInspector
//
//  Created by Christoph Krey on 12.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "Subscription.h"
#import "Session.h"

@interface Subscription (Create)
+ (Subscription *)subscriptionWithTopic:(NSString *)topic
                            qos:(int)qos
                        session:(Session *)session
         inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
@end
