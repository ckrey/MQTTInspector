//
//  AppDelegate.m
//  MQTTInspector
//
//  Created by Christoph Krey on 09.11.13.
//  Copyright © 2013-2017 Christoph Krey. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterVC.h"

#import "Model.h"

@interface AppDelegate ()
@property (nonatomic) UIBackgroundTaskIdentifier bgTask;
@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:ddLogLevel];
    DDLogVerbose(@"didFinishLaunchingWithOptions");
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:TRUE];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    DDLogVerbose(@"applicationDidBecomeActive");
    [[UIApplication sharedApplication] setIdleTimerDisabled:TRUE];

}

- (void)applicationWillResignActive:(UIApplication *)application {
    DDLogVerbose(@"applicationWillResignActive");
    [self saveContext];
    [[UIApplication sharedApplication] setIdleTimerDisabled:FALSE];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    DDLogVerbose(@"applicationDidEnterBackground");

    self.bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^
                           {
                               DDLogVerbose(@"BackgroundTaskExpirationHandler");
                               [self connectionClosed];
                           }];
}

- (void)connectionClosed {
    DDLogVerbose(@"connectionClosed");
    
    if (self.bgTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    DDLogVerbose(@"applicationWillTerminate");
    [self saveContext];
}

- (void)saveContext {
    DDLogVerbose(@"saveContext");

    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if (managedObjectContext.hasChanges && ![managedObjectContext save:&error]) {
            DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _managedObjectContext.persistentStoreCoordinator = coordinator;
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MQTTInspector" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [self.applicationDocumentsDirectory URLByAppendingPathComponent:@"MQTTInspector.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                             NSInferMappingModelAutomaticallyOption: @YES};

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory {
    return [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    DDLogVerbose(@"UIApplication openURL:%@ sourceApplication:%@ annotation:%@",
                 url, sourceApplication, annotation);
    
    if (url && [url.scheme isEqualToString:@"file"]) {

        NSError *error;
        NSInputStream *input = [NSInputStream inputStreamWithURL:url];
        if (input.streamError) {
            DDLogError(@"Error inputStreamWithURL %@ %@", [input streamError], url);
            return FALSE;
        }
        [input open];
        if (input.streamError) {
            DDLogError(@"Error open %@ %@", [input streamError], url);
            return FALSE;
        }

        DDLogVerbose(@"[OwnTracksAppDelegate] URL pathExtension %@", url.pathExtension);

        if ([url.pathExtension isEqualToString:@"mqti"]) {
            [self processMQTI:input url:url];
        } else if ([url.pathExtension isEqualToString:@"mqtc"]) {
            NSURL *directoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                         inDomain:NSUserDomainMask
                                                                appropriateForURL:nil
                                                                           create:YES
                                                                            error:&error];
            NSString *fileName = url.lastPathComponent;
            NSURL *fileURL = [directoryURL URLByAppendingPathComponent:fileName];
            [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
            [[NSFileManager defaultManager] copyItemAtURL:url toURL:fileURL error:nil];
        } else {
            //
        }

        [input close];
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    }
    return TRUE;
}

- (BOOL)processMQTI:(NSInputStream *)input url:(NSURL *)url {
    NSError *error;

    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithStream:input
                                                                 options:0
                                                                   error:&error];
    if (dictionary) {
        for (NSString *key in dictionary.allKeys) {
            DDLogVerbose(@"Init %@:%@", key, dictionary[key]);
        }

        if ([dictionary[@"_type"] isEqualToString:@"MQTTInspector-Session"] &&
            dictionary[@"name"]) {
            NSString *name = dictionary[@"name"];
            Session *session = [Session existSessionWithName:name
                                      inManagedObjectContext:_managedObjectContext];
            if (!session) {
                session = [Session sessionWithName:name
                            inManagedObjectContext:_managedObjectContext];
            }

            NSString *string;
            string = dictionary[@"host"];
            if (string) session.host = string;

            string = dictionary[@"port"];
            if (string) session.port = @(string.integerValue);

            string = dictionary[@"tls"];
            if (string) session.tls = @(string.boolValue);

            string = dictionary[@"auth"];
            if (string) session.auth = @(string.boolValue);

            string = dictionary[@"user"];
            if (string) session.user = string;

            string = dictionary[@"passwd"];
            if (string) session.passwd = string;

            string = dictionary[@"pkcsfile"];
            if (string) session.pkcsfile = string;

            string = dictionary[@"pkcspassword"];
            if (string) session.pkcspassword = string;

            string = dictionary[@"clientid"];
            if (string) session.clientid = string;

            string = dictionary[@"cleansession"];
            if (string) session.cleansession = @(string.boolValue);

            string = dictionary[@"keepalive"];
            if (string) session.keepalive = @(string.integerValue);

            string = dictionary[@"autoconnect"];
            if (string) session.autoconnect = @(string.boolValue);

            string = dictionary[@"websocket"];
            if (string) session.websocket = @(string.boolValue);

            string = dictionary[@"allowUntrustedCertificates"];
            if (string) session.allowUntrustedCertificates = @(string.boolValue);

            string = dictionary[@"protocollevel"];
            if (string) session.protocolLevel = @(string.integerValue);

            string = dictionary[@"sizelimit"];
            if (string) session.sizelimit = @(string.integerValue);

            string = dictionary[@"includefilter"];
            if (string) session.includefilter = @(string.boolValue);

            string = dictionary[@"attributefilter"];
            if (string) session.attributefilter = string;

            string = dictionary[@"datafilter"];
            if (string) session.datafilter = string;

            string = dictionary[@"topicfilter"];
            if (string) session.topicfilter = string;

            string = dictionary[@"sessionExpiryInterval"];
            if (string) session.sessionExpiryInterval = @(string.integerValue);

            string = dictionary[@"receiveMaximum"];
            if (string) session.receiveMaximum = @(string.integerValue);

            string = dictionary[@"maximumPacketSize"];
            if (string) session.maximumPacketSize = @(string.integerValue);

            string = dictionary[@"topicAliasMaximum"];
            if (string) session.topicAliasMaximum = @(string.integerValue);

            string = dictionary[@"authMethod"];
            if (string) session.authMethod = string;

            string = dictionary[@"authData"];
            if (string) session.authData = [string dataUsingEncoding:NSUTF8StringEncoding];

            string = dictionary[@"requestProblemInformation"];
            if (string) session.requestProblemInformation = @(string.boolValue);

            string = dictionary[@"requestResponseInformation"];
            if (string) session.requestResponseInformatino = @(string.boolValue);


            NSArray *subs = dictionary[@"subs"];
            if (subs) for (NSDictionary *subDict in subs) {
                NSString *name = subDict[@"name"];
                if (name.length == 0) {
                    name = subDict[@"topic"];
                }

                Subscription *sub = [Subscription existsSubscriptionWithName:name
                                                                     session:session
                                                      inManagedObjectContext:_managedObjectContext];
                if (!sub) {
                    sub = [Subscription subscriptionWithName:name
                                                       topic:name
                                                         qos:0
                                                     noLocal:false
                                           retainAsPublished:false
                                              retainHandling:MQTTSendRetained
                                      subscriptionIdentifier:0
                                                     session:session
                                      inManagedObjectContext:_managedObjectContext];
                }
                string = subDict[@"topic"];
                if (string) sub.topic = string;
                string = subDict[@"qos"];
                if (string) sub.qos = @(string.integerValue);
                string = subDict[@"noLocal"];
                if (string) sub.noLocal = @(string.boolValue);
                string = subDict[@"retainAsPublished"];
                if (string) sub.retainAsPublished = @(string.boolValue);
                string = subDict[@"retainHandling"];
                if (string) sub.retainHandling = @(string.integerValue);
                string = subDict[@"subscriptionIdentifier"];
                if (string) sub.susbscriptionIdentifier = @(string.integerValue);
            }

            NSArray *pubs = dictionary[@"pubs"];
            if (pubs) for (NSDictionary *pubDict in pubs) {
                NSString *name = pubDict[@"name"];
                Publication *pub = [Publication existsPublicationWithName:name
                                                                  session:session
                                                   inManagedObjectContext:_managedObjectContext];
                if (!pub) {
                    pub = [Publication publicationWithName:name
                                                     topic:@"topic"
                                                       qos:0
                                                  retained:NO
                                                      data:[[NSData alloc] init]
                                                   session:session
                                    inManagedObjectContext:_managedObjectContext];
                }
                string = pubDict[@"topic"];
                if (string) pub.topic = string;

                string = pubDict[@"qos"];
                if (string) pub.qos = @(string.integerValue);

                string = pubDict[@"retained"];
                if (string) pub.retained = @(string.boolValue);

                NSData *data = pubDict[@"data"];
                if (string) pub.data = data;
            }

            NSArray *userProperties = dictionary[@"userProperties"];
            if (userProperties && [NSJSONSerialization isValidJSONObject:userProperties]) {
                session.userProperties = [NSJSONSerialization dataWithJSONObject:userProperties
                                                                         options:0
                                                                           error:nil];
            }
        } else {
            DDLogError(@"Error invalid init file %@ name %@)",
                       dictionary[@"_type"],
                       dictionary[@"name"]
                       );
            return FALSE;
        }
    } else {
        DDLogError(@"Error illegal json in init file %@)", error);
        return FALSE;
    }

    DDLogError(@"Init file %@ successfully processed)", [url lastPathComponent]);

    [self saveContext];
    return TRUE;
}

@end
