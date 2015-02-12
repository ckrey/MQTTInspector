//
//  MQTTInspectorAppDelegate.m
//  MQTTInspector
//
//  Created by Christoph Krey on 09.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "MQTTInspectorAppDelegate.h"
#import "MQTTInspectorMasterViewController.h"
#import "Session+Create.h"
#import "Subscription+Create.h"
#import "Publication+Create.h"

@interface MQTTInspectorAppDelegate ()
@property (nonatomic) UIBackgroundTaskIdentifier bgTask;
@end

@implementation MQTTInspectorAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunchingWithOptions");

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        
        UINavigationController *masterNavigationController = splitViewController.viewControllers[0];
        MQTTInspectorMasterViewController *controller = (MQTTInspectorMasterViewController *)masterNavigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;

        UINavigationController *detailNavigationController = [splitViewController.viewControllers lastObject];
        MQTTInspectorDetailViewController *detailController = (MQTTInspectorDetailViewController *)detailNavigationController.topViewController;
        controller.detailViewController = detailController;
    } else {
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        MQTTInspectorMasterViewController *controller = (MQTTInspectorMasterViewController *)navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
    }
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"applicationWillResignActive");

    [self saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"applicationDidEnterBackground");

    self.bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^
                           {
                               NSLog(@"BackgroundTaskExpirationHandler");
                               
                               [self connectionClosed];
                           }];
}

- (void)connectionClosed
{
    NSLog(@"connectionClosed");
    
    if (self.bgTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"applicationWillTerminate");

    [self saveContext];
}

- (void)saveContext
{
    NSLog(@"saveContext");

    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MQTTInspector" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MQTTInspector.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                             NSInferMappingModelAutomaticallyOption: @YES};

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
#ifdef DEBUG
    NSLog(@"UIApplication openURL:%@ sourceApplication:%@ annotation:%@", url, sourceApplication, annotation);
#endif
    
    if (url) {
        NSError *error;
        NSInputStream *input = [NSInputStream inputStreamWithURL:url];
        if ([input streamError]) {
            NSLog(@"Error nputStreamWithURL %@ %@", [input streamError], url);
            return FALSE;
        }
        [input open];
        if ([input streamError]) {
            NSLog(@"Error open %@ %@", [input streamError], url);
            return FALSE;
        }
        
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithStream:input options:0 error:&error];
        if (dictionary) {
            for (NSString *key in [dictionary allKeys]) {
                NSLog(@"Init %@:%@", key, dictionary[key]);
            }
            
            if ([dictionary[@"_type"] isEqualToString:@"MQTTInspector-Session"]) {
                NSString *name = dictionary[@"name"];
                Session *session = [Session existSessionWithName:name
                                          inManagedObjectContext:_managedObjectContext];
                if (!session) {
                    session = [Session sessionWithName:name
                                                  host:@"host"
                                                  port:1883
                                                   tls:NO
                                                  auth:NO
                                                  user:@""
                                                passwd:@""
                                              clientid:@""
                                          cleansession:YES
                                             keepalive:60
                                           autoconnect:NO
                                                dnssrv:NO
                                             dnsdomain:@""
                                         protocolLevel:4
                                       attributefilter:@""
                                           topicfilter:@""
                                            datafilter:@""
                                         includefilter:YES
                                             sizelimit:0
                                inManagedObjectContext:_managedObjectContext];
                }
                
                NSString *string;
                string = dictionary[@"host"];
                if (string) session.host = string;
                
                string = dictionary[@"port"];
                if (string) session.port = @([string integerValue]);
                
                string = dictionary[@"tls"];
                if (string) session.tls = @([string boolValue]);
                
                string = dictionary[@"auth"];
                if (string) session.auth = @([string boolValue]);
                
                string = dictionary[@"user"];
                if (string) session.user = string;
                
                string = dictionary[@"passwd"];
                if (string) session.passwd = string;
                
                string = dictionary[@"clientid"];
                if (string) session.clientid = string;
                
                string = dictionary[@"cleansession"];
                if (string) session.cleansession = @([string boolValue]);
                
                string = dictionary[@"keepalive"];
                if (string) session.keepalive = @([string integerValue]);
                
                string = dictionary[@"autoconnect"];
                if (string) session.autoconnect = @([string boolValue]);
                
                string = dictionary[@"dnssrv"];
                if (string) session.dnssrv = @([string boolValue]);
                
                string = dictionary[@"dnsdomain"];
                if (string) session.dnsdomain = string;
                
                string = dictionary[@"protocollevel"];
                if (string) session.protocolLevel = @([string integerValue]);
                
                string = dictionary[@"sizelimit"];
                if (string) session.sizelimit = @([string integerValue]);
                
                string = dictionary[@"includefilter"];
                if (string) session.includefilter = @([string boolValue]);
                
                string = dictionary[@"attributefilter"];
                if (string) session.attributefilter = string;
                
                string = dictionary[@"datafilter"];
                if (string) session.datafilter = string;
                
                string = dictionary[@"topicfilter"];
                if (string) session.topicfilter = string;

                NSArray *subs = dictionary[@"subs"];
                if (subs) for (NSDictionary *subDict in subs) {
                    NSString *topic = subDict[@"topic"];
                    Subscription *sub = [Subscription existsSubscriptionWithTopic:topic
                                                                          session:session
                                                           inManagedObjectContext:_managedObjectContext];
                    if (!sub) {
                        sub = [Subscription subscriptionWithTopic:topic
                                                              qos:0
                                                          session:session
                                           inManagedObjectContext:_managedObjectContext];
                    }
                    string = subDict[@"qos"];
                    if (string) sub.qos = @([string integerValue]);
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
                    if (string) pub.qos = @([string integerValue]);

                    string = pubDict[@"retained"];
                    if (string) pub.retained = @([string boolValue]);

                    NSData *data = pubDict[@"data"];
                    if (string) pub.data = data;
                }
            } else {
                NSLog(@"Error invalid init file %@)", dictionary[@"_type"]);
                return FALSE;
            }
        } else {
            NSLog(@"Error illegal json in init file %@)", error);
            return FALSE;
        }
        
        NSLog(@"Init file %@ successfully processed)", [url lastPathComponent]);
        
    }
    [self saveContext];
    return TRUE;
}

@end
