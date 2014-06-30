//
//  Topic+Create.m
//  MQTTInspector
//
//  Created by Christoph Krey on 11.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "Topic+Create.h"
#import "MQTTInspectorDataViewController.h"

@implementation Topic (Create)

+ (Topic *)existsTopicNamed:(NSString *)name
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
        if ([matches count]) {
            topic = [matches lastObject];
        }
    }
    return topic;
}

+ (Topic *)topicNamed:(NSString *)name
            timestamp:(NSDate *)timestamp
                 data:(NSData *)data
                  qos:(int)qos
             retained:(BOOL)retained
                  mid:(unsigned int)mid
              session:(Session *)session
inManagedObjectContext:(NSManagedObjectContext *)context
{
    Topic *topic = [Topic existsTopicNamed:name session:session inManagedObjectContext:context];
    
    if (!topic) {
        topic = [NSEntityDescription insertNewObjectForEntityForName:@"Topic" inManagedObjectContext:context];
        
        topic.topic = name;
        topic.timestamp = timestamp;
        topic.data = data;
        topic.qos = @(qos);
        topic.retained = @(retained);
        topic.mid = @(mid);
        topic.belongsTo = session;
        topic.count = @(0);
        topic.justupdated = @(INTMAX_MAX);

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
    NSString *string = [NSString stringWithFormat:@" q%d r%d i%u (%lu) #%d",
                        [self.qos intValue],
                        [self.retained boolValue],
                        [self.mid unsignedIntValue],
                        (unsigned long)self.data.length,
                        [self.count intValue]];
    return string;
}

- (NSString *)dataText
{
    return [MQTTInspectorDataViewController dataToString:self.data];
}

- (BOOL)isJustupdated
{
    return [self.justupdated boolValue];
}

- (void)setOld
{
    self.justupdated = @FALSE;
}

@end
