//
//  DetailVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 09.11.13.
//  Copyright © 2013-2017 Christoph Krey. All rights reserved.
//

#import "DetailVC.h"
#import <mqttc/MQTTWebsocketTransport.h>
#import <mqttc/MQTTInMemoryPersistence.h>

#import "Model.h"

#import "LogsTVC.h"
#import "TopicsTVC.h"
#import "CommandsTVC.h"
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
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (weak, nonatomic) IBOutlet UISwitch *runningSwitch;
@property (weak, nonatomic) IBOutlet MasterView *masterView;

@property (strong, nonatomic) LogsTVC *logsTVC;
@property (strong, nonatomic) TopicsTVC *topicsTVC;
@property (strong, nonatomic) CommandsTVC *commandsTVC;
@property (strong, nonatomic) ShowSubsTVC *subsTVC;
@property (strong, nonatomic) ShowPubsTVC *pubsTVC;
@property (weak, nonatomic) IBOutlet UITextField *countText;

@property (strong, nonatomic) NSManagedObjectContext *queueManagedObjectContext;
@property (strong, nonatomic) NSTimer *connectTimer;
@property (nonatomic) float queueIn;
@property (nonatomic) float queueOut;

@end

@implementation DetailVC

- (void)viewDidLoad {
    DDLogVerbose(@"viewDidLoad");
    
    [super viewDidLoad];
    
    self.splitViewController.delegate = self;

    [[NSNotificationCenter defaultCenter ]addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter ]addObserver:self
                                             selector:@selector(willResign:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter ]addObserver:self
                                             selector:@selector(willEnter:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    self.masterView.portrait = true;
    self.masterView.offset = CGPointMake(0, 0);
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
    
    self.masterView.subs = self.subs;
    self.masterView.pubs = self.pubs;
    self.masterView.messages = self.messages;
    
    [self showCount];
    
    if (!self.session) {
        (self.splitViewController).preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    }
    [self setSubViews];
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
            id theObject;
            
            if (self.logsTVC) {
                Message *message = [(self.logsTVC).fetchedResultsController objectAtIndexPath:indexPath];
                theObject = message;
            }
            if (self.topicsTVC) {
                Topic *topic = [(self.topicsTVC).fetchedResultsController objectAtIndexPath:indexPath];
                theObject = topic;
            }
            if (self.commandsTVC) {
                Command *command = [(self.commandsTVC).fetchedResultsController objectAtIndexPath:indexPath];
                theObject = command;
            }
            
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
/*
    CGRect vrect = self.masterView.frame;
    CGRect mrect = self.messages.frame;
    CGRect srect = self.subs.frame;
    CGRect prect = self.pubs.frame;
    
    if (fabs(offset.x) > vrect.size.width / 2 - 4) offset.x = 0;
    if (fabs(offset.y) > vrect.size.height / 2 - 4) offset.y = 0;
    
    srect = CGRectMake(0,
                       0,
                       vrect.size.width / 2 - 4 + offset.x,
                       vrect.size.height / 2 - 4 + offset.y);
    
    if (portrait) {
        mrect = CGRectMake(vrect.size.width / 2 + 4 + offset.x,
                           0,
                           vrect.size.width - (vrect.size.width / 2 - 4 + offset.x),
                           vrect.size.height);
        prect = CGRectMake(0,
                           vrect.size.height / 2 + 4 + offset.y,
                           vrect.size.width / 2 - 4 + offset.x,
                           vrect.size.height - (vrect.size.height / 2 - 4 + offset.y + 8));
    } else {
        mrect = CGRectMake(0,
                           vrect.size.height / 2 + 4 + offset.y,
                           vrect.size.width,
                           vrect.size.height - (vrect.size.height / 2 - 4 + offset.y + 8));
        prect = CGRectMake(vrect.size.width / 2 + 4 + offset.x,
                           0,
                           vrect.size.width - (vrect.size.width / 2 - 4 + offset.x),
                           vrect.size.height / 2 - 4 + offset.y);
    }
    
    DDLogVerbose(@"v=%f/%f/%f/%f, s=%f/%f/%f/%f, p=%f/%f/%f/%f, m=%f/%f/%f/%f",
                 vrect.origin.x, vrect.origin.y, vrect.size.width, vrect.size.height,
                 srect.origin.x, srect.origin.y, srect.size.width, srect.size.height,
                 prect.origin.x, prect.origin.y, prect.size.width, prect.size.height,
                 mrect.origin.x, mrect.origin.y, mrect.size.width, mrect.size.height);

    self.messages.frame = mrect;
    self.subs.frame = srect;
    self.pubs.frame = prect;
 */
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
    //
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
        
        //        MQTTInMemoryPersistence *persistence = [[MQTTInMemoryPersistence alloc] init];
        //        persistence.maxMessages = 1024;
        //        persistence.maxWindowSize = 16;
        //        self.mqttSession.persistence = persistence;
        
        if ((self.session.websocket).boolValue) {
            MQTTWebsocketTransport *websocketTransport = [[MQTTWebsocketTransport alloc] init];
            websocketTransport.host = self.session.host;
            websocketTransport.port = (self.session.port).unsignedIntValue;
            websocketTransport.tls = (self.session.tls).boolValue;
            if ((self.session.tls).boolValue) {
                websocketTransport.allowUntrustedCertificates = (self.session.allowUntrustedCertificates).boolValue;
            }
            self.mqttSession.transport = websocketTransport;
        } else {
            if ((self.session.tls).boolValue) {
                MQTTSSLSecurityPolicyTransport *sslSecurityPolicyTransport = [[MQTTSSLSecurityPolicyTransport alloc] init];
                sslSecurityPolicyTransport.host = self.session.host;
                sslSecurityPolicyTransport.port = (self.session.port).unsignedIntValue;
                sslSecurityPolicyTransport.tls = (self.session.tls).boolValue;
                
                MQTTSSLSecurityPolicy *sslSecurityPolicy = [MQTTSSLSecurityPolicy policyWithPinningMode:MQTTSSLPinningModeNone];
                
                sslSecurityPolicy.allowInvalidCertificates = (self.session.allowUntrustedCertificates).boolValue;
                sslSecurityPolicy.validatesCertificateChain = !(self.session.allowUntrustedCertificates).boolValue;
                sslSecurityPolicy.validatesDomainName = !(self.session.allowUntrustedCertificates).boolValue;
                
                sslSecurityPolicyTransport.securityPolicy = sslSecurityPolicy;
                
                self.mqttSession.transport = sslSecurityPolicyTransport;
            } else {
                MQTTCFSocketTransport *cfSocketTransport = [[MQTTCFSocketTransport alloc] init];
                cfSocketTransport.host = self.session.host;
                
                cfSocketTransport.port = (self.session.port).unsignedIntValue;
                cfSocketTransport.tls = (self.session.tls).boolValue;
                self.mqttSession.transport = cfSocketTransport;
            }
        }
        
        
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
    if (self.session) {
        [self.logsTVC dismissViewControllerAnimated:YES completion:nil];
        self.logsTVC = nil;
        [self.topicsTVC dismissViewControllerAnimated:YES completion:nil];
        self.topicsTVC = nil;
        [self.commandsTVC dismissViewControllerAnimated:YES completion:nil];
        self.commandsTVC = nil;
        switch (self.level.selectedSegmentIndex) {
            case 2:
                self.commandsTVC = [[CommandsTVC alloc] init];
                self.commandsTVC.mother = self;
                self.commandsTVC.tableView = self.messages;
                break;
            case 1:
                self.logsTVC = [[LogsTVC alloc] init];
                self.logsTVC.mother = self;
                self.logsTVC.tableView = self.messages;
                break;
            case 0:
            default:
                self.topicsTVC = [[TopicsTVC alloc] init];
                self.topicsTVC.mother = self;
                self.topicsTVC.tableView = self.messages;
                break;
        }
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

- (NSManagedObjectContext *)queueManagedObjectContext
{
    if (!_queueManagedObjectContext) {
        _queueManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _queueManagedObjectContext.parentContext = self.session.managedObjectContext;
    }
    return _queueManagedObjectContext;
}

- (void)startQueue
{
    self.queueIn += 1;
    [self showQueue];
}

- (void)finishQueue
{
    while (!self.runningSwitch.on) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    }
    self.queueOut += 1;
    [self performSelectorOnMainThread:@selector(showQueue) withObject:nil waitUntilDone:FALSE];
}

- (void)showQueue
{
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
    NSArray *events = @[
                        @"MQTTSessionEventConnected",
                        @"MQTTSessionEventConnectionRefused",
                        @"MQTTSessionEventConnectionClosed",
                        @"MQTTSessionEventConnectionError",
                        @"MQTTSessionEventProtocolError",
                        @"MQTTSessionEventConnectionClosedByBroker"
                        ];
    
    DDLogVerbose(@"handleEvent: %@ (%ld) %@",
                 events[eventCode % [events count]],
                 (long)eventCode,
                 [error description]);
    
    if (eventCode == MQTTSessionEventConnected) {
        [self.subsTVC.tableView reloadData];
        [self.pubsTVC.tableView reloadData];
    }
    
    if (eventCode == MQTTSessionEventConnectionClosed ||
        eventCode == MQTTSessionEventConnectionClosedByBroker) {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate connectionClosed];
    }
    
    if (error) {
        [DetailVC alert:[NSString stringWithFormat: @"Error %@ (%ld) %@",
                                                  events[eventCode % events.count],
                                                  (long)eventCode,
                                                  error.description]];
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

- (void)unsubAckReceivedV5:(MQTTSession *)session msgID:(UInt16)msgID reasonString:(NSString *)reasonString userProperties:(NSArray<NSDictionary<NSString *,NSString *> *> *)userProperties reasonCodes:(NSArray<NSNumber *> *)reasonCodes {
    //
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

- (void)buffered:(MQTTSession *)session flowingIn:(NSUInteger)flowingIn flowingOut:(NSUInteger)flowingOut
{
    DDLogVerbose(@"Connection buffered i%lu o%lu", (unsigned long)flowingIn, (unsigned long)flowingOut);
    if (flowingIn + flowingOut) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    } else {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    }
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


- (void)message:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle mainBundle].infoDictionary[@"CFBundleName"]
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil];
    [alertView show];
    [self performSelector:@selector(messageDismiss:) withObject:alertView afterDelay:0.5];
}

- (void)messageDismiss:(UIAlertView *)alertView {
    [alertView dismissWithClickedButtonIndex:0 animated:true];
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
