//
//  SessionInfoTVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 30.08.17.
//  Copyright © 2017-2019 Christoph Krey. All rights reserved.
//

#import "SessionInfoTVC.h"
#import "UserPropertiesTVC.h"
#import "TopicAliasesTVC.h"

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
        if ([self.mqttSession.transport isKindOfClass:[MQTTNWTransport class]]) {
            MQTTNWTransport *transport = (MQTTNWTransport *)self.mqttSession.transport;
            if (transport.ws) {
                scheme = transport.tls ? @"wss" : @"ws";
            } else {
                scheme = transport.tls ? @"mqtts" : @"mqtt";
            }
        }

        self.url.text = [NSString stringWithFormat:@"%@://%@%@:%ld",
                         scheme,
                         self.mqttSession.userName ? [NSString stringWithFormat:@"%@@", self.mqttSession.userName] : @"",
                         self.mqttSession.host,
                         (long)self.mqttSession.port
                         ];

        self.clientId.text = [NSString stringWithFormat:@"%d/%d/%@/%@",
                              self.mqttSession.cleanSessionFlag,
                              self.mqttSession.sessionPresent,
                              self.mqttSession.clientId ? self.mqttSession.clientId : @"(not specified)",
                              self.mqttSession.assignedClientIdentifier ? self.mqttSession.assignedClientIdentifier : @"(not specified)"
                              ];

        self.keepAlive.text = [NSString stringWithFormat:@"%d/%@/%d",
                               self.mqttSession.keepAliveInterval,
                               self.mqttSession.serverKeepAlive ? self.mqttSession.serverKeepAlive.description : @"(not specified)",
                               self.mqttSession.effectiveKeepAlive
                               ];

        self.authenticationMethod.text = self.mqttSession.brokerAuthMethod ? self.mqttSession.brokerAuthMethod : @"(not specified)";

        self.authenticationData.text = self.mqttSession.brokerAuthData ? self.mqttSession.brokerAuthData.description : @"(not specified)";

        self.responseInformation.text = self.mqttSession.brokerResponseInformation ? self.mqttSession.brokerResponseInformation : @"(not specified)";

        self.serverReference.text = self.mqttSession.serverReference ? self.mqttSession.serverReference : @"(not specified)";

        self.reasonString.text = self.mqttSession.reasonString ? self.mqttSession.reasonString : @"(not specified)";

        self.receiveMaximum.text = self.mqttSession.brokerReceiveMaximum ? self.mqttSession.brokerReceiveMaximum.stringValue : @"(not specified, default 65,535)";

        self.topicAliasMaximum.text = [NSString stringWithFormat:@"%lu/%@",
                                       (unsigned long)self.mqttSession.brokerTopicAliases.count,
                                       self.mqttSession.brokerTopicAliasMaximum ? self.mqttSession.brokerTopicAliasMaximum.stringValue : @"(not specified, default 0)"];

        self.clientTopicAliasMaximum.text = [NSString stringWithFormat:@"%lu/%@",
                                             (unsigned long)self.mqttSession.topicAliases.count,
                                             self.mqttSession.topicAliasMaximum ? self.mqttSession.topicAliasMaximum.stringValue : @"(not specified, default 0)"];

        self.maximumQos.text = self.mqttSession.maximumQoS ? self.mqttSession.maximumQoS.stringValue : @"(not specified, default 2)";

        self.retainAvailable.text = self.mqttSession.retainAvailable ? self.mqttSession.retainAvailable.boolValue ? @"true" : @"false" : @"(not specified, default true)";

        self.userProperties.text = [NSString stringWithFormat:@"%lu",
                                    (long)self.mqttSession.brokerUserProperties.count
                                    ];
        self.sessionExpiryInterval.text = self.mqttSession.sessionExpiryInterval ? self.mqttSession.sessionExpiryInterval.stringValue : @"(not specified, default 0)";

        self.maximumPacketSize.text = self.mqttSession.brokerMaximumPacketSize ? self.mqttSession.brokerMaximumPacketSize.stringValue : @"(not specified)";

        self.wildcardSubscriptionAvailable.text = self.mqttSession.wildcardSubscriptionAvailable ? self.mqttSession.wildcardSubscriptionAvailable.boolValue ? @"true" : @"false" : @"(not specified, default true)";

        self.subscriptionIdentifiersAvailable.text = self.mqttSession.subscriptionIdentifiersAvailable ? self.mqttSession.subscriptionIdentifiersAvailable.boolValue ? @"true" : @"false" : @"(not specified, default true)";

        self.sharedSubscriptionAvailable.text = self.mqttSession.sharedSubscriptionAvailable ? self.mqttSession.sharedSubscriptionAvailable.boolValue ? @"true" : @"false" : @"(not specified, default true)";
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowUserProperties"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setUserProperties:)]) {
            [segue.destinationViewController performSelector:@selector(setUserProperties:)
                                                  withObject:self.mqttSession.brokerUserProperties];
        }
    }
    if ([segue.identifier isEqualToString:@"ShowBrokerTopicAliases"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setTopicAliases:)]) {
            [segue.destinationViewController performSelector:@selector(setTopicAliases:)
                                                  withObject:self.mqttSession.brokerTopicAliases];
        }
    }
    if ([segue.identifier isEqualToString:@"ShowClientTopicAliases"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setTopicAliases:)]) {
            [segue.destinationViewController performSelector:@selector(setTopicAliases:)
                                                  withObject:self.mqttSession.topicAliases];
        }
    }
}



@end
