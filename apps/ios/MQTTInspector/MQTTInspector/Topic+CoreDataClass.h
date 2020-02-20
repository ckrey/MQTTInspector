//
//  Topic+CoreDataClass.h
//  MQTTInspector
//
//  Created by Christoph Krey on 09.10.17.
//  Copyright © 2017-2020 Christoph Krey. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Session;

NS_ASSUME_NONNULL_BEGIN

@interface Topic : NSManagedObject
+ (Topic *)topicNamed:(NSString *)name
              session:(Session *)session
inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Topic *)existsTopicNamed:(NSString *)name
                    session:(Session *)session
     inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)allTopicsOfSession:(Session *)session inManagedObjectContext:(NSManagedObjectContext *)context;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *attributeText;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *attributeTextPart1;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *attributeTextPart2;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *attributeTextPart3;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *dataText;
- (void)setOld;

@end

NS_ASSUME_NONNULL_END

#import "Topic+CoreDataProperties.h"
