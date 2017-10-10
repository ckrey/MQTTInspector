//
//  Message+CoreDataClass.h
//  MQTTInspector
//
//  Created by Christoph Krey on 09.10.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Session;

NS_ASSUME_NONNULL_BEGIN

@interface Message : NSManagedObject
+ (Message *)messageAt:(NSDate *)timestamp
               session:(Session *)session
inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)allMessagesOfSession:(Session *)session inManagedObjectContext:(NSManagedObjectContext *)context;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *attributeText;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *attributeTextPart1;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *attributeTextPart2;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *attributeTextPart3;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *dataText;


@end

NS_ASSUME_NONNULL_END

#import "Message+CoreDataProperties.h"
