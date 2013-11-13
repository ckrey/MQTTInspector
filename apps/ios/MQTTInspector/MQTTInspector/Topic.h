//
//  Topic.h
//  MQTTInspector
//
//  Created by Christoph Krey on 12.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Session;

@interface Topic : NSManagedObject

@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * topic;
@property (nonatomic, retain) Session *belongsTo;

@end
