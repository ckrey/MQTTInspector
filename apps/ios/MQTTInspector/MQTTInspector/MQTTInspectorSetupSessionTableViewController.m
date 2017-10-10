//
//  MQTTInspectorSetupSessionTableViewController.m
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright © 2013-2017 Christoph Krey. All rights reserved.
//

#import "MQTTInspectorSetupSessionTableViewController.h"
#import "Model.h"
#import "MQTTInspectorDetailViewController.h"
#import "MQTTInspectorUserPropertyTVC.h"

@interface MQTTInspectorSetupSessionTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITextField *hostText;
@property (weak, nonatomic) IBOutlet UITextField *portText;
@property (weak, nonatomic) IBOutlet UISwitch *tlsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *authSwitch;
@property (weak, nonatomic) IBOutlet UITextField *userText;
@property (weak, nonatomic) IBOutlet UITextField *passwdText;
@property (weak, nonatomic) IBOutlet UISwitch *clientIdSwitch;
@property (weak, nonatomic) IBOutlet UITextField *clientIdText;
@property (weak, nonatomic) IBOutlet UISwitch *cleansessionSwitch;
@property (weak, nonatomic) IBOutlet UITextField *keepaliveText;
@property (weak, nonatomic) IBOutlet UISwitch *autoConnectSwitch;
@property (weak, nonatomic) IBOutlet UITextField *protocolLevelText;
@property (weak, nonatomic) IBOutlet UITextField *sizeLimitText;
@property (weak, nonatomic) IBOutlet UITextField *sessionExpiryIntervalText;
@property (weak, nonatomic) IBOutlet UISwitch *useWebsocketsSwitch;
@property (weak, nonatomic) IBOutlet UITextField *receiveMaximumText;
@property (weak, nonatomic) IBOutlet UITextField *willDelayIntervalText;
@property (weak, nonatomic) IBOutlet UISwitch *allowUntrustedCertificatesSwitch;
@property (weak, nonatomic) IBOutlet UITextField *maximumPacketSizeText;
@property (weak, nonatomic) IBOutlet UISwitch *requestProblemInformationSwitch;
@property (weak, nonatomic) IBOutlet UITextField *topicAliasMaximumText;
@property (weak, nonatomic) IBOutlet UISwitch *requestReplyInfoSwitch;
@property (weak, nonatomic) IBOutlet UITextField *authMethodText;
@property (weak, nonatomic) IBOutlet UITextField *authDataText;
@property (strong, nonatomic) UIDocumentInteractionController *dic;

@end

@implementation MQTTInspectorSetupSessionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.nameText.delegate = self;
    self.hostText.delegate = self;
    self.portText.delegate = self;
    self.userText.delegate = self;
    self.passwdText.delegate = self;
    self.clientIdText.delegate = self;
    self.keepaliveText.delegate = self;
    self.protocolLevelText.delegate = self;
    self.sizeLimitText.delegate = self;
    self.receiveMaximumText.delegate = self;
    self.maximumPacketSizeText.delegate = self;
    self.willDelayIntervalText.delegate = self;
    self.topicAliasMaximumText.delegate = self;
    self.authMethodText.delegate = self;
    self.authDataText.delegate = self;

    self.title = self.session.name;
    
    self.nameText.text = self.session.name;
    self.hostText.text = self.session.host;
    self.portText.text = [NSString stringWithFormat:@"%@", self.session.port];
    self.tlsSwitch.on = (self.session.tls).boolValue;
    self.allowUntrustedCertificatesSwitch.enabled = self.tlsSwitch.on;
    self.allowUntrustedCertificatesSwitch.on = (self.session.allowUntrustedCertificates).boolValue;
    self.useWebsocketsSwitch.on = (self.session.websocket).boolValue;
    self.authSwitch.on = (self.session.auth).boolValue;
    if ((self.session.auth).boolValue) {
        self.userText.enabled = TRUE;
        self.passwdText.enabled = TRUE;
    } else {
        self.userText.enabled = FALSE;
        self.passwdText.enabled = FALSE;
    }

    self.userText.text = self.session.user;
    self.passwdText.text = self.session.passwd;
    if (self.session.clientid) {
        self.clientIdText.text = self.session.clientid;
        self.clientIdText.enabled = TRUE;
        self.clientIdSwitch.on = TRUE;
    } else {
        self.clientIdText.text = nil;
        self.clientIdText.enabled = FALSE;
        self.clientIdSwitch.on = FALSE;
    }

    self.cleansessionSwitch.on = (self.session.cleansession).boolValue;
    self.keepaliveText.text = [NSString stringWithFormat:@"%@", self.session.keepalive];
    self.allowUntrustedCertificatesSwitch.on = (self.session.allowUntrustedCertificates).boolValue;
    self.useWebsocketsSwitch.on = (self.session.websocket).boolValue;
    self.autoConnectSwitch.on = (self.session.autoconnect).boolValue;
    self.protocolLevelText.text = [NSString stringWithFormat:@"%@", self.session.protocolLevel];
    self.sizeLimitText.text = [NSString stringWithFormat:@"%@", self.session.sizelimit];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"setSessionForFilters:"] ||
        [segue.identifier isEqualToString:@"setSessionForSubs:"] ||
        [segue.identifier isEqualToString:@"setSessionForPubs:"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setSession:)]) {
            [segue.destinationViewController performSelector:@selector(setSession:)
                                                  withObject:self.session];
        }
    } else if ([segue.identifier isEqualToString:@"SessionUserProperties"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setUserProperties:)]) {
            [segue.destinationViewController performSelector:@selector(setUserProperties:)
                                                  withObject:nil];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (IBAction)nameChanged:(UITextField *)sender {
    
    NSString *newName = sender.text;

    Session *existingSession = [Session existSessionWithName:newName inManagedObjectContext:self.session.managedObjectContext];
    if (!existingSession || (existingSession == self.session)) {
        self.session.name = newName;
        self.title = self.session.name;
    } else {
        [MQTTInspectorDetailViewController alert:@"Duplicate Session"];
    }
}
- (IBAction)hostChanged:(UITextField *)sender {
    self.session.host = sender.text;
}
- (IBAction)portChanged:(UITextField *)sender {
    self.session.port = @((sender.text).intValue);
}
- (IBAction)tlsChanged:(UISwitch *)sender {
    self.session.tls = @(sender.on);
    if (sender.on) {
        self.session.port = @(8883);
    } else {
        self.session.port = @(1883);
    }
    self.portText.text = [NSString stringWithFormat:@"%@", self.session.port];
    self.allowUntrustedCertificatesSwitch.enabled = self.tlsSwitch.on;
}

- (IBAction)allowUntrustedCertificatesChanged:(UISwitch *)sender {
    self.session.allowUntrustedCertificates = @(sender.on);
}

- (IBAction)useWebsocketsChanged:(UISwitch *)sender {
    self.session.websocket = @(sender.on);
}

- (IBAction)authChanged:(UISwitch *)sender {
    self.session.auth = @(sender.on);
    if ((self.session.auth).boolValue) {
        self.userText.enabled = TRUE;
        self.passwdText.enabled = TRUE;
    } else {
        self.userText.enabled = FALSE;
        self.passwdText.enabled = FALSE;
    }
}

- (IBAction)userChanged:(UITextField *)sender {
    self.session.user = sender.text;
}

- (IBAction)passwdChanged:(UITextField *)sender {
    self.session.passwd = sender.text;
}

- (IBAction)clientIdSwitched:(UISwitch *)sender {
    if (sender.on) {
        self.clientIdText.text = @"";
        self.session.clientid = self.clientIdText.text;
        self.clientIdText.enabled = TRUE;
    } else {
        self.clientIdText.text = nil;
        self.session.clientid = nil;
        self.clientIdText.enabled = FALSE;
    }
}

- (IBAction)clientIdChanged:(UITextField *)sender {
    self.session.clientid = sender.text;
}

- (IBAction)cleansessionChanged:(UISwitch *)sender {
    self.session.cleansession = @(sender.on);
}

- (IBAction)keepalvieChanged:(UITextField *)sender {
    self.session.keepalive = @((sender.text).intValue);
}

- (IBAction)autoConnectChanged:(UISwitch *)sender {
    self.session.autoconnect = @(sender.on);
}

- (IBAction)dnssrvSelected:(UIStoryboardSegue *)segue
{
    self.hostText.text = self.session.host;
    self.portText.text = [NSString stringWithFormat:@"%@", self.session.port];
}
- (IBAction)protocolLevelChanged:(UITextField *)sender {
    self.session.protocolLevel = @((sender.text).intValue);
}

- (IBAction)sizeLimitChanged:(UITextField *)sender {
    self.session.sizelimit = @((sender.text).intValue);
}

- (IBAction)send:(UIBarButtonItem *)sender {
    NSMutableArray *subs = [[NSMutableArray alloc] init];
    for (Subscription *sub in self.session.hasSubs) {
        [subs addObject:@{@"topic": (sub.topic).description,
                          @"qos": (sub.qos).description
                          }];
    }
    
    NSMutableArray *pubs = [[NSMutableArray alloc] init];
    for (Publication *pub in self.session.hasPubs) {
        [pubs addObject:@{@"name": (pub.name).description,
                          @"topic": (pub.topic).description,
                          @"qos": (pub.qos).description,
                          @"retained": (pub.retained).description
                          }];
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"_type"] = @"MQTTInspector-Session";
    dict[@"name"] = self.session.name;
    dict[@"host"] = self.session.host;
    dict[@"port"] = self.session.port;
    dict[@"tls"] = self.session.tls;
    dict[@"auth"] = self.session.auth;
    dict[@"user"] = self.session.user;
    dict[@"passwd"] = self.session.passwd;
    dict[@"clientid"] = self.session.clientid;
    dict[@"cleansession"] = self.session.cleansession;
    dict[@"keepalive"] = self.session.keepalive;
    dict[@"websocket"] = self.session.websocket;
    dict[@"allowUntrustedCertificates"] = self.session.allowUntrustedCertificates;
    dict[@"autoconnect"] = self.session.autoconnect;
    dict[@"protocollevel"] = self.session.protocolLevel;
    dict[@"sizeLimit"] = self.session.sizelimit;
    dict[@"includefilter"] = self.session.includefilter;
    dict[@"attributefilter"] = self.session.attributefilter;
    dict[@"datafilter"] = self.session.datafilter;
    dict[@"topicfilter"] = self.session.topicfilter;
    dict[@"sessionExpiryInterval"] = self.session.sessionExpiryInterval;
    dict[@"receiveMaximum"] = self.session.receiveMaximum;
    dict[@"maximumPacketSize"] = self.session.maximumPacketSize;
    dict[@"willDelay"] = self.session.willDelay;
    dict[@"topicAliasMaximum"] = self.session.topicAliasMaximum;
    dict[@"requestProblemInformation"] = self.session.requestProblemInformation;
    dict[@"requestReplyInfo"] = self.session.requestReplyInfo;
    if (self.session.userProperties) {
        dict[@"userProperties"] = [NSJSONSerialization JSONObjectWithData:self.session.userProperties
                                                                  options:0
                                                                    error:nil];
    } else {
        dict[@"userProperties"] = nil;
    }

    dict[@"authMethod"] = self.session.authMethod;
    if (self.session.authData) {
        dict[@"authData"] = [[NSString alloc] initWithData:self.session.authData
                                                  encoding:NSUTF8StringEncoding];
    } else {
        dict[@"authData"] = nil;
    }
    dict[@"subs"] = subs;
    dict[@"pubs"] = pubs;

    NSError *error;
    NSData *myData = [NSJSONSerialization dataWithJSONObject:dict
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:&error];
    
    NSURL *directoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    NSString *fileName = [NSString stringWithFormat:@"session.mqti"];
    NSURL *fileURL = [directoryURL URLByAppendingPathComponent:fileName];
    

    [[NSFileManager defaultManager] createFileAtPath:fileURL.path
                                            contents:myData
                                          attributes:nil];
    
    self.dic = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    self.dic.delegate = self;
    [self.dic presentOptionsMenuFromBarButtonItem:sender animated:YES];
    
}

@end
