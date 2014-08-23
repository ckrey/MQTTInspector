//
//  Subscription.h
//  MQTTInspector
//
//  Created by Christoph Krey on 21.08.14.
//  Copyright (c) 2014 Christoph Krey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Session;

@interface Subscription : NSManagedObject

@property (nonatomic, retain) NSNumber * color;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSNumber * qos;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSString * topic;
@property (nonatomic, retain) Session *belongsTo;

@end
