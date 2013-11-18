//
// MQTTSession.h
// MQtt Client
// 
// Copyright (c) 2011, 2013, 2lemetry LLC
// 
// All rights reserved. This program and the accompanying materials
// are made available under the terms of the Eclipse Public License v1.0
// which accompanies this distribution, and is available at
// http://www.eclipse.org/legal/epl-v10.html
// 
// Contributors:
//    Kyle Roche - initial API and implementation and/or initial documentation
// 

#import <Foundation/Foundation.h>
#import "MQTTDecoder.h"
#import "MQTTEncoder.h"

typedef enum {
    MQTTSessionStatusCreated,
    MQTTSessionStatusConnecting,
    MQTTSessionStatusConnected,
    MQTTSessionStatusDisconnecting,
    MQTTSessionStatusClosed,
    MQTTSessionStatusError
} MQTTSessionStatus;

typedef enum {
    MQTTSessionEventConnected,
    MQTTSessionEventConnectionRefused,
    MQTTSessionEventConnectionClosed,
    MQTTSessionEventConnectionError,
    MQTTSessionEventProtocolError
} MQTTSessionEvent;

@class MQTTSession;

@protocol MQTTSessionDelegate <NSObject>

- (void)handleEvent:(MQTTSession *)session event:(MQTTSessionEvent)eventCode error:(NSError *)error;
- (void)newMessage:(MQTTSession *)session
              data:(NSData *)data
           onTopic:(NSString *)topic
               qos:(int)qos
          retained:(BOOL)retained
               mid:(unsigned int)mid;
- (void)messageDelivered:(MQTTSession *)session msgID:(UInt16)msgID;
- (void)sending:(int)type qos:(int)qos retained:(BOOL)retained duped:(BOOL)duped data:(NSData *)data;
- (void)received:(int)type qos:(int)qos retained:(BOOL)retained duped:(BOOL)duped data:(NSData *)data;

@end

@interface MQTTSession : NSObject <MQTTDecoderDelegate, MQTTEncoderDelegate>

@property (weak, nonatomic) id<MQTTSessionDelegate> delegate;

- (MQTTSession *)initWithClientId:(NSString *)clientId
                         userName:(NSString *)userName
                         password:(NSString *)password
                        keepAlive:(UInt16)keepAliveInterval
                     cleanSession:(BOOL)cleanSessionFlag
                             will:(BOOL)willFlag
                        willTopic:(NSString *)willTopic
                          willMsg:(NSData *)willMsg
                          willQoS:(UInt8)willQoS
                   willRetainFlag:(BOOL)willRetainFlag
                          runLoop:(NSRunLoop *)runLoop
                          forMode:(NSString *)runLoopMode;

- (void)connectToHost:(NSString*)host port:(UInt32)port usingSSL:(BOOL)usingSSL;
- (void)subscribeToTopic:(NSString*)topic atLevel:(UInt8)qosLevel;
- (void)unsubscribeTopic:(NSString*)theTopic;
- (UInt16)publishData:(NSData*)data onTopic:(NSString*)topic retain:(BOOL)retainFlag qos:(NSInteger)qos;
- (void)close;

@end
