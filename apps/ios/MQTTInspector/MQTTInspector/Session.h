//
//  Session.h
//  MQTTInspector
//
//  Created by Christoph Krey on 22.12.15.
//  Copyright © 2015-2016 Christoph Krey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Command, Message, Publication, Subscription, Topic;

NS_ASSUME_NONNULL_BEGIN

@interface Session : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "Session+CoreDataProperties.h"
