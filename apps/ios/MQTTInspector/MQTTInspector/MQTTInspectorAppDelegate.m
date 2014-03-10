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

    // Override point for customization after application launch.
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
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"applicationWillResignActive");

    [self saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"applicationWillEnterForeground");

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"applicationDidBecomeActive");

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
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
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
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

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MQTTInspector" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MQTTInspector.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             nil];

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
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
                                         protocolLevel:3
                                       attributefilter:@""
                                           topicfilter:@""
                                            datafilter:@""
                                         includefilter:YES
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
