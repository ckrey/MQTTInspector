//
//  Topic+Create.m
//  MQTTInspector
//
//  Created by Christoph Krey on 11.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "Topic+Create.h"

@implementation Topic (Create)

+ (Topic *)topicNamed:(NSString *)name
            timestamp:(NSDate *)timestamp
                 data:(NSData *)data
              session:(Session *)session
inManagedObjectContext:(NSManagedObjectContext *)context
{
    Topic *topic = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Topic"];
    request.predicate = [NSPredicate predicateWithFormat:@"topic = %@ AND belongsTo = %@", name, session];
    
    NSError *error = nil;
    
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        // handle error
    } else {
        if (![matches count]) {
            topic = [NSEntityDescription insertNewObjectForEntityForName:@"Topic" inManagedObjectContext:context];
            
            topic.topic = name;
            topic.timestamp = timestamp;
            topic.data = data;
            topic.belongsTo = session;
            topic.count = @(0);
        } else {
            topic = [matches lastObject];
            topic.timestamp = timestamp;
            topic.data = data;
            topic.count = @([topic.count intValue] + 1);
        }
    }
    
    return topic;
    
}

+ (NSArray *)allTopicsOfSession:(Session *)session inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Topic"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
    request.predicate = [NSPredicate predicateWithFormat:@"belongsTo = %@", session];
    
    NSError *error = nil;
    
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    return matches;
}

@end
