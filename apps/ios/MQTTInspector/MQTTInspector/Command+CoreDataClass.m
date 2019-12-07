//
//  Command+CoreDataClass.m
//  MQTTInspector
//
//  Created by Christoph Krey on 09.10.17.
//  Copyright © 2017-2019 Christoph Krey. All rights reserved.
//
//

#import "Command+CoreDataClass.h"

@implementation Command
+ (Command *)commandAt:(NSDate *)timestamp
               inbound:(BOOL)inbound
                  type:(int)type
                 duped:(BOOL)duped
                   qos:(int)qos
              retained:(BOOL)retained
                   mid:(unsigned int)mid
                  data:(NSData *)data
               session:(Session *)session
inManagedObjectContext:(NSManagedObjectContext *)context {
    Command *command = nil;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Command"];
    request.predicate = [NSPredicate predicateWithFormat:@"timestamp = %@ AND belongsTo = %@", timestamp, session];

    NSError *error = nil;

    NSArray *matches = [context executeFetchRequest:request error:&error];

    if (!matches) {
        // handle error
    } else {
        if (!matches.count) {
            command = [NSEntityDescription insertNewObjectForEntityForName:@"Command" inManagedObjectContext:context];

            command.timestamp = timestamp;
            command.inbound = @(inbound);
            command.type = @(type);
            command.duped = @(duped);
            command.qos = @(qos);
            command.retained = @(retained);
            command.data = data;
            command.mid = @(mid);
            command.belongsTo = session;
        } else {
            command = matches.lastObject;
        }
    }

    return command;


}

- (NSString *)attributeText {
    return [NSString stringWithFormat:@"%@%@%@",
            self.attributeTextPart1,
            self.attributeTextPart2,
            self.attributeTextPart3
            ];
}

- (NSString *)attributeTextPart1 {
    return [NSString stringWithFormat:@"%@ %@ ",
            [NSDateFormatter localizedStringFromDate:self.timestamp
                                           dateStyle:NSDateFormatterShortStyle
                                           timeStyle:NSDateFormatterMediumStyle],
            (self.inbound).boolValue ? @"incoming" : @"outgoing"
            ];
}

- (NSString *)attributeTextPart2 {
    const NSArray *commandNames = @[
                                    @"Reserved0",
                                    @"CONNECT",
                                    @"CONNACK",
                                    @"PUBLISH",
                                    @"PUBACK",
                                    @"PUBREC",
                                    @"PUBREL",
                                    @"PUBCOMP",
                                    @"SUBSCRIBE",
                                    @"SUBACK",
                                    @"UNSUBSCRIBE",
                                    @"UNSUBACK",
                                    @"PINGREQ",
                                    @"PINGRESP",
                                    @"DISCONNECT",
                                    @"Reserved15"
                                    ];

    return commandNames[(self.type).intValue];
}

- (NSString *)attributeTextPart3 {
    return [NSString stringWithFormat:@" d%@ q%@ r%@ i%u",
            self.duped,
            self.qos,
            self.retained,
            (self.mid).unsignedIntValue
            ];
}

- (NSString *)dataText {
    return [NSString stringWithFormat:@"(%lu) %@",
            (unsigned long)self.data.length,
            (self.data).description];
}


+ (NSArray *)allCommandsOfSession:(Session *)session
           inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Command"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
    request.predicate = [NSPredicate predicateWithFormat:@"belongsTo = %@", session];

    NSError *error = nil;

    NSArray *matches = [context executeFetchRequest:request error:&error];

    return matches;
}


@end
