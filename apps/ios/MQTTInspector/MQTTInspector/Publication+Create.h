//
//  Publication+Create.h
//  MQTTInspector
//
//  Created by Christoph Krey on 12.11.13.
//  Copyright © 2013-2016 Christoph Krey. All rights reserved.
//

#import "Publication.h"

@interface Publication (Create)
+ (Publication *)existsPublicationWithName:(NSString *)name
                                   session:(Session *)session
                    inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Publication *)publicationWithName:(NSString *)name
                               topic:(NSString *)topic
                                 qos:(int)qos
                            retained:(BOOL)retained
                                data:(NSData *)data
                             session:(Session *)session
              inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
