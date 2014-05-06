//
//  Command.h
//  MQTTInspector
//
//  Created by Christoph Krey on 05.05.14.
//  Copyright (c) 2014 Christoph Krey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Session;

@interface Command : NSManagedObject

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSNumber * duped;
@property (nonatomic, retain) NSNumber * inbound;
@property (nonatomic, retain) NSNumber * mid;
@property (nonatomic, retain) NSNumber * qos;
@property (nonatomic, retain) NSNumber * retained;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) Session *belongsTo;

@end
