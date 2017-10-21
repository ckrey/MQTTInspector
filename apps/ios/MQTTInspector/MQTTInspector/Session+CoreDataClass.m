//
//  Session+CoreDataClass.m
//  MQTTInspector
//
//  Created by Christoph Krey on 09.10.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//
//

#import "Session+CoreDataClass.h"

@implementation Session
+ (Session *)sessionWithName:(NSString *)name
      inManagedObjectContext:(NSManagedObjectContext *)context {
    Session *session = [Session existSessionWithName:name inManagedObjectContext:context];

    if (!session) {

        DDLogVerbose(@"insertNewObjectForEntityForName Session %@", name);
        session = [NSEntityDescription insertNewObjectForEntityForName:@"Session" inManagedObjectContext:context];

        session.name = name;
        session.host = name;
        session.port = @(1883);
        session.tls = @(false);
        session.allowUntrustedCertificates = @(NO);
        session.websocket = @(NO);
        session.auth = @(false);
        session.user = nil;
        session.passwd = nil;
        session.clientid = nil;
        session.cleansession = @(true);
        session.keepalive = @(60);
        session.autoconnect = @(false);
        session.protocolLevel = @(4);
        session.attributefilter = @".*";
        session.topicfilter = @".*";
        session.datafilter = @".*";
        session.includefilter = @(true);
        session.sizelimit = @(0);
        session.sessionExpiryInterval = nil;
        session.receiveMaximum = nil;
        session.maximumPacketSize = nil;
        session.topicAliasMaximum = nil;
        session.userProperties = nil;
        session.requestResponseInformatino = nil;
        session.requestProblemInformation = nil;
        session.authMethod = nil;
        session.authData = nil;

        session.state = @(-1);
    }

    return session;
}

+ (Session *)existSessionWithName:(NSString *)name
           inManagedObjectContext:(NSManagedObjectContext *)context {
    DDLogVerbose(@"existSessionWithName %@", name);

    Session *session = nil;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Session"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];

    NSError *error = nil;

    NSArray *matches = [context executeFetchRequest:request error:&error];

    if (!matches) {
        // handle error
    } else {
        if (matches.count) {
            session = matches.lastObject;
        }
    }

    return session;
}

+ (NSArray *)allSessions:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Session"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]];

    NSError *error = nil;

    NSArray *matches = [context executeFetchRequest:request error:&error];

    return matches;
}




@end
