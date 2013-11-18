//
//  Subscription.h
//  MQTTInspector
//
//  Created by Christoph Krey on 18.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Session;

@interface Subscription : NSManagedObject

@property (nonatomic, retain) NSNumber * color;
@property (nonatomic, retain) NSNumber * qos;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSString * topic;
@property (nonatomic, retain) Session *belongsTo;

@end
