//
//  MQTTInspectorDetailViewController.m
//  MQTTInspector
//
//  Created by Christoph Krey on 09.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "MQTTInspectorDetailViewController.h"
#import "Message+Create.h"
#import "Topic+Create.h"
#import "Command+Create.h"
#import "Subscription+Create.h"
#import "Publication+Create.h"
#import "MQTTInspectorLogsTableViewController.h"
#import "MQTTInspectorTopicsTableViewController.h"
#import "MQTTInspectorCommandsTableViewController.h"
#import "MQTTInspectorSubsTableViewController.h"
#import "MQTTInspectorPubsTableViewController.h"
#import "MQTTInspectorDataViewController.h"
#import "MQTTInspectorSetupPubsTableViewController.h"
#import "MQTTInspectorSetupSubsTableViewController.h"

@interface MQTTInspectorDetailViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *disconnectButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *connectButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *clearButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *pubButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UITableView *messages;
@property (weak, nonatomic) IBOutlet UITableView *subs;
@property (weak, nonatomic) IBOutlet UITableView *pubs;
@property (weak, nonatomic) IBOutlet UISegmentedControl *level;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (weak, nonatomic) IBOutlet UISwitch *runningSwitch;

@property (strong, nonatomic) MQTTInspectorLogsTableViewController *logsTVC;
@property (strong, nonatomic) MQTTInspectorTopicsTableViewController *topicsTVC;
@property (strong, nonatomic) MQTTInspectorCommandsTableViewController *commandsTVC;
@property (strong, nonatomic) MQTTInspectorSubsTableViewController *subsTVC;
@property (strong, nonatomic) MQTTInspectorPubsTableViewController *pubsTVC;

@property (strong, nonatomic) UIAlertView *alertView;
@property (strong, nonatomic) NSManagedObjectContext *queueManagedObjectContext;
@property (nonatomic) float queueIn;
@property (nonatomic) float queueOut;
@property (strong, nonatomic) SRVResolver *resolver;
@property (strong, nonatomic) NSMutableArray *resolverResults;

@end

@implementation MQTTInspectorDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self viewChanged:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /* start with organizer if no session selected */
    if (!self.session) {
        [self.masterPopoverController presentPopoverFromBarButtonItem:self.navigationController.navigationItem.backBarButtonItem permittedArrowDirections:(UIPopoverArrowDirectionAny) animated:TRUE];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"setSession:"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setMother:)]) {
            [segue.destinationViewController performSelector:@selector(setMother:)
                                                  withObject:self];
        }
    }
    if ([segue.identifier isEqualToString:@"enlargePubs"] ||
        [segue.identifier isEqualToString:@"enlargeSubs"]) {
        
        if (segue.sourceViewController == self) {
            if ([segue.destinationViewController respondsToSelector:@selector(setSession:)]) {
                [segue.destinationViewController performSelector:@selector(setSession:)
                                                      withObject:self.session];
            }
        }
    }


    NSIndexPath *indexPath = nil;
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        if (self.logsTVC) {
            indexPath = [self.logsTVC.tableView indexPathForCell:sender];
        }
        if (self.topicsTVC) {
            indexPath = [self.topicsTVC.tableView indexPathForCell:sender];
        }
        if (self.commandsTVC) {
            indexPath = [self.commandsTVC.tableView indexPathForCell:sender];
        }
    }
    
    if (indexPath) {
        if ([segue.identifier isEqualToString:@"setMessage:"]) {
            NSData *theData;
            NSString *theTopic;
            
            if (self.logsTVC) {
                Message *message = [[self.logsTVC fetchedResultsController] objectAtIndexPath:indexPath];
                theData = message.data;
                theTopic = message.topic;
            }
            if (self.topicsTVC) {
                Topic *topic = [[self.topicsTVC fetchedResultsController] objectAtIndexPath:indexPath];
                theData = topic.data;
                theTopic = topic.topic;
            }
            if (self.commandsTVC) {
                Command *command = [[self.commandsTVC fetchedResultsController] objectAtIndexPath:indexPath];
                theData = command.data;
                theTopic = [NSDateFormatter localizedStringFromDate:command.timestamp
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterMediumStyle];
            }


            if ([segue.destinationViewController respondsToSelector:@selector(setTopic:)]) {
                [segue.destinationViewController performSelector:@selector(setTopic:)
                                                      withObject:theTopic];
            }
            if ([segue.destinationViewController respondsToSelector:@selector(setData:)]) {
                [segue.destinationViewController performSelector:@selector(setData:)
                                                      withObject:theData];
            }
        }
    }
}

- (void)publish:(Publication *)pub
{
    NSString *string = [MQTTInspectorDataViewController dataToString:pub.data];
    
    // REPLACE %t with timeIntervalSince1970
    NSString *nowString = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
    string = [string stringByReplacingOccurrencesOfString:@"%t" withString:nowString];
    
    // REPLACE %c with effective clientId
    NSString *clientId;
    if ((!pub.belongsTo.clientid) || ([pub.belongsTo.clientid isEqualToString:@""])) {
        clientId = [NSString stringWithFormat:@"MQTTInspector-%d", getpid()];
    } else {
        clientId = pub.belongsTo.clientid;
    }
    string = [string stringByReplacingOccurrencesOfString:@"%c" withString:clientId];
    
    [self.mqttSession publishData:[string dataUsingEncoding:NSUTF8StringEncoding]
                                 onTopic:pub.topic
                                  retain:[pub.retained boolValue]
                                     qos:[pub.qos intValue]];
}


- (NSString *)effectiveClientId
{
    NSString *clientId;
    if ((!self.session.clientid) || ([self.session.clientid isEqualToString:@""])) {
        clientId = [NSString stringWithFormat:@"MQTTInspector-%d", getpid()];
    } else {
        clientId = self.session.clientid;
    }
    return clientId;
}

- (IBAction)runningChanged:(UISwitch *)sender {
    //
}

- (IBAction)connect:(UIBarButtonItem *)sender {
    if (self.session) {
        
        self.title = [NSString stringWithFormat:@"%@ - %@", self.session.name, [self url]];

        self.mqttSession = [[MQTTSession alloc] initWithClientId:[self effectiveClientId]
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
        
        if ([self.session.cleansession boolValue]) {
            for (Subscription *sub in self.session.hasSubs) {
                 sub.state = @(0);
            }
        }
        
        [self.mqttSession connectToHost:self.session.host port:[self.session.port intValue] usingSSL:[self.session.tls boolValue]];
    }
}
- (IBAction)disconnect:(UIBarButtonItem *)sender {
    if (self.session) {
        self.title = self.session.name;
        [self.mqttSession close];
    }
}

- (IBAction)viewChanged:(UISegmentedControl *)sender {
    if (self.session) {
        [self.logsTVC dismissViewControllerAnimated:YES completion:nil];
        self.logsTVC = nil;
        [self.topicsTVC dismissViewControllerAnimated:YES completion:nil];
        self.topicsTVC = nil;
        [self.commandsTVC dismissViewControllerAnimated:YES completion:nil];
        self.commandsTVC = nil;
        switch (self.level.selectedSegmentIndex) {
            case 2:
                self.commandsTVC = [[MQTTInspectorCommandsTableViewController alloc] init];
                self.commandsTVC.mother = self;
                self.commandsTVC.tableView = self.messages;
                break;
            case 1:
                self.logsTVC = [[MQTTInspectorLogsTableViewController alloc] init];
                self.logsTVC.mother = self;
                self.logsTVC.tableView = self.messages;
                break;
            case 0:
            default:
                self.topicsTVC = [[MQTTInspectorTopicsTableViewController alloc] init];
                self.topicsTVC.mother = self;
                self.topicsTVC.tableView = self.messages;
                break;
        }
    }
}
- (IBAction)clear:(UIBarButtonItem *)sender {
    if (self.session) {
        for (Message *message in self.session.hasMesssages) {
            [self.managedObjectContext deleteObject:message];
        }
        for (Topic *topic in self.session.hasTopics) {
            [self.managedObjectContext deleteObject:topic];
        }
        for (Command *command in self.session.hasCommands) {
            [self.managedObjectContext deleteObject:command];
        }
    }
}

#pragma mark - Managing the detail item
- (void)setSession:(Session *)session
{
    self.managedObjectContext = session.managedObjectContext;
    
    self.title = session.name;
    
    if ((_session != session) || ([self.session.state intValue] != MQTTSessionEventConnected)) {
        if (_session) {
            if (self.mqttSession)
            {
                [self.mqttSession close];
            }
        }
        _session = session;
        
        self.clearButton.enabled = TRUE;
        self.level.enabled = TRUE;
        self.connectButton.enabled = TRUE;

        self.subsTVC = nil;
        UITableViewController *stvc = [[UITableViewController alloc] init];
        stvc.tableView = self.subs;
        [stvc.tableView reloadData];
        
        self.pubsTVC = nil;
        UITableViewController *ptvc = [[UITableViewController alloc] init];
        ptvc.tableView = self.pubs;
        [ptvc.tableView reloadData];

        [self viewChanged:nil];
        
        [self connect:nil];
//        [self performSelector:@selector(connect:) withObject:nil afterDelay:1];
        
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
        
}

#pragma mark - MQTTSessionDelegate
- (void)handleEvent:(MQTTSession *)session event:(MQTTSessionEvent)eventCode error:(NSError *)error
{
    if (session != self.mqttSession) {
#ifdef DEBUG
        NSLog(@"handle Event: old Session");
#endif
        return;
    }
    
#ifdef DEBUG
    NSLog(@"handleEvent: %d %@", eventCode, [error description]);
#endif
    self.session.state = @(eventCode);
    if ([self.session.state intValue] == MQTTSessionEventConnected) {
        self.subsTVC = [[MQTTInspectorSubsTableViewController alloc] init];
        self.subsTVC.mother = self;
        self.subsTVC.tableView = self.subs;
        
        self.pubsTVC = [[MQTTInspectorPubsTableViewController alloc] init];
        self.pubsTVC.mother = self;
        self.pubsTVC.tableView = self.pubs;
        
        self.connectButton.enabled = FALSE;
        self.disconnectButton.enabled = TRUE;
        self.pubButton.enabled = TRUE;
    } else {
        self.subsTVC = nil;
        UITableViewController *stvc = [[UITableViewController alloc] init];
        stvc.tableView = self.subs;
        [stvc.tableView reloadData];

        self.pubsTVC = nil;
        UITableViewController *ptvc = [[UITableViewController alloc] init];
        ptvc.tableView = self.pubs;
        [ptvc.tableView reloadData];
        
        self.connectButton.enabled = TRUE;
        self.disconnectButton.enabled = FALSE;
        self.pubButton.enabled = FALSE;
    }
    if (error) {
        [MQTTInspectorDetailViewController alert:[error description]];
    }
}

#define MAX_LOG 512
#define MAX_TOPIC 256
#define MAX_COMMAND 1024

- (NSManagedObjectContext *)queueManagedObjectContext
{
    if (!_queueManagedObjectContext) {
        _queueManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_queueManagedObjectContext setParentContext:self.managedObjectContext];
    }
    return _queueManagedObjectContext;
}
- (void)startQueue
{
    self.queueIn += 1;
    [self.progress setProgress:self.queueOut/self.queueIn animated:YES];
}

- (void)finishQueue
{
    while (!self.runningSwitch.on) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    }
    [self performSelectorOnMainThread:@selector(showQueue) withObject:nil waitUntilDone:NO];
}

- (void)showQueue
{
    self.queueOut += 1;
    if (self.queueIn == self.queueOut) {
        self.queueIn = 1;
        self.queueOut = 1;
    }
    [self.progress setProgress:self.queueOut/self.queueIn animated:YES];
}

- (void)limit:(NSArray *)array max:(int)max
{
#ifdef DEBUG
    NSLog(@"#count %lu/%d", (unsigned long)[array count], max);
#endif
    
    for (NSInteger i = [array count]; i > max; i--) {
        NSManagedObject *object = array[i - 1];
#ifdef DEBUG
        NSLog(@"delete %@", object);
#endif
        [object.managedObjectContext deleteObject:object];
    }
}

- (void)newMessage:(MQTTSession *)session
              data:(NSData *)data
           onTopic:(NSString *)topic
               qos:(int)qos
          retained:(BOOL)retained
               mid:(unsigned int)mid
{
    NSDate *timestamp = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *name = self.session.name;
    NSString *host = self.session.host;
    int port = [self.session.port intValue];
    BOOL tls = [self.session.tls boolValue];
    BOOL auth = [self.session.auth boolValue];
    NSString *user = self.session.user;
    NSString *passwd = self.session.passwd;
    NSString *clientid = self.session.clientid;
    BOOL cleansession = [self.session.cleansession boolValue];
    int keepalive = [self.session.keepalive intValue];
    NSString *dnsdomain = self.session.dnsdomain;
    BOOL dnssrv = [self.session.dnssrv boolValue];

    [self startQueue];
    [self.queueManagedObjectContext performBlock:^{
#ifdef DEBUG
        NSLog(@"newLog");
#endif
        Session *mySession = [Session sessionWithName:name
                                                 host:host
                                                 port:port
                                                  tls:tls
                                                 auth:auth
                                                 user:user
                                               passwd:passwd
                                             clientid:clientid
                                         cleansession:cleansession
                                            keepalive:keepalive
                                               dnssrv:dnssrv
                                               dnsdomain:dnsdomain
                               inManagedObjectContext:self.queueManagedObjectContext];

        [Message messageAt:timestamp
                     topic:topic
                      data:data
                       qos:qos
                       retained:retained
                       mid:mid
                   session:mySession
    inManagedObjectContext:self.queueManagedObjectContext];
        
        [self limit:[Message allMessagesOfSession:mySession
                           inManagedObjectContext:self.queueManagedObjectContext]
                max:MAX_LOG];
        
#ifdef DEBUG
        NSLog(@"newTopic");
#endif
        [Topic topicNamed:topic
                timestamp:timestamp
                     data:data
                      qos:qos
                 retained:retained
                      mid:mid
                  session:mySession
   inManagedObjectContext:self.queueManagedObjectContext];
        
        [self limit:[Topic allTopicsOfSession:mySession
                       inManagedObjectContext:self.queueManagedObjectContext]
                max:MAX_TOPIC];

        [self.queueManagedObjectContext save:NULL];
        [self finishQueue];
    }];
}

- (void)received:(int)type qos:(int)qos retained:(BOOL)retained duped:(BOOL)duped data:(NSData *)data
{
    NSDate *timestamp = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *name = self.session.name;
    NSString *host = self.session.host;
    int port = [self.session.port intValue];
    BOOL tls = [self.session.tls boolValue];
    BOOL auth = [self.session.auth boolValue];
    NSString *user = self.session.user;
    NSString *passwd = self.session.passwd;
    NSString *clientid = self.session.clientid;
    BOOL cleansession = [self.session.cleansession boolValue];
    int keepalive = [self.session.keepalive intValue];
    NSString *dnsdomain = self.session.dnsdomain;
    BOOL dnssrv = [self.session.dnssrv boolValue];

    [self startQueue];
    [self.queueManagedObjectContext performBlock:^{
#ifdef DEBUG
        NSLog(@"newCommand in");
#endif
        Session *mySession = [Session sessionWithName:name
                                                  host:host
                                                 port:port
                                                  tls:tls
                                                 auth:auth
                                                 user:user
                                               passwd:passwd
                                             clientid:clientid
                                         cleansession:cleansession
                                            keepalive:keepalive
                                               dnssrv:dnssrv
                                               dnsdomain:dnsdomain
                               inManagedObjectContext:self.queueManagedObjectContext];

        [Command commandAt:timestamp
                   inbound:YES
                      type:type
                     duped:duped
                       qos:qos
                  retained:retained
                       mid:0
                      data:data
                   session:mySession
    inManagedObjectContext:self.queueManagedObjectContext];
        
        [self limit:[Command allCommandsOfSession:mySession
                           inManagedObjectContext:self.queueManagedObjectContext]
                max:MAX_COMMAND];
        
        [self.queueManagedObjectContext save:NULL];
        [self finishQueue];
    }];
}

- (void)sending:(int)type qos:(int)qos retained:(BOOL)retained duped:(BOOL)duped data:(NSData *)data
{
    NSDate *timestamp = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *name = self.session.name;
    NSString *host = self.session.host;
    int port = [self.session.port intValue];
    BOOL tls = [self.session.tls boolValue];
    BOOL auth = [self.session.auth boolValue];
    NSString *user = self.session.user;
    NSString *passwd = self.session.passwd;
    NSString *clientid = self.session.clientid;
    BOOL cleansession = [self.session.cleansession boolValue];
    NSString *dnsdomain = self.session.dnsdomain;
    BOOL dnssrv = [self.session.dnssrv boolValue];
    int keepalive = [self.session.keepalive intValue];

    [self startQueue];
    [self.queueManagedObjectContext performBlock:^{
#ifdef DEBUG
        NSLog(@"newCommand out");
#endif

        Session *mySession = [Session sessionWithName:name
                                                  host:host
                                                 port:port
                                                  tls:tls
                                                 auth:auth
                                                 user:user
                                               passwd:passwd
                                             clientid:clientid
                                         cleansession:cleansession
                                            keepalive:keepalive
                                               dnssrv:dnssrv
                                               dnsdomain:dnsdomain

                               inManagedObjectContext:self.queueManagedObjectContext];

        [Command commandAt:timestamp
                   inbound:NO
                      type:type
                     duped:duped
                       qos:qos
                  retained:retained
                       mid:0
                      data:data
                   session:mySession
    inManagedObjectContext:self.queueManagedObjectContext];
        
        [self limit:[Command allCommandsOfSession:mySession
                           inManagedObjectContext:self.queueManagedObjectContext]
                max:MAX_COMMAND];
        
        [self.queueManagedObjectContext save:NULL];
        [self finishQueue];
    }];
}

- (void)messageDelivered:(MQTTSession *)session msgID:(UInt16)msgID
{
    //
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = @"Sessions";
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return YES;
}

#pragma mark - Alerts

+ (void)alert:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle mainBundle].infoDictionary[@"CFBundleName"]
                                                message:message
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - dns srv
- (void)getService:(NSString *)srvName
{
    self.resolver = [[SRVResolver alloc] initWithSRVName:srvName];
    self.resolver.delegate = self;
    
    [self.resolver start];
}

- (void)srvResolver:(SRVResolver *)resolver didReceiveResult:(NSDictionary *)result
{
    NSLog(@"didReceiveResult %@", result);
    [self.resolverResults addObject:result];
}

- (void)srvResolver:(SRVResolver *)resolver didStopWithError:(NSError *)error
{
    NSLog(@"didStopWithError %@", error);
}

- (NSString *)url
{
    return [NSString stringWithFormat:@"%@://%@%@:%@",
            [self.session.tls boolValue] ? @"mqtts" : @"mqtt",
            [self.session.auth boolValue] ? [NSString stringWithFormat:@"%@@",
                                                    self.session.user] : @"",
            self.session.host,
            self.session.port];
    
}
- (IBAction)longSub:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self performSegueWithIdentifier:@"enlargeSubs" sender:sender];
    }
}
- (IBAction)longPub:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self performSegueWithIdentifier:@"enlargePubs" sender:sender];
    }
}


@end
