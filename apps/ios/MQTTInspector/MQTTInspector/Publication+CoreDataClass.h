//
//  Publication+CoreDataClass.h
//  MQTTInspector
//
//  Created by Christoph Krey on 09.10.17.
//  Copyright © 2017-2018 Christoph Krey. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Session;

NS_ASSUME_NONNULL_BEGIN

@interface Publication : NSManagedObject
+ (Publication *)existsPublicationWithName:(NSString *)name
                                   session:(Session *)session
                    inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Publication *)publicationWithName:(NSString *)name
                               topic:(NSString *)topic
                                 qos:(int)qos
                            retained:(BOOL)retained
                                data:(NSData *)data
                             session:(Session *)session
              inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

NS_ASSUME_NONNULL_END

#import "Publication+CoreDataProperties.h"
