//
//  Message.h
//  MQTTInspector
//
//  Created by Christoph Krey on 09.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message : NSManagedObject

@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * outbound;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * dup;
@property (nonatomic, retain) NSNumber * qos;
@property (nonatomic, retain) NSNumber * retained;
@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSManagedObject *belongsTo;

@end
