//
//  Session+Create.h
//  MQTTInspector
//
//  Created by Christoph Krey on 09.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "Session.h"

@interface Session (Create)
+ (Session *)sessionWithHost:(NSString *)host
                         port:(int)port
                          tls:(BOOL)tls
                         auth:(BOOL)auth
                         user:(NSString *)user
                       passwd:(NSString *)passwd
                     clientid:(NSString *)clientid
                 cleansession:(BOOL)cleansession
                    keepalive:(int)keepalive
       inManagedObjectContext:(NSManagedObjectContext *)context;

@end
