//
//  Topic+Create.h
//  MQTTInspector
//
//  Created by Christoph Krey on 11.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "Topic.h"

@interface Topic (Create)
+ (Topic *)topicNamed:(NSString *)name
                 timestamp:(NSDate *)timestamp
                  data:(NSData *)data
               session:(Session *)session
inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)allTopicsOfSession:(Session *)session inManagedObjectContext:(NSManagedObjectContext *)context;
@end
