//
//  Message+Create.m
//  MQTTInspector
//
//  Created by Christoph Krey on 11.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "Message+Create.h"

@implementation Message (Create)
+ (Message *)messageAt:(NSDate *)timestamp
                 topic:(NSString *)topic
                  data:(NSData *)data
               session:(Session *)session
inManagedObjectContext:(NSManagedObjectContext *)context
{
    Message *message = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    request.predicate = [NSPredicate predicateWithFormat:@"timestamp = %@ AND belongsTo = %@", timestamp, session];
    
    NSError *error = nil;
    
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        // handle error
    } else {
        if (![matches count]) {
            message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
            
            message.timestamp = timestamp;
            message.topic = topic;
            message.data = data;
            message.belongsTo = session;
        } else {
            message = [matches lastObject];
        }
        message.state = @(0);
    }
    
    return message;

}

+ (NSArray *)allMessagesOfSession:(Session *)session inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
    request.predicate = [NSPredicate predicateWithFormat:@"belongsTo = %@", session];
    
    NSError *error = nil;
    
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    return matches;
}

@end
