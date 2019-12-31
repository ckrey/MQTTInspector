//
//  DetailVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 09.11.13.
//  Copyright © 2013-2020 Christoph Krey. All rights reserved.
//

#import "DetailVC.h"
#import <mqttc/MQTTInMemoryPersistence.h>
#import <mqttc/MQTTLog.h>
#import <mqttc/MQTTStrict.h>

#import "Model.h"

#import "MessagesTVC.h"
#import "ShowSubsTVC.h"
#import "ShowPubsTVC.h"
#import "DataVC.h"
#import "PubsTVC.h"
#import "SubsTVC.h"
#import "AppDelegate.h"
#import "SessionInfoTVC.h"

@interface MasterView: UIView
@property (nonatomic) BOOL portrait;
@property (nonatomic) CGPoint offset;
@property (weak, nonatomic) IBOutlet UITableView *messages;
@property (weak, nonatomic) IBOutlet UITableView *subs;
@property (weak, nonatomic) IBOutlet UITableView *pubs;

@end

@implementation MasterView

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect vrect = self.frame;
    CGRect mrect = self.messages.frame;
    CGRect srect = self.subs.frame;
    CGRect prect = self.pubs.frame;
    
    if (fabs(self.offset.x) > vrect.size.width / 2 - 4) self.offset = CGPointMake(0, self.offset.y);
    if (fabs(self.offset.y) > vrect.size.height / 2 - 4) self.offset = CGPointMake(self.offset.x, 0);
    
    srect = CGRectMake(0,
                       0,
                       vrect.size.width / 2 - 4 + self.offset.x,
                       vrect.size.height / 2 - 4 + self.offset.y);
    
    if (self.portrait) {
        mrect = CGRectMake(vrect.size.width / 2 + 4 + self.offset.x,
                           0,
                           vrect.size.width - (vrect.size.width / 2 - 4 + self.offset.x),
                           vrect.size.height);
        prect = CGRectMake(0,
                           vrect.size.height / 2 + 4 + self.offset.y,
                           vrect.size.width / 2 - 4 + self.offset.x,
                           vrect.size.height - (vrect.size.height / 2 - 4 + self.offset.y + 8));
    } else {
        mrect = CGRectMake(0,
                           vrect.size.height / 2 + 4 + self.offset.y,
                           vrect.size.width,
                           vrect.size.height - (vrect.size.height / 2 - 4 + self.offset.y + 8));
        prect = CGRectMake(vrect.size.width / 2 + 4 + self.offset.x,
                           0,
                           vrect.size.width - (vrect.size.width / 2 - 4 + self.offset.x),
                           vrect.size.height / 2 - 4 + self.offset.y);
    }
    
    DDLogVerbose(@"v=%f/%f/%f/%f, s=%f/%f/%f/%f, p=%f/%f/%f/%f, m=%f/%f/%f/%f",
                 vrect.origin.x, vrect.origin.y, vrect.size.width, vrect.size.height,
                 srect.origin.x, srect.origin.y, srect.size.width, srect.size.height,
                 prect.origin.x, prect.origin.y, prect.size.width, prect.size.height,
                 mrect.origin.x, mrect.origin.y, mrect.size.width, mrect.size.height);
    
    self.messages.frame = mrect;
    self.subs.frame = srect;
    self.pubs.frame = prect;
}

@end

@interface DetailVC ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *infoButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *disconnectButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *connectButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *clearButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *pubButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UITableView *messages;
@property (weak, nonatomic) IBOutlet UITableView *subs;
@property (weak, nonatomic) IBOutlet UITableView *pubs;
@property (weak, nonatomic) IBOutlet UISegmentedControl *level;
@property (weak, nonatomic) IBOutlet UISwitch *runningSwitch;
@property (weak, nonatomic) IBOutlet MasterView *masterView;

@property (strong, nonatomic) MessagesTVC *messagesTVC;
@property (strong, nonatomic) ShowSubsTVC *subsTVC;
@property (strong, nonatomic) ShowPubsTVC *pubsTVC;
@property (weak, nonatomic) IBOutlet UITextField *countText;

@property (strong, nonatomic) NSManagedObjectContext *queueManagedObjectContext;
@property (strong, nonatomic) NSTimer *connectTimer;
@property (nonatomic) float queueIn;
@property (nonatomic) float queueOut;
@property (nonatomic) BOOL running;

@end

@implementation DetailVC
static DetailVC *theDetailVC;

- (void)viewDidLoad {
    DDLogVerbose(@"viewDidLoad");
    theDetailVC = self;
    
    [super viewDidLoad];
    
    self.splitViewController.delegate = self;

#if !TARGET_OS_MACCATALYST
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(orientationChanged:)
     name:UIApplicationDidChangeStatusBarOrientationNotification
     object:nil];
#endif
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(willResign:)
     name:UIApplicationWillResignActiveNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(willEnter:)
     name:UIApplicationWillEnterForegroundNotification
     object:nil];
    self.masterView.portrait = true;
    self.masterView.offset = CGPointMake(0, 0);

    MQTTLog.logLevel = DDLogLevelVerbose;
    MQTTStrict.strict = false;
}

- (void)orientationChanged:(NSNotification *)notification {
    DDLogVerbose(@"orientationChanged");
}

- (void)willResign:(NSNotification *)notification {
    DDLogVerbose(@"willResign");
    [self disconnect:nil];
}

- (void)willEnter:(NSNotification *)notification {
    DDLogVerbose(@"willEnter");
    if ((self.session.autoconnect).boolValue) {
        self.title = [NSString stringWithFormat:@"%@-%@", self.session.name, [self url]];
        [self connect:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"viewWillAppear");
    [super viewWillAppear:animated];
    [self viewChanged:nil];
    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.navigationItem.leftItemsSupplementBackButton = YES;

    [self enableButtons];
    
    if (!self.subsTVC) {
        self.subsTVC = [[ShowSubsTVC alloc] init];
        self.subsTVC.mother = self;
        self.subsTVC.tableView = self.subs;
    }
    
    if (!self.pubsTVC) {
        self.pubsTVC = [[ShowPubsTVC alloc] init];
        self.pubsTVC.mother = self;
        self.pubsTVC.tableView = self.pubs;
    }

    if (!self.messagesTVC) {
        self.messagesTVC = [[MessagesTVC alloc] init];
        self.messagesTVC.mother = self;
        self.messagesTVC.tableView = self.messages;
    }

    self.masterView.subs = self.subs;
    self.masterView.pubs = self.pubs;
    self.masterView.messages = self.messages;
    
    [self showCount];
    
    if (!self.session) {
        (self.splitViewController).preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    }
    [self setSubViews];

    self.running = self.runningSwitch.on;
}

- (void)viewDidAppear:(BOOL)animated {
    DDLogVerbose(@"viewDidAppear");
    [self setSubViews];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"viewWillDisappear");
    [super viewWillDisappear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"setSessionForPub:"] ||
        [segue.identifier isEqualToString:@"setSessionForFilter:"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setMother:)]) {
            [segue.destinationViewController performSelector:@selector(setMother:)
                                                  withObject:self];
        }
    } else if ([segue.identifier isEqualToString:@"enlargePubs"] ||
        [segue.identifier isEqualToString:@"enlargeSubs"]) {
        
        if (segue.sourceViewController == self) {
            if ([segue.destinationViewController respondsToSelector:@selector(setSession:)]) {
                [segue.destinationViewController performSelector:@selector(setSession:)
                                                      withObject:self.session];
            }
        }
    } else if ([segue.identifier isEqualToString:@"showSessionInfo"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setSession:)]) {
            [segue.destinationViewController performSelector:@selector(setSession:)
                                                  withObject:self.session];
        }
        if ([segue.destinationViewController respondsToSelector:@selector(setMqttSession:)]) {
            [segue.destinationViewController performSelector:@selector(setMqttSession:)
                                                  withObject:self.mqttSession];
        }
    }


    
    NSIndexPath *indexPath = nil;
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.messages indexPathForCell:sender];
    }
    
    if (indexPath) {
        if ([segue.identifier isEqualToString:@"setMessage:"]) {
            id theObject = [self.messagesTVC.fetchedResultsController objectAtIndexPath:indexPath];;

            if ([segue.destinationViewController respondsToSelector:@selector(setObject:)]) {
                [segue.destinationViewController performSelector:@selector(setObject:)
                                                      withObject:theObject];
            }
        }
    }
}

- (void)publish:(Publication *)pub {
    NSString *string = [[NSString alloc] initWithData:pub.data encoding:NSUTF8StringEncoding];
    
    // REPLACE %t with timeIntervalSince1970
    NSString *nowString = [NSString stringWithFormat:@"%.0f", [NSDate date].timeIntervalSince1970];
    string = [string stringByReplacingOccurrencesOfString:@"%t" withString:nowString];
    
    // REPLACE %c with effective clientId
    NSString *clientId;
    if ((!pub.belongsTo.clientid) || ([pub.belongsTo.clientid isEqualToString:@""])) {
        clientId = [NSString stringWithFormat:@"MQTTInspector%d", getpid()];
    } else {
        clientId = pub.belongsTo.clientid;
    }
    string = [string stringByReplacingOccurrencesOfString:@"%c" withString:clientId];

    [self.mqttSession publishDataV5:[string dataUsingEncoding:NSUTF8StringEncoding]
                            onTopic:pub.topic
                             retain:(pub.retained).boolValue
                                qos:(pub.qos).intValue
             payloadFormatIndicator:pub.payloadFormatIndicator
              messageExpiryInterval:pub.messageExpiryInterval
                         topicAlias:pub.topicAlias
                      responseTopic:pub.responseTopic
                    correlationData:pub.correlationData
                     userProperties:pub.userProperties ? [NSJSONSerialization JSONObjectWithData:pub.userProperties options:0 error:nil] : nil
                        contentType:pub.contentType
                     publishHandler:nil];
}


- (NSString *)effectiveClientId {
    NSString *clientId;
    if (!self.session.clientid) {
        clientId = [NSString stringWithFormat:@"MQTTInspector%d", getpid()];
    } else {
        clientId = self.session.clientid;
    }
    return clientId;
}

- (void)viewDidLayoutSubviews {
    DDLogVerbose(@"viewDidLayoutSubviews");
    [self setSubViews];
}

- (void)viewWillLayoutSubviews {
    DDLogVerbose(@"viewWillLayoutSubviews");
    [self setSubViews];
}

- (void)setSubViews {
    DDLogVerbose(@"setSubViews");
    [self.masterView setNeedsLayout];
}

- (IBAction)rotate:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        DDLogVerbose(@"rotate");
        self.masterView.portrait = !self.masterView.portrait;
        [self setSubViews];
    }
}

- (IBAction)pan:(UIPanGestureRecognizer *)sender {
    DDLogVerbose(@"pan %ld", (long)sender.state);
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            [sender setTranslation:CGPointMake(self.subs.frame.size.width, self.subs.frame.size.height)
                            inView:sender.view];
            sender.view.backgroundColor = [UIColor yellowColor];
            break;
            
        case UIGestureRecognizerStateChanged: {
            CGPoint point = [sender translationInView:sender.view];
            DDLogVerbose(@"translationInView %f,%f", point.x, point.y);
            CGRect vrect = self.subs.superview.frame;
            
            if (point.x > 8 &&
                point.x < vrect.size.width - 8 &&
                point.y > 8 &&
                point.y < vrect.size.height - 8) {
                
                self.masterView.offset = CGPointMake(point.x - vrect.size.width / 2,
                                     point.y - vrect.size.height / 2);
                [self setSubViews];
                sender.view.backgroundColor = [UIColor orangeColor];
            } else {
                sender.view.backgroundColor = [UIColor redColor];
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
            sender.view.backgroundColor = [UIColor blueColor];
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStatePossible:
        default:
            sender.view.backgroundColor = [UIColor grayColor];
            break;
    }
}
- (IBAction)editSubs:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.subs.editing = !self.subs.editing;
    }
}
- (IBAction)editPubs:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.pubs.editing = !self.pubs.editing;
    }
}

- (IBAction)runningChanged:(UISwitch *)sender {
    self.running = self.runningSwitch.on;
}

/*
 * MQTTSession is managed here in the setSession, connect and disconnect
 */

- (void)setMqttSession:(MQTTSession *)mqttSession {
    DDLogVerbose(@"setMqttSession");
    _mqttSession = mqttSession;
}

#pragma mark - Managing the detail item
- (void)setSession:(Session *)session {
    DDLogVerbose(@"setSession");
    if (self.session) {
        [self disconnect:nil];
    }
    
    _session = session;
    
    if ((session.autoconnect).boolValue) {
        self.title = [NSString stringWithFormat:@"%@-%@", self.session.name, [self url]];
        [self connect:nil];
    }
    
    [self viewChanged:nil];
    self.title = session.name;
    [self.subsTVC.tableView reloadData];
    [self.pubsTVC.tableView reloadData];
    self.messagesTVC.messagesType = MessagesTopics;
    [self showCount];
    [self enableButtons];
}


- (IBAction)connect:(UIBarButtonItem *)sender {
    if (self.session) {
        
        if (self.mqttSession) {
            [self.mqttSession closeWithReturnCode:MQTTSuccess
                            sessionExpiryInterval:nil
                                     reasonString:nil
                                   userProperties:nil
                                disconnectHandler:nil];
            self.mqttSession.delegate = nil;
        }
        
        self.mqttSession = [[MQTTSession alloc] init];

        MQTTNWTransport *nwTransport = [[MQTTNWTransport alloc] init];
        nwTransport.host = self.session.host;
        nwTransport.port = (self.session.port).unsignedIntValue;
        nwTransport.tls = (self.session.tls).boolValue;
        if ((self.session.tls).boolValue) {
            nwTransport.allowUntrustedCertificates = (self.session.allowUntrustedCertificates).boolValue;
        }
        nwTransport.ws = (self.session.websocket).boolValue;
        self.mqttSession.transport = nwTransport;

        self.mqttSession.transport.host = self.session.host;
        self.mqttSession.transport.port = (self.session.port).unsignedIntValue;
        self.mqttSession.transport.tls = (self.session.tls).boolValue;

        NSArray *certificates = nil;
        NSURL *directoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                     inDomain:NSUserDomainMask
                                                            appropriateForURL:nil
                                                                       create:YES
                                                                        error:nil];
        if (self.session.pkcsfile && self.session.pkcsfile.length) {
            NSString *clientPKCSPath = [directoryURL.path stringByAppendingPathComponent:self.session.pkcsfile];
            certificates = [MQTTTransport clientCertsFromP12:clientPKCSPath
                                                  passphrase:self.session.pkcspassword];
        }
        self.mqttSession.certificates = certificates;        
        
        self.mqttSession.clientId = [self effectiveClientId];
        self.mqttSession.userName = (self.session.auth).boolValue ? self.session.user : nil;
        self.mqttSession.password = (self.session.auth).boolValue ? self.session.passwd : nil;
        self.mqttSession.keepAliveInterval = (self.session.keepalive).intValue;
        self.mqttSession.cleanSessionFlag = (self.session.cleansession).boolValue;
        self.mqttSession.protocolLevel = (self.session.protocolLevel).intValue;
        self.mqttSession.sessionExpiryInterval = self.session.sessionExpiryInterval;
        self.mqttSession.receiveMaximum = self.session.receiveMaximum;
        self.mqttSession.maximumPacketSize = self.session.maximumPacketSize;
        self.mqttSession.topicAliasMaximum = self.session.topicAliasMaximum;
        self.mqttSession.requestProblemInformation = self.session.requestProblemInformation;
        self.mqttSession.requestResponseInformation = self.session.requestResponseInformatino;
        if (self.session.userProperties) {
            self.mqttSession.userProperties = [NSJSONSerialization
                                               JSONObjectWithData:self.session.userProperties
                                               options:0
                                               error:nil];
        } else {
            self.mqttSession.userProperties = nil;
        }
        self.mqttSession.authMethod = self.session.authMethod;
        self.mqttSession.authData = self.session.authData;


        if ((self.session.cleansession).boolValue) {
            for (Subscription *sub in self.session.hasSubs) {
                sub.state = @(0);
            }
        }
        
        self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:(self.session.keepalive).intValue
                                                             target:self
                                                           selector:@selector(connectTimeout:)
                                                           userInfo:nil
                                                            repeats:NO];
        self.title = [NSString stringWithFormat:@"%@-%@", self.session.name, [self url]];
        self.mqttSession.delegate = self;
        [self.mqttSession connectWithConnectHandler:nil];
        [self enableButtons];
    }
}
                             
- (void)connectTimeout:(NSTimer *)timer {
    DDLogError(@"connect timed out");
    [self message:@"connect timed out"];
    [self disconnect:nil];
}

- (IBAction)disconnect:(UIBarButtonItem *)sender {
    if (self.session) {
        [self.mqttSession closeWithReturnCode:MQTTSuccess
                        sessionExpiryInterval:nil
                                 reasonString:nil
                               userProperties:nil
                            disconnectHandler:nil];
        self.mqttSession = nil;
        self.title = self.session.name;
    }
}

- (IBAction)viewChanged:(UISegmentedControl *)sender {
    switch (self.level.selectedSegmentIndex) {
        case 2:
            self.messagesTVC.messagesType = MessagesCommands;
            break;
        case 1:
            self.messagesTVC.messagesType = MessagesLogs;
            break;
        case 0:
        default:
            self.messagesTVC.messagesType = MessagesTopics;
            break;
    }
    [self showCount];
}

- (IBAction)clear:(UIBarButtonItem *)sender {
    if (self.session) {
        for (Message *message in self.session.hasMesssages) {
            [self.session.managedObjectContext deleteObject:message];
        }
        for (Topic *topic in self.session.hasTopics) {
            [self.session.managedObjectContext deleteObject:topic];
        }
        for (Command *command in self.session.hasCommands) {
            [self.session.managedObjectContext deleteObject:command];
        }
        NSError *error;
        if (![self.session.managedObjectContext save:&error]) {
            DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    [self showCount];
}

#define MAX_LOG 512
#define MAX_TOPIC 256
#define MAX_COMMAND 1024

- (NSManagedObjectContext *)queueManagedObjectContext {
    if (!_queueManagedObjectContext) {
        _queueManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _queueManagedObjectContext.parentContext = self.session.managedObjectContext;
    }
    return _queueManagedObjectContext;
}

- (void)startQueue {
    self.queueIn += 1;
    [self showQueue];
}

- (void)finishQueue {
    while (!self.running) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    }
    self.queueOut += 1;
    [self performSelectorOnMainThread:@selector(showQueue) withObject:nil waitUntilDone:FALSE];
}

- (void)showQueue {
    if (self.queueIn == self.queueOut) {
        self.queueIn = 1;
        self.queueOut = 1;
    }
    [self.progress setProgress:self.queueOut/self.queueIn animated:NO];
    [self showCount];
}

- (void)showCount
{
    if (self.session) {
        switch (self.level.selectedSegmentIndex) {
            case 2:
                self.countText.text = [NSString stringWithFormat:@"%lu",
                                       (unsigned long)(self.session.hasCommands).count];
                break;
            case 1:
                self.countText.text = [NSString stringWithFormat:@"%lu",
                                       (unsigned long)(self.session.hasMesssages).count];
                break;
            case 0:
            default:
                self.countText.text = [NSString stringWithFormat:@"%lu",
                                       (unsigned long)(self.session.hasTopics).count];
                break;
        }
    } else {
        self.countText.text = @"";
    }
}

- (void)limit:(NSArray *)array max:(int)max
{
    DDLogVerbose(@"#count %lu/%d", (unsigned long)[array count], max);
    
    for (NSInteger i = array.count; i > max; i--) {
        NSManagedObject *object = array[i - 1];
        DDLogVerbose(@"delete %@", object);
        [object.managedObjectContext deleteObject:object];
    }
}

#pragma mark - MQTTSessionDelegate
- (void)connected:(MQTTSession *)session sessionPresent:(BOOL)sessionPresent {
    if (!sessionPresent) {
        for (Subscription *sub in self.session.hasSubs) {
            sub.state = @(false);
        }
    }
}

- (void)connectionClosed:(MQTTSession *)session {
    //
}

- (void)connectionError:(MQTTSession *)session error:(NSError *)error {
    //
}

- (void)connectionRefused:(MQTTSession *)session error:(NSError *)error {
    //
}

- (void)handleEvent:(MQTTSession *)session event:(MQTTSessionEvent)eventCode error:(NSError *)error {

    NSMutableDictionary *dict = [@{
        @"eventCode": @(eventCode)
    } mutableCopy];

    if (error) {
        dict[@"error"] = error;
    }
    
    [self performSelectorOnMainThread:@selector(handleEventMain:)
                           withObject:dict
                        waitUntilDone:NO];
}

- (void)handleEventMain:(NSDictionary <NSString *, id> *)dict {
    MQTTSessionEvent eventCode = MQTTSessionEventConnected;
    NSError *error = nil;

    NSObject *eventCodeObject = [dict objectForKey:@"eventCode"];
    if (eventCodeObject && [eventCodeObject isKindOfClass:[NSNumber class]]) {
        NSNumber *n = (NSNumber *)eventCodeObject;
        eventCode = n.integerValue;
    }
    NSObject *errorObject = [dict objectForKey:@"error"];
    if (errorObject && [errorObject isKindOfClass:[NSError class]]) {
        error = (NSError *)errorObject;
    }

    NSArray *events = @[
                        @"MQTTSessionEventConnected",
                        @"MQTTSessionEventConnectionRefused",
                        @"MQTTSessionEventConnectionClosed",
                        @"MQTTSessionEventConnectionError",
                        @"MQTTSessionEventProtocolError",
                        @"MQTTSessionEventConnectionClosedByBroker"
                        ];

    DDLogVerbose(@"handleEvent: %@ (%ld) %@ (%ld)",
                 events[eventCode % [events count]],
                 (long)eventCode,
                 [error description],
                 (long)error.code);
    
    if (eventCode == MQTTSessionEventConnected) {
        [self.subsTVC.tableView reloadData];
        [self.pubsTVC.tableView reloadData];
        [self.messagesTVC.tableView reloadData];
    }
    
    if (eventCode == MQTTSessionEventConnectionClosed ||
        eventCode == MQTTSessionEventConnectionClosedByBroker) {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate connectionClosed];
    }
    
    if (error) {
        [DetailVC alert:[NSString stringWithFormat: @"Error %@ (%ld) %@ (%ld)",
                         events[eventCode % events.count],
                         (long)eventCode,
                         error.localizedDescription,
                         (long)error.code
                         ]];
    }
    
    if (self.connectTimer && self.connectTimer.isValid) {
        [self.connectTimer invalidate];
    }
    [self enableButtons];
}

- (void)subAckReceivedV5:(MQTTSession *)session
                   msgID:(UInt16)msgID
            reasonString:(NSString *)reasonString
          userProperties:(NSDictionary<NSString *,NSString *> *)userProperties
             reasonCodes:(NSArray<NSNumber *> *)reasonCodes {
    DDLogVerbose(@"subAckReceived m%d r%@ u%@ c%@",
                 msgID, reasonString, userProperties, reasonCodes);
}

- (void)unsubAckReceivedV5:(MQTTSession *)session
                     msgID:(UInt16)msgID
              reasonString:(NSString *)reasonString
            userProperties:(NSArray<NSDictionary<NSString *,NSString *> *> *)userProperties
               reasonCodes:(NSArray<NSNumber *> *)reasonCodes {
    DDLogVerbose(@"unsubAckReceived m%d r%@ u%@ c%@",
                 msgID, reasonString, userProperties, reasonCodes);
}

-(void)newMessageV5:(MQTTSession *)session
               data:(NSData *)data
            onTopic:(NSString *)topic
                qos:(MQTTQosLevel)qos
           retained:(BOOL)retained
                mid:(unsigned int)mid
payloadFormatIndicator:(NSNumber *)payloadFormatIndicator
messageExpiryInterval:(NSNumber *)messageExpiryInterval
         topicAlias:(NSNumber *)topicAlias
      responseTopic:(NSString *)responseTopic
    correlationData:(NSData *)correlationData
     userProperties:(NSArray<NSDictionary<NSString *,NSString *> *> *)userProperties
        contentType:(NSString *)contentType
subscriptionIdentifiers:(NSArray<NSNumber *> *)subscriptionIdentifiers {
    NSDate *timestamp = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *name = self.session.name;
    NSString *attributefilter = self.session.attributefilter;
    NSString *datafilter = self.session.datafilter;
    NSString *topicfilter = self.session.topicfilter;
    BOOL includefilter = (self.session.includefilter).boolValue;
    
    BOOL filter = TRUE;
    NSData *limitedData = [self limitedData:data];
    
    NSError *error;
    
    NSString *attributes = [NSString stringWithFormat:@"q%d r%d i%u", qos, retained, mid];
    NSRegularExpression *attributeRegex =
    [NSRegularExpression regularExpressionWithPattern:attributefilter ? attributefilter : @"" options:0 error:&error];
    if (attributeRegex) {
        NSUInteger attributeMatches = [attributeRegex numberOfMatchesInString:attributes
                                                                      options:0
                                                                        range:NSMakeRange(0, attributes.length)];
        if ((attributeMatches == 0) == includefilter) {
            DDLogVerbose(@"filter regexp %@ does not match attributes %@ %@",
                         attributefilter, attributes, @(includefilter));
            filter = FALSE;
        }
    }
    
    
    DDLogVerbose(@"limitedData %@", limitedData ? limitedData : @"nil");
    NSString *dataString;
    dataString = [[NSString alloc] initWithData:limitedData encoding:NSUTF8StringEncoding];
    DDLogVerbose(@"dataString NSUTF8StringEncoding %@", dataString ? dataString : @"nil");
    if (!dataString) {
        dataString = [[NSString alloc] initWithData:limitedData encoding:NSUnicodeStringEncoding];
        DDLogVerbose(@"dataString NSUnicodeStringEncoding %@", dataString ? dataString : @"nil");
    }
    if (!dataString) {
        dataString = [[NSString alloc] initWithData:limitedData encoding:NSISOLatin1StringEncoding];
        DDLogVerbose(@"dataString NSISOLatin1StringEncoding %@", dataString ? dataString : @"nil");
    }
    NSRegularExpression *dataRegex;
    
    if (dataString) {
        dataRegex =
        [NSRegularExpression regularExpressionWithPattern:datafilter ? datafilter : @"" options:0 error:&error];
        if (dataRegex){
            NSUInteger dataMatches = [dataRegex numberOfMatchesInString:dataString
                                                                options:0
                                                                  range:NSMakeRange(0, dataString.length)];
            if ((dataMatches == 0) == includefilter) {
                DDLogVerbose(@"filter regexp %@ does not match data %@ %@",
                             datafilter, dataString, @(includefilter));
                filter = FALSE;
            }
        }
    }
    
    NSRegularExpression *topicRegex;
    DDLogVerbose(@"topic %@", topic ? topic : @"nil");
    if (topic) {
        topicRegex =
        [NSRegularExpression regularExpressionWithPattern:topicfilter ? topicfilter : @"" options:0 error:&error];
        if (topicRegex) {
            NSUInteger topicMatches = [topicRegex numberOfMatchesInString:topic
                                                                  options:0
                                                                    range:NSMakeRange(0, topic.length)];
            if ((topicMatches == 0) == includefilter) {
                DDLogVerbose(@"filter regexp %@ does not match topic %@ %@",
                             topicfilter, topic, @(includefilter));
                filter = FALSE;
            }
        }
    } else {
        DDLogVerbose(@"no topic");
        filter = false;
    }
    
    if (filter) {
        [self startQueue];
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^(void) {
            if (![name isEqualToString:self.session.name]) {
                return;
            }

            [self.queueManagedObjectContext performBlock:^{
                Session *mySession = [Session existSessionWithName:name
                                            inManagedObjectContext:self.queueManagedObjectContext];
                
                DDLogVerbose(@"newLog");
                Message *theMessage = [Message messageAt:timestamp
                                                 session:mySession
                                  inManagedObjectContext:self.queueManagedObjectContext];

                theMessage.topic = topic;
                theMessage.data = limitedData;
                theMessage.qos = @(qos);
                theMessage.retained = @(retained);
                theMessage.mid = @(mid);
                theMessage.payloadFormatIndicator = payloadFormatIndicator;
                theMessage.messageExpiryInterval = messageExpiryInterval;
                theMessage.topicAlias = topicAlias;
                theMessage.responstTopic = responseTopic;
                theMessage.correlationData = correlationData;
                if (userProperties && [NSJSONSerialization isValidJSONObject:userProperties]) {
                    theMessage.userProperties = [NSJSONSerialization dataWithJSONObject:userProperties
                                                                              options:0
                                                                                error:nil];
                } else {
                    theMessage.userProperties = nil;
                }
                theMessage.contentType = contentType;
                if (subscriptionIdentifiers && [NSJSONSerialization isValidJSONObject:subscriptionIdentifiers]) {
                    theMessage.subscriptionIdentifiers = [NSJSONSerialization
                                                        dataWithJSONObject:subscriptionIdentifiers
                                                        options:0
                                                        error:nil];
                } else {
                    theMessage.subscriptionIdentifiers = nil;
                }

                
                [self limit:[Message allMessagesOfSession:mySession
                                   inManagedObjectContext:self.queueManagedObjectContext]
                        max:MAX_LOG];
                
                DDLogVerbose(@"newTopic");
                Topic *theTopic = [Topic topicNamed:topic
                                            session:mySession
                             inManagedObjectContext:self.queueManagedObjectContext];
                theTopic.count = @((theTopic.count).intValue + 1);
                theTopic.data = limitedData;
                theTopic.qos = @(qos);
                theTopic.mid = @(mid);
                theTopic.retained = @(retained);
                theTopic.timestamp = timestamp;
                theTopic.justupdated = theTopic.count;
                theTopic.payloadFormatIndicator = payloadFormatIndicator;
                theTopic.messageExpiryInterval = messageExpiryInterval;
                theTopic.topicAlias = topicAlias;
                theTopic.responseTopic = responseTopic;
                theTopic.correlationData = correlationData;
                if (userProperties && [NSJSONSerialization isValidJSONObject:userProperties]) {
                    theTopic.userProperties = [NSJSONSerialization dataWithJSONObject:userProperties
                                                                              options:0
                                                                                error:nil];
                } else {
                    theTopic.userProperties = nil;
                }
                theTopic.contentType = contentType;
                if (subscriptionIdentifiers && [NSJSONSerialization isValidJSONObject:subscriptionIdentifiers]) {
                    theTopic.subscriptionIdentifiers = [NSJSONSerialization
                                                        dataWithJSONObject:subscriptionIdentifiers
                                                        options:0
                                                        error:nil];
                } else {
                    theTopic.subscriptionIdentifiers = nil;
                }

                [self limit:[Topic allTopicsOfSession:mySession
                               inManagedObjectContext:self.queueManagedObjectContext]
                        max:MAX_TOPIC];

                NSError *error;
                
                if (![self.queueManagedObjectContext save:NULL]) {
                    DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
                
                [self finishQueue];
            }];
        });
    }
}

- (void)received:(MQTTSession *)session
            type:(MQTTCommandType)type
             qos:(MQTTQosLevel)qos
        retained:(BOOL)retained
           duped:(BOOL)duped
             mid:(UInt16)mid
            data:(NSData *)data {
    
    NSDate *timestamp = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *name = self.session.name;
    
    NSData *limitedData = [self limitedData:data];
    
    [self startQueue];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^(void) {
        if (![name isEqualToString:self.session.name]) {
            return;
        }
        
        [self.queueManagedObjectContext performBlock:^{
            DDLogVerbose(@"newCommand in");
            Session *mySession = [Session existSessionWithName:name
                                        inManagedObjectContext:self.queueManagedObjectContext];
            [Command commandAt:timestamp
                       inbound:YES
                          type:type
                         duped:duped
                           qos:qos
                      retained:retained
                           mid:mid
                          data:limitedData
                       session:mySession
        inManagedObjectContext:self.queueManagedObjectContext];
            
            [self limit:[Command allCommandsOfSession:mySession
                               inManagedObjectContext:self.queueManagedObjectContext]
                    max:MAX_COMMAND];
            
            NSError *error;
            
            if (![self.queueManagedObjectContext save:NULL]) {
                DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            
            [self finishQueue];
        }];
    });
}

- (void)sending:(MQTTSession *)session
           type:(MQTTCommandType)type
            qos:(MQTTQosLevel)qos
       retained:(BOOL)retained
          duped:(BOOL)duped
            mid:(UInt16)mid
           data:(NSData *)data {
    
    NSDate *timestamp = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *name = self.session.name;
    
    NSData *limitedData = [self limitedData:data];
    
    [self startQueue];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^(void) {
        if (![name isEqualToString:self.session.name]) {
            return;
        }
        
        [self.queueManagedObjectContext performBlock:^{
            DDLogVerbose(@"newCommand out");
            Session *mySession = [Session existSessionWithName:name
                                        inManagedObjectContext:self.queueManagedObjectContext];
            
            
            [Command commandAt:timestamp
                       inbound:NO
                          type:type
                         duped:duped
                           qos:qos
                      retained:retained
                           mid:mid
                          data:limitedData
                       session:mySession
        inManagedObjectContext:self.queueManagedObjectContext];
            
            [self limit:[Command allCommandsOfSession:mySession
                               inManagedObjectContext:self.queueManagedObjectContext]
                    max:MAX_COMMAND];
            
            NSError *error;
            
            if (![self.queueManagedObjectContext save:NULL]) {
                DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            
            [self finishQueue];
        }];
    });
}

- (void)messageDeliveredV5:(MQTTSession *)session msgID:(UInt16)msgID topic:(NSString *)topic data:(NSData *)data qos:(MQTTQosLevel)qos retainFlag:(BOOL)retainFlag payloadFormatIndicator:(NSNumber *)payloadFormatIndicator messageExpiryInterval:(NSNumber *)messageExpiryInterval topicAlias:(NSNumber *)topicAlias responseTopic:(NSString *)responseTopic correlationData:(NSData *)correlationData userProperties:(NSArray<NSDictionary<NSString *,NSString *> *> *)userProperties contentType:(NSString *)contentType {
    //
}

- (void)buffered:(MQTTSession *)session
       flowingIn:(NSUInteger)flowingIn
      flowingOut:(NSUInteger)flowingOut {
    DDLogVerbose(@"Connection buffered i%lu o%lu", (unsigned long)flowingIn, (unsigned long)flowingOut);
}

#pragma mark - Alerts

- (void)message:(NSString *)message {
    [self alert:[NSBundle mainBundle].infoDictionary[@"CFBundleName"]
        message:message
   dismissAfter:0.5];
}

+ (void)alert:(NSString *)message {
    [theDetailVC alert:[NSBundle mainBundle].infoDictionary[@"CFBundleName"]
               message:message
   dismissAfter:0];
}

- (void)alert:(NSString *)title
      message:(NSString *)message
 dismissAfter:(NSTimeInterval)interval {
    [self performSelectorOnMainThread:@selector(alert:)
                           withObject:@{
                                        @"title": title,
                                        @"message": message,
                                        @"interval": [NSNumber numberWithFloat:interval]
                                        }
                        waitUntilDone:NO];
}

- (void)alert:(NSDictionary *)parameters {
    UIAlertController *ac = [UIAlertController
                             alertControllerWithTitle:parameters[@"title"]
                             message:parameters[@"message"]
                             preferredStyle:UIAlertControllerStyleAlert];
    NSNumber *interval = parameters[@"interval"];
    if (!interval || interval.floatValue == 0.0) {
        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"Continue",
                                                               @"Continue button title")

                             style:UIAlertActionStyleDefault
                             handler:nil];
        [ac addAction:ok];
    }
    [self presentViewController:ac animated:TRUE completion:nil];

    if (interval && interval.floatValue > 0.0) {
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:interval.floatValue];
    }
}

- (void)dismiss {
    [self dismissViewControllerAnimated:TRUE completion:nil];
}




- (NSString *)url {
    return [NSString stringWithFormat:@"%@%@%@:%@",
            ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) ? @"" :
            [NSString stringWithFormat:@"%@://", (self.session.tls).boolValue ? @"mqtts" : @"mqtt"],
            (self.session.auth).boolValue ? [NSString stringWithFormat:@"%@@",
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

- (void)enableButtons {
    if (self.session) {
        self.level.enabled = TRUE;
        self.clearButton.enabled = TRUE;

        switch (self.mqttSession.status) {
            case MQTTSessionStatusConnected:
                self.connectButton.enabled = FALSE;
                self.disconnectButton.enabled = TRUE;
                self.pubButton.enabled = TRUE;
                self.infoButton.enabled = TRUE;
                break;
                
            case MQTTSessionStatusConnecting:
                self.connectButton.enabled = FALSE;
                self.disconnectButton.enabled = FALSE;
                self.pubButton.enabled = FALSE;
                self.infoButton.enabled = TRUE;
                break;
                
            default:
                self.connectButton.enabled = TRUE;
                self.disconnectButton.enabled = FALSE;
                self.pubButton.enabled = FALSE;
                self.infoButton.enabled = FALSE;
                break;
        }
    } else {
        self.level.enabled = FALSE;
        self.clearButton.enabled = FALSE;
        self.infoButton.enabled = FALSE;
    }
}

- (NSData *)limitedData:(NSData *)data
{
    NSData *limitedData = data;
    int limit = (self.session.sizelimit).intValue;
    if (limit) {
        limitedData = [data subdataWithRange:NSMakeRange(0, MIN(data.length, limit))];
    }
    return limitedData;
}

#pragma mark - UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController *)svc willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode {
    DDLogVerbose(@"splitViewController willChangeToDisplayMode %ld", (long)displayMode);
    [self setSubViews];
}

@end
