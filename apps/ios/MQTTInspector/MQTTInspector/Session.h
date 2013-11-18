//
//  Session.h
//  MQTTInspector
//
//  Created by Christoph Krey on 18.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Command, Message, Publication, Subscription, Topic;

@interface Session : NSManagedObject

@property (nonatomic, retain) NSNumber * auth;
@property (nonatomic, retain) NSNumber * cleansession;
@property (nonatomic, retain) NSString * clientid;
@property (nonatomic, retain) NSString * dnsdomain;
@property (nonatomic, retain) NSNumber * dnssrv;
@property (nonatomic, retain) NSString * host;
@property (nonatomic, retain) NSNumber * keepalive;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * passwd;
@property (nonatomic, retain) NSNumber * port;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSNumber * tls;
@property (nonatomic, retain) NSString * user;
@property (nonatomic, retain) NSOrderedSet *hasCommands;
@property (nonatomic, retain) NSOrderedSet *hasMesssages;
@property (nonatomic, retain) NSOrderedSet *hasPubs;
@property (nonatomic, retain) NSOrderedSet *hasSubs;
@property (nonatomic, retain) NSOrderedSet *hasTopics;
@end

@interface Session (CoreDataGeneratedAccessors)

- (void)insertObject:(Command *)value inHasCommandsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromHasCommandsAtIndex:(NSUInteger)idx;
- (void)insertHasCommands:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeHasCommandsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInHasCommandsAtIndex:(NSUInteger)idx withObject:(Command *)value;
- (void)replaceHasCommandsAtIndexes:(NSIndexSet *)indexes withHasCommands:(NSArray *)values;
- (void)addHasCommandsObject:(Command *)value;
- (void)removeHasCommandsObject:(Command *)value;
- (void)addHasCommands:(NSOrderedSet *)values;
- (void)removeHasCommands:(NSOrderedSet *)values;
- (void)insertObject:(Message *)value inHasMesssagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromHasMesssagesAtIndex:(NSUInteger)idx;
- (void)insertHasMesssages:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeHasMesssagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInHasMesssagesAtIndex:(NSUInteger)idx withObject:(Message *)value;
- (void)replaceHasMesssagesAtIndexes:(NSIndexSet *)indexes withHasMesssages:(NSArray *)values;
- (void)addHasMesssagesObject:(Message *)value;
- (void)removeHasMesssagesObject:(Message *)value;
- (void)addHasMesssages:(NSOrderedSet *)values;
- (void)removeHasMesssages:(NSOrderedSet *)values;
- (void)insertObject:(Publication *)value inHasPubsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromHasPubsAtIndex:(NSUInteger)idx;
- (void)insertHasPubs:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeHasPubsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInHasPubsAtIndex:(NSUInteger)idx withObject:(Publication *)value;
- (void)replaceHasPubsAtIndexes:(NSIndexSet *)indexes withHasPubs:(NSArray *)values;
- (void)addHasPubsObject:(Publication *)value;
- (void)removeHasPubsObject:(Publication *)value;
- (void)addHasPubs:(NSOrderedSet *)values;
- (void)removeHasPubs:(NSOrderedSet *)values;
- (void)insertObject:(Subscription *)value inHasSubsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromHasSubsAtIndex:(NSUInteger)idx;
- (void)insertHasSubs:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeHasSubsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInHasSubsAtIndex:(NSUInteger)idx withObject:(Subscription *)value;
- (void)replaceHasSubsAtIndexes:(NSIndexSet *)indexes withHasSubs:(NSArray *)values;
- (void)addHasSubsObject:(Subscription *)value;
- (void)removeHasSubsObject:(Subscription *)value;
- (void)addHasSubs:(NSOrderedSet *)values;
- (void)removeHasSubs:(NSOrderedSet *)values;
- (void)insertObject:(Topic *)value inHasTopicsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromHasTopicsAtIndex:(NSUInteger)idx;
- (void)insertHasTopics:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeHasTopicsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInHasTopicsAtIndex:(NSUInteger)idx withObject:(Topic *)value;
- (void)replaceHasTopicsAtIndexes:(NSIndexSet *)indexes withHasTopics:(NSArray *)values;
- (void)addHasTopicsObject:(Topic *)value;
- (void)removeHasTopicsObject:(Topic *)value;
- (void)addHasTopics:(NSOrderedSet *)values;
- (void)removeHasTopics:(NSOrderedSet *)values;
@end
