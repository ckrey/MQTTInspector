//
//  Session.h
//  MQTTInspector
//
//  Created by Christoph Krey on 09.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Message;

@interface Session : NSManagedObject

@property (nonatomic, retain) NSString * host;
@property (nonatomic, retain) NSNumber * port;
@property (nonatomic, retain) NSNumber * tls;
@property (nonatomic, retain) NSNumber * auth;
@property (nonatomic, retain) NSString * user;
@property (nonatomic, retain) NSString * passwd;
@property (nonatomic, retain) NSString * clientid;
@property (nonatomic, retain) NSNumber * cleansession;
@property (nonatomic, retain) NSNumber * keepalive;
@property (nonatomic, retain) Message *hasMesssages;

@end
