//
//  Message+Create.h
//  MQTTInspector
//
//  Created by Christoph Krey on 11.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "Message.h"
#import "Session+Create.h"

@interface Message (Create)
+ (Message *)messageAt:(NSDate *)timestamp
                 topic:(NSString *)topic
                  data:(NSData *)data
               session:(Session *)session
inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)allMessagesOfSession:(Session *)session inManagedObjectContext:(NSManagedObjectContext *)context;
@end
