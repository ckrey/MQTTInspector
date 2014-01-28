//
//  Publication+Create.m
//  MQTTInspector
//
//  Created by Christoph Krey on 12.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "Publication+Create.h"

@implementation Publication (Create)
+ (Publication *)publicationWithName:(NSString *)name
                               topic:(NSString *)topic
                                 qos:(int)qos
                            retained:(BOOL)retained
                                data:(NSData *)data
                             session:(Session *)session
              inManagedObjectContext:(NSManagedObjectContext *)context
{
    Publication *publication = [Publication existsPublicationWithName:name session:session inManagedObjectContext:context];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Publication"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@ AND belongsTo = %@", name, session];
    
    if (!publication) {
        publication = [NSEntityDescription insertNewObjectForEntityForName:@"Publication" inManagedObjectContext:context];
        
        publication.name = name;
        publication.topic = topic;
        publication.data = data;
        publication.qos = @(qos);
        publication.retained = @(retained);
        publication.position = @([Publication newPosition:session]);
        publication.belongsTo = session;
        publication.state = @(0);
    }
    
    return publication;
}

+ (Publication *)existsPublicationWithName:(NSString *)name
                                   session:(Session *)session
                    inManagedObjectContext:(NSManagedObjectContext *)context
{
    Publication *publication = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Publication"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@ AND belongsTo = %@", name, session];
    
    NSError *error = nil;
    
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        // handle error
    } else {
        if ([matches count]) {
            publication = [matches lastObject];
            publication.state = @(0);
            for (Publication *pub in session.hasPubs) {
                if (!pub.position) {
                    pub.position = @([Publication newPosition:session]);
                }
            }
        }
    }
    
    return publication;
    
    
}

+ (NSUInteger)newPosition:(Session *)session
{
    NSUInteger position = 0;
    
    for (Publication *pub in session.hasPubs) {
        if ([pub.position unsignedIntegerValue] >= position) {
            position = [pub.position unsignedIntegerValue] + 1;
        }
    }
    return position;
}



@end
