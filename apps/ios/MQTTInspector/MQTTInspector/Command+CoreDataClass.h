//
//  Command+CoreDataClass.h
//  MQTTInspector
//
//  Created by Christoph Krey on 09.10.17.
//  Copyright © 2017-2019 Christoph Krey. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Session;

NS_ASSUME_NONNULL_BEGIN

@interface Command : NSManagedObject
+ (Command *)commandAt:(NSDate *)timestamp
               inbound:(BOOL)inbound
                  type:(int)type
                 duped:(BOOL)duped
                   qos:(int)qos
              retained:(BOOL)retained
                   mid:(unsigned int)mid
                  data:(NSData *)data
               session:(Session *)session
inManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSArray *)allCommandsOfSession:(Session *)session
           inManagedObjectContext:(NSManagedObjectContext *)context;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *attributeText;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *attributeTextPart1;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *attributeTextPart2;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *attributeTextPart3;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *dataText;

@end

NS_ASSUME_NONNULL_END

#import "Command+CoreDataProperties.h"
