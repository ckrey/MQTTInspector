//
//  MQTTInspectorAppDelegate.h
//  MQTTInspector
//
//  Created by Christoph Krey on 05.12.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MQTTInspectorAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
