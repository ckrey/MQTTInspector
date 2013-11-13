//
//  Command+Create.h
//  MQTTInspector
//
//  Created by Christoph Krey on 12.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "Command.h"
#import "Session.h"

@interface Command (Create)
+ (Command *)commandAt:(NSDate *)timestamp
               inbound:(BOOL)inbound
                  type:(int)type
                 duped:(BOOL)duped
                   qos:(int)qos
              retained:(BOOL)retained
                  data:(NSData *)data
               session:(Session *)session
inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)allCommandsOfSession:(Session *)session inManagedObjectContext:(NSManagedObjectContext *)context;
@end
