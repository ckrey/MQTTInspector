//
//  Publication+Create.h
//  MQTTInspector
//
//  Created by Christoph Krey on 12.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "Publication.h"
#import "Session.h"

@interface Publication (Create)
+ (Publication *)publicationWithName:(NSString *)name
                               topic:(NSString *)topic
                                 qos:(int)qos
                            retained:(BOOL)retained
                                data:(NSData *)data
                             session:(Session *)session
              inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
