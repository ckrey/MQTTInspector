//
//  SessionInfoTVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 30.08.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//

#import "SessionInfoTVC.h"
#import "UserPropertiesTVC.h"
#import <MQTTClient/MQTTWebSocketTransport.h>

@interface SessionInfoTVC ()
@property (weak, nonatomic) IBOutlet UILabel *subscriptionIdentifiersAvailable;
@property (weak, nonatomic) IBOutlet UILabel *url;
@property (weak, nonatomic) IBOutlet UILabel *keepAlive;
@property (weak, nonatomic) IBOutlet UILabel *clientId;
@property (weak, nonatomic) IBOutlet UILabel *sharedSubscriptionAvailable;
@property (weak, nonatomic) IBOutlet UILabel *wildcardSubscriptionAvailable;
@property (weak, nonatomic) IBOutlet UILabel *maximumPacketSize;
@property (weak, nonatomic) IBOutlet UILabel *retainAvailable;
@property (weak, nonatomic) IBOutlet UILabel *maximumQos;
@property (weak, nonatomic) IBOutlet UILabel *topicAliasMaximum;
@property (weak, nonatomic) IBOutlet UILabel *receiveMaximum;
@property (weak, nonatomic) IBOutlet UILabel *reasonString;
@property (weak, nonatomic) IBOutlet UILabel *serverReference;
@property (weak, nonatomic) IBOutlet UILabel *responseInformation;
@property (weak, nonatomic) IBOutlet UILabel *authenticationMethod;
@property (weak, nonatomic) IBOutlet UILabel *authenticationData;
@property (weak, nonatomic) IBOutlet UILabel *userProperties;
@property (weak, nonatomic) IBOutlet UILabel *clientTopicAliasMaximum;
@property (weak, nonatomic) IBOutlet UILabel *sessionExpiryInterval;

@end

@implementation SessionInfoTVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.mqttSession) {
        NSString *scheme = @"???";
        if ([self.mqttSession.transport isKindOfClass:[MQTTCFSocketTransport class]]) {
            MQTTCFSocketTransport *transport = (MQTTCFSocketTransport *)self.mqttSession.transport;
            scheme = transport.tls ? @"mqtts" : @"mqtt";
        } else if ([self.mqttSession.transport isKindOfClass:[MQTTWebsocketTransport class]]) {
            MQTTWebsocketTransport *transport = (MQTTWebsocketTransport *)self.mqttSession.transport;
            scheme = transport.tls ? @"wss" : @"ws";
        }

        self.url.text = [NSString stringWithFormat:@"%@://%@%@:%ld",
                         scheme,
                         self.mqttSession.userName ? [NSString stringWithFormat:@"%@@", self.mqttSession.userName] : @"",
                         self.mqttSession.host,
                         (long)self.mqttSession.port
                         ];

        self.clientId.text = [NSString stringWithFormat:@"%@ \"%@\"/\"%@\"",
                              self.mqttSession.cleanSessionFlag ? @"Clean Session" : @"No Clean Start",
                              self.mqttSession.clientId ? self.mqttSession.clientId : @"(nil)",
                              self.mqttSession.assignedClientIdentifier ? self.mqttSession.assignedClientIdentifier : @"(nil)"
                              ];

        self.keepAlive.text = [NSString stringWithFormat:@"%d/%@/%d",
                               self.mqttSession.keepAliveInterval,
                               self.mqttSession.serverKeepAlive ? self.mqttSession.serverKeepAlive.description : @"-",
                               self.mqttSession.effectiveKeepAlive
                               ];

        self.authenticationMethod.text = self.mqttSession.brokerAuthMethod;
        self.authenticationData.text = self.mqttSession.brokerAuthData.description;
        self.responseInformation.text = self.mqttSession.brokerResponseInformation;
        self.serverReference.text = self.mqttSession.serverReference;
        self.reasonString.text = self.mqttSession.reasonString;
        self.receiveMaximum.text = self.mqttSession.brokerReceiveMaximum.description;
        self.topicAliasMaximum.text = [NSString stringWithFormat:@"%lu/%@",
                                       (unsigned long)self.mqttSession.brokerTopicAliases.count,
                                       self.mqttSession.brokerTopicAliasMaximum.description];
        self.clientTopicAliasMaximum.text = [NSString stringWithFormat:@"%lu/%@",
                                             (unsigned long)self.mqttSession.topicAliases.count,
                                             self.mqttSession.topicAliasMaximum.description];
        self.maximumQos.text = self.mqttSession.maximumQoS.description;
        self.retainAvailable.text = self.mqttSession.retainAvailable.description;
        self.userProperties.text = [NSString stringWithFormat:@"%lu",
                                    (long)self.mqttSession.brokerUserProperties.count
                                    ];
        self.sessionExpiryInterval.text = self.mqttSession.sessionExpiryInterval.description;
        self.maximumPacketSize.text = self.mqttSession.brokerMaximumPacketSize.description;
        self.wildcardSubscriptionAvailable.text = self.mqttSession.wildcardSubscriptionAvailable.description;
        self.subscriptionIdentifiersAvailable.text = self.mqttSession.subscriptionIdentifiersAvailable.description;
        self.sharedSubscriptionAvailable.text = self.mqttSession.sharedSubscriptionAvailable.description;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowUserProperties"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setUserProperties:)]) {
            [segue.destinationViewController performSelector:@selector(setUserProperties:)
                                                  withObject:self.mqttSession.brokerUserProperties];
        }
    }
}



@end
