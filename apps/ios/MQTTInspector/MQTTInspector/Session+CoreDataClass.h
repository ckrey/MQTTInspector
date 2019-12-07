//
//  Session+CoreDataClass.h
//  MQTTInspector
//
//  Created by Christoph Krey on 09.10.17.
//  Copyright © 2017-2019 Christoph Krey. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Command, Message, Publication, Subscription, Topic;

NS_ASSUME_NONNULL_BEGIN

@interface Session : NSManagedObject
+ (Session *)existSessionWithName:(NSString *)name
           inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Session *)sessionWithName:(NSString * _Nonnull)name
      inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)allSessions:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "Session+CoreDataProperties.h"
