//
//  Message+CoreDataClass.m
//  MQTTInspector
//
//  Created by Christoph Krey on 09.10.17.
//  Copyright © 2017-2019 Christoph Krey. All rights reserved.
//
//

#import "Message+CoreDataClass.h"

@implementation Message
+ (Message *)messageAt:(NSDate *)timestamp
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
        if (!matches.count) {
            message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];

            message.timestamp = timestamp;
            message.belongsTo = session;
            message.topic = nil;
            message.data = nil;
            message.qos = @(0);
            message.retained = @(false);
            message.mid = @(0);
            message.payloadFormatIndicator = nil;
            message.messageExpiryInterval = nil;
            message.topicAlias = nil;
            message.subscriptionIdentifiers = nil;
            message.userProperties = nil;
            message.responstTopic = nil;
            message.correlationData = nil;
            message.contentType = nil;
        } else {
            message = matches.lastObject;
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
            self.attributeTextPart1,
            self.attributeTextPart2,
            self.attributeTextPart3
            ];
}

- (NSString *)attributeTextPart1
{
    return [NSString stringWithFormat:@"%@ ",
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
            (self.qos).intValue,
            (self.retained).boolValue,
            (self.mid).unsignedIntValue,
            (unsigned long)self.data.length];
}

- (NSString *)dataText
{
    return [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
}



@end
