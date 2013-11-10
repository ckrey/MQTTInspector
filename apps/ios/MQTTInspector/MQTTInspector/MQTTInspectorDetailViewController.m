//
//  MQTTInspectorDetailViewController.m
//  MQTTInspector
//
//  Created by Christoph Krey on 09.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "MQTTInspectorDetailViewController.h"

@interface MQTTInspectorDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *url;
@property (weak, nonatomic) IBOutlet UILabel *error;
@property (weak, nonatomic) IBOutlet UILabel *event;
@property (weak, nonatomic) IBOutlet UITableView *messages;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@property (strong, nonatomic) MQTTSession *mqttSession;
@end

@implementation MQTTInspectorDetailViewController

- (IBAction)connect:(UIButton *)sender {
    self.mqttSession = [[MQTTSession alloc] initWithClientId:self.session.clientid
                                                    userName:self.session.user
                                                    password:self.session.passwd
                                                   keepAlive:[self.session.keepalive intValue]
                                                cleanSession:[self.session.cleansession boolValue]
                                                        will:NO
                                                   willTopic:nil
                                                     willMsg:nil
                                                     willQoS:0
                                              willRetainFlag:NO
                                                     runLoop:[NSRunLoop currentRunLoop]
                                                     forMode:NSRunLoopCommonModes];
    self.mqttSession.delegate = self;

    [self.mqttSession connectToHost:self.session.host port:[self.session.port integerValue] usingSSL:[self.session.tls boolValue]];
}

- (IBAction)disconnect:(UIButton *)sender {
    [self.mqttSession close];
}
#pragma mark - Managing the detail item

- (void)setSession:(Session *)session
{
    _session = session;
    
    self.url.text = [session description];
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

#pragma mark - MQTTSessionDelegate
- (void)handleEvent:(MQTTSession *)session event:(MQTTSessionEvent)eventCode error:(NSError *)error
{
    const NSDictionary *events = @{
                                   @(MQTTSessionEventConnected): @"connected",
                                   @(MQTTSessionEventConnectionRefused): @"connection refused",
                                   @(MQTTSessionEventConnectionClosed): @"connection closed",
                                   @(MQTTSessionEventConnectionError): @"connection error",
                                   @(MQTTSessionEventProtocolError): @"protocoll error"
                                   };
        
    self.event.text = [NSString stringWithFormat:@"%@ (%d)",  events[@(eventCode)], eventCode];
    if (error) self.error.text = [error description];
}
- (void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic
{
    
}
- (void)messageDelivered:(MQTTSession *)session msgID:(UInt16)msgID
{
    
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Setup", @"Setup");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
