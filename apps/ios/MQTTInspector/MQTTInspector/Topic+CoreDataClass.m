//
//  Topic+CoreDataClass.m
//  MQTTInspector
//
//  Created by Christoph Krey on 09.10.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//
//

#import "Topic+CoreDataClass.h"
#import "DataVC.h"

@implementation Topic

+ (Topic *)existsTopicNamed:(NSString *)name
                    session:(Session *)session
     inManagedObjectContext:(NSManagedObjectContext *)context {
    Topic *topic = nil;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Topic"];
    request.predicate = [NSPredicate predicateWithFormat:@"topic = %@ AND belongsTo = %@", name, session];

    NSError *error = nil;

    NSArray *matches = [context executeFetchRequest:request error:&error];

    if (!matches) {
        // handle error
    } else {
        if (matches.count) {
            topic = matches.lastObject;
        }
    }
    return topic;
}

+ (Topic *)topicNamed:(NSString *)name
              session:(Session *)session
inManagedObjectContext:(NSManagedObjectContext *)context {
    Topic *topic = [Topic existsTopicNamed:name session:session inManagedObjectContext:context];

    if (!topic) {
        topic = [NSEntityDescription insertNewObjectForEntityForName:@"Topic" inManagedObjectContext:context];

        topic.topic = name;
        topic.belongsTo = session;
        topic.timestamp = nil;
        topic.data = nil;
        topic.qos = @(0);
        topic.retained = @(false);
        topic.mid = @(0);
        topic.count = @(0);
        topic.justupdated = [NSNumber numberWithBool:TRUE];
        topic.payloadFormatIndicator = nil;
        topic.publicationExpiryInterval = nil;
        topic.topicAlias = nil;
        topic.responseTopic = nil;
        topic.correlationData = nil;
        topic.userProperties = nil;
        topic.subscriptionIdentifiers = nil;
    }
    return topic;
}

+ (NSArray *)allTopicsOfSession:(Session *)session
         inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Topic"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
    request.predicate = [NSPredicate predicateWithFormat:@"belongsTo = %@", session];

    NSError *error = nil;

    NSArray *matches = [context executeFetchRequest:request error:&error];

    return matches;
}

- (NSString *)attributeText {
    return [NSString stringWithFormat:@"%@%@%@",
            self.attributeTextPart1,
            self.attributeTextPart2,
            self.attributeTextPart3
            ];
}

- (NSString *)attributeTextPart1 {
    return [NSString stringWithFormat:@"%@ :",
            [NSDateFormatter localizedStringFromDate:self.timestamp
                                           dateStyle:NSDateFormatterShortStyle
                                           timeStyle:NSDateFormatterMediumStyle]
            ];
}

- (NSString *)attributeTextPart2 {
    return self.topic;
}

- (NSString *)attributeTextPart3 {
    NSString *string = [NSString stringWithFormat:@" q%d r%d i%u (%lu) #%d",
                        (self.qos).intValue,
                        (self.retained).boolValue,
                        (self.mid).unsignedIntValue,
                        (unsigned long)self.data.length,
                        (self.count).intValue];
    return string;
}

- (NSString *)dataText {
    return [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
}

- (void)setOld {
    self.justupdated = [NSNumber numberWithBool:false];
}


@end
