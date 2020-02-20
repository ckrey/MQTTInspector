//
//  Session+CoreDataProperties.h
//  MQTTInspector
//
//  Created by Christoph Krey on 09.04.18.
//  Copyright © 2018-2020 Christoph Krey. All rights reserved.
//
//

#import "Session+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Session (CoreDataProperties)

+ (NSFetchRequest<Session *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *allowUntrustedCertificates;
@property (nullable, nonatomic, copy) NSString *attributefilter;
@property (nullable, nonatomic, copy) NSNumber *auth;
@property (nullable, nonatomic, retain) NSData *authData;
@property (nullable, nonatomic, copy) NSString *authMethod;
@property (nullable, nonatomic, copy) NSNumber *autoconnect;
@property (nullable, nonatomic, copy) NSNumber *cleansession;
@property (nullable, nonatomic, copy) NSString *clientid;
@property (nullable, nonatomic, copy) NSString *datafilter;
@property (nullable, nonatomic, copy) NSString *host;
@property (nullable, nonatomic, copy) NSNumber *includefilter;
@property (nullable, nonatomic, copy) NSNumber *keepalive;
@property (nullable, nonatomic, copy) NSNumber *maximumPacketSize;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *passwd;
@property (nullable, nonatomic, copy) NSNumber *port;
@property (nullable, nonatomic, copy) NSNumber *protocolLevel;
@property (nullable, nonatomic, copy) NSNumber *receiveMaximum;
@property (nullable, nonatomic, copy) NSNumber *requestProblemInformation;
@property (nullable, nonatomic, copy) NSNumber *requestResponseInformatino;
@property (nullable, nonatomic, copy) NSNumber *sessionExpiryInterval;
@property (nullable, nonatomic, copy) NSNumber *sizelimit;
@property (nullable, nonatomic, copy) NSNumber *state;
@property (nullable, nonatomic, copy) NSNumber *tls;
@property (nullable, nonatomic, copy) NSNumber *topicAliasMaximum;
@property (nullable, nonatomic, copy) NSString *topicfilter;
@property (nullable, nonatomic, copy) NSString *user;
@property (nullable, nonatomic, retain) NSData *userProperties;
@property (nullable, nonatomic, copy) NSNumber *websocket;
@property (nullable, nonatomic, copy) NSString *pkcsfile;
@property (nullable, nonatomic, copy) NSString *pkcspassword;
@property (nullable, nonatomic, retain) NSOrderedSet<Command *> *hasCommands;
@property (nullable, nonatomic, retain) NSOrderedSet<Message *> *hasMesssages;
@property (nullable, nonatomic, retain) NSOrderedSet<Publication *> *hasPubs;
@property (nullable, nonatomic, retain) NSOrderedSet<Subscription *> *hasSubs;
@property (nullable, nonatomic, retain) NSOrderedSet<Topic *> *hasTopics;

@end

@interface Session (CoreDataGeneratedAccessors)

- (void)insertObject:(Command *)value inHasCommandsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromHasCommandsAtIndex:(NSUInteger)idx;
- (void)insertHasCommands:(NSArray<Command *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeHasCommandsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInHasCommandsAtIndex:(NSUInteger)idx withObject:(Command *)value;
- (void)replaceHasCommandsAtIndexes:(NSIndexSet *)indexes withHasCommands:(NSArray<Command *> *)values;
- (void)addHasCommandsObject:(Command *)value;
- (void)removeHasCommandsObject:(Command *)value;
- (void)addHasCommands:(NSOrderedSet<Command *> *)values;
- (void)removeHasCommands:(NSOrderedSet<Command *> *)values;

- (void)insertObject:(Message *)value inHasMesssagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromHasMesssagesAtIndex:(NSUInteger)idx;
- (void)insertHasMesssages:(NSArray<Message *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeHasMesssagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInHasMesssagesAtIndex:(NSUInteger)idx withObject:(Message *)value;
- (void)replaceHasMesssagesAtIndexes:(NSIndexSet *)indexes withHasMesssages:(NSArray<Message *> *)values;
- (void)addHasMesssagesObject:(Message *)value;
- (void)removeHasMesssagesObject:(Message *)value;
- (void)addHasMesssages:(NSOrderedSet<Message *> *)values;
- (void)removeHasMesssages:(NSOrderedSet<Message *> *)values;

- (void)insertObject:(Publication *)value inHasPubsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromHasPubsAtIndex:(NSUInteger)idx;
- (void)insertHasPubs:(NSArray<Publication *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeHasPubsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInHasPubsAtIndex:(NSUInteger)idx withObject:(Publication *)value;
- (void)replaceHasPubsAtIndexes:(NSIndexSet *)indexes withHasPubs:(NSArray<Publication *> *)values;
- (void)addHasPubsObject:(Publication *)value;
- (void)removeHasPubsObject:(Publication *)value;
- (void)addHasPubs:(NSOrderedSet<Publication *> *)values;
- (void)removeHasPubs:(NSOrderedSet<Publication *> *)values;

- (void)insertObject:(Subscription *)value inHasSubsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromHasSubsAtIndex:(NSUInteger)idx;
- (void)insertHasSubs:(NSArray<Subscription *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeHasSubsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInHasSubsAtIndex:(NSUInteger)idx withObject:(Subscription *)value;
- (void)replaceHasSubsAtIndexes:(NSIndexSet *)indexes withHasSubs:(NSArray<Subscription *> *)values;
- (void)addHasSubsObject:(Subscription *)value;
- (void)removeHasSubsObject:(Subscription *)value;
- (void)addHasSubs:(NSOrderedSet<Subscription *> *)values;
- (void)removeHasSubs:(NSOrderedSet<Subscription *> *)values;

- (void)insertObject:(Topic *)value inHasTopicsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromHasTopicsAtIndex:(NSUInteger)idx;
- (void)insertHasTopics:(NSArray<Topic *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeHasTopicsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInHasTopicsAtIndex:(NSUInteger)idx withObject:(Topic *)value;
- (void)replaceHasTopicsAtIndexes:(NSIndexSet *)indexes withHasTopics:(NSArray<Topic *> *)values;
- (void)addHasTopicsObject:(Topic *)value;
- (void)removeHasTopicsObject:(Topic *)value;
- (void)addHasTopics:(NSOrderedSet<Topic *> *)values;
- (void)removeHasTopics:(NSOrderedSet<Topic *> *)values;

@end

NS_ASSUME_NONNULL_END
