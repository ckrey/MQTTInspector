//
//  Topic+Create.h
//  MQTTInspector
//
//  Created by Christoph Krey on 11.11.13.
//  Copyright © 2013-2016 Christoph Krey. All rights reserved.
//

#import "Topic.h"

@interface Topic (Create)
+ (Topic *)topicNamed:(NSString *)name
            timestamp:(NSDate *)timestamp
                 data:(NSData *)data
                  qos:(int)qos
             retained:(BOOL)retained
                  mid:(unsigned int)mid
              session:(Session *)session
inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Topic *)existsTopicNamed:(NSString *)name
              session:(Session *)session
inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)allTopicsOfSession:(Session *)session inManagedObjectContext:(NSManagedObjectContext *)context;

- (NSString *)attributeText;
- (NSString *)attributeTextPart1;
- (NSString *)attributeTextPart2;
- (NSString *)attributeTextPart3;
- (NSString *)dataText;
- (BOOL)isJustupdated;
- (void)setOld;

@end
