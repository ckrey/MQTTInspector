//
//  Command+Create.m
//  MQTTInspector
//
//  Created by Christoph Krey on 12.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "Command+Create.h"

@implementation Command (Create)
+ (Command *)commandAt:(NSDate *)timestamp inbound:(BOOL)inbound type:(int)type duped:(BOOL)duped qos:(int)qos retained:(BOOL)retained data:(NSData *)data session:(Session *)session inManagedObjectContext:(NSManagedObjectContext *)context
{
    Command *command = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Command"];
    request.predicate = [NSPredicate predicateWithFormat:@"timestamp = %@ AND belongsTo = %@", timestamp, session];
    
    NSError *error = nil;
    
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        // handle error
    } else {
        if (![matches count]) {
            command = [NSEntityDescription insertNewObjectForEntityForName:@"Command" inManagedObjectContext:context];
            
            command.timestamp = timestamp;
            command.inbound = @(inbound);
            command.type = @(type);
            command.duped = @(duped);
            command.qos = @(qos);
            command.retained = @(retained);
            command.data = data;
            command.belongsTo = session;
        } else {
            command = [matches lastObject];
        }
    }
    
    return command;
    

}

+ (NSArray *)allCommandsOfSession:(Session *)session inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Command"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
    request.predicate = [NSPredicate predicateWithFormat:@"belongsTo = %@", session];
    
    NSError *error = nil;
    
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    return matches;
}

@end
