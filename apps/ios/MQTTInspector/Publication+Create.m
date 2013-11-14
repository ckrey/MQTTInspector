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
    Publication *publication = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Publication"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@ AND belongsTo = %@", name, session];
    
    NSError *error = nil;
    
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        // handle error
    } else {
        if (![matches count]) {
            publication = [NSEntityDescription insertNewObjectForEntityForName:@"Publication" inManagedObjectContext:context];
            
            publication.name = name;
            publication.topic = topic;
            publication.data = data;
            publication.qos = @(qos);
            publication.retained = @(retained);
            publication.belongsTo = session;
        } else {
            publication = [matches lastObject];
        }
        publication.state = @(0);
    }
    
    return publication;
    

}

@end
