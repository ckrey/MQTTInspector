//
//  Session+Create.h
//  MQTTInspector
//
//  Created by Christoph Krey on 09.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "Session.h"

@interface Session (Create)
+ (Session *)existSessionWithName:(NSString *)name
           inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Session *)sessionWithName:(NSString *)name
                        host:(NSString *)host
                        port:(int)port
                         tls:(BOOL)tls
                        auth:(BOOL)auth
                        user:(NSString *)user
                      passwd:(NSString *)passwd
                    clientid:(NSString *)clientid
                cleansession:(BOOL)cleansession
                   keepalive:(int)keepalive
                 autoconnect:(BOOL)autoconnect
                      dnssrv:(BOOL)dnssrv
                   dnsdomain:(NSString *)dnsdomain
               protocolLevel:(UInt8)protocolLevel
             attributefilter:(NSString *)attributefilter
                 topicfilter:(NSString *)topicfilter
                  datafilter:(NSString *)datafilter
               includefilter:(BOOL)includefilter
                   sizelimit:(int)sizelimit
      inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)allSessions:(NSManagedObjectContext *)context;

@end
