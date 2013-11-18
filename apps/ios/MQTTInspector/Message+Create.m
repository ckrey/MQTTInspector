//
//  Message+Create.m
//  MQTTInspector
//
//  Created by Christoph Krey on 11.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "Message+Create.h"
#import "MQTTInspectorDataViewController.h"

@implementation Message (Create)
+ (Message *)messageAt:(NSDate *)timestamp
                 topic:(NSString *)topic
                  data:(NSData *)data
                   qos:(int)qos
              retained:(BOOL)retained
                   mid:(unsigned int)mid
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
            message.qos = @(qos);
            message.retained = @(retained);
            message.mid = @(mid);
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

- (NSString *)attributeText
{
    return [NSString stringWithFormat:@"%@%@%@",
            [self attributeTextPart1],
            [self attributeTextPart2],
            [self attributeTextPart3]
            ];
}

- (NSString *)attributeTextPart1
{
    return [NSString stringWithFormat:@"%@ :",
            [NSDateFormatter localizedStringFromDate:self.timestamp
                                           dateStyle:NSDateFormatterShortStyle
                                           timeStyle:NSDateFormatterMediumStyle]
            ];
}

- (NSString *)attributeTextPart2
{
    return self.topic;
}

- (NSString *)attributeTextPart3
{
    return [NSString stringWithFormat:@" q%d r%d i%u (%lu)",
            [self.qos intValue],
            [self.retained boolValue],
            [self.mid unsignedIntValue],
            (unsigned long)self.data.length];
}

- (NSString *)dataText
{
    return [MQTTInspectorDataViewController dataToString:self.data];
}


@end
