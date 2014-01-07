//
//  Session+Create.m
//  MQTTInspector
//
//  Created by Christoph Krey on 09.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "Session+Create.h"

@implementation Session (Create)

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
      inManagedObjectContext:(NSManagedObjectContext *)context;
{
    Session *session = [Session existSessionWithName:name inManagedObjectContext:context];
    
    if (!session) {
        
#ifdef DEBUG
        NSLog(@"insertNewObjectForEntityForName Session %@", name);
#endif

        session = [NSEntityDescription insertNewObjectForEntityForName:@"Session" inManagedObjectContext:context];
        
        session.name = name;
        session.host = host;
        session.port = @(port);
        session.tls = @(tls);
        session.auth = @(auth);
        session.user = user;
        session.passwd = passwd;
        session.clientid = clientid;
        session.cleansession = @(cleansession);
        session.keepalive = @(keepalive);
        session.autoconnect = @(autoconnect);
        session.dnssrv = @(dnssrv);
        session.dnsdomain = dnsdomain;
        session.state = @(-1);
    }
    
    return session;
}

+ (Session *)existSessionWithName:(NSString *)name
           inManagedObjectContext:(NSManagedObjectContext *)context
{
#ifdef DEBUG
    NSLog(@"existSessionWithName %@", name);
#endif

    Session *session = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Session"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    
    NSError *error = nil;
    
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        // handle error
    } else {
        if ([matches count]) {
            session = [matches lastObject];
            session.state = @(-1);
        }
    }
    
    return session;
}

+ (NSArray *)allSessions:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Session"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]];
    
    NSError *error = nil;
    
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    return matches;
}



@end
