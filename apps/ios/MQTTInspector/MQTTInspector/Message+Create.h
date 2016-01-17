//
//  Message+Create.h
//  MQTTInspector
//
//  Created by Christoph Krey on 11.11.13.
//  Copyright © 2013-2016 Christoph Krey. All rights reserved.
//

#import "Message.h"

@interface Message (Create)
+ (Message *)messageAt:(NSDate *)timestamp
                 topic:(NSString *)topic
                  data:(NSData *)data
                   qos:(int)qos
              retained:(BOOL)retained
                   mid:(unsigned int)mid
               session:(Session *)session
inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)allMessagesOfSession:(Session *)session inManagedObjectContext:(NSManagedObjectContext *)context;

- (NSString *)attributeText;
- (NSString *)attributeTextPart1;
- (NSString *)attributeTextPart2;
- (NSString *)attributeTextPart3;
- (NSString *)dataText;

@end
