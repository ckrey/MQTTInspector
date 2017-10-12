//
//  MessageInfoTVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 12.10.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//

#import "MessageInfoTVC.h"
#import "SubscriptionIdentifiersTVC.h"
#import "UserPropertiesTVC.h"

@interface MessageInfoTVC ()
@property (weak, nonatomic) IBOutlet UILabel *payloadFormatIndicatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *publicationExpiryIntervalLabel;
@property (weak, nonatomic) IBOutlet UILabel *topicAliasLabel;
@property (weak, nonatomic) IBOutlet UILabel *subscriptionIdentifiersLabel;
@property (weak, nonatomic) IBOutlet UILabel *userPropertiesLabel;
@property (weak, nonatomic) IBOutlet UILabel *responseTopicLabel;
@property (weak, nonatomic) IBOutlet UILabel *correlationDataLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentTypeLabel;

@end

@implementation MessageInfoTVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.payloadFormatIndicatorLabel.text = self.payloadFormatIndicator.stringValue;
    self.publicationExpiryIntervalLabel.text = self.publicationExpiryInterval.stringValue;
    self.topicAliasLabel.text = self.topicAlias.stringValue;
    if (self.subscriptionIdentifiers) {
        NSArray <NSString *> *subscriptionIdentifiersArray = [NSJSONSerialization JSONObjectWithData:self.subscriptionIdentifiers options:0 error:nil];
        self.subscriptionIdentifiersLabel.text = [NSString stringWithFormat:@"%lu",
                                                  (unsigned long)subscriptionIdentifiersArray.count];
    } else {
        self.subscriptionIdentifiersLabel.text = @"0";
    }
    if (self.userProperties) {
        NSArray <NSDictionary <NSString *, NSString *> *> *userPropertiesArray = [NSJSONSerialization JSONObjectWithData:self.userProperties options:0 error:nil];
        self.userPropertiesLabel.text = [NSString stringWithFormat:@"%lu",
                                                  (unsigned long)userPropertiesArray.count];
    } else {
        self.userPropertiesLabel.text = @"0";
    }
    self.responseTopicLabel.text = self.responseTopic;
    self.correlationDataLabel.text = [[NSString alloc] initWithData:self.correlationData
                                                           encoding:NSUTF8StringEncoding];
    self.contentTypeLabel.text = self.contentType;

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController respondsToSelector:@selector(setSubscriptionIdentifiers:)]) {
        [segue.destinationViewController performSelector:@selector(setSubscriptionIdentifiers:)
                                              withObject:self.subscriptionIdentifiers];
    }
    if ([segue.destinationViewController respondsToSelector:@selector(setUserProperties:)]) {
        NSArray <NSDictionary <NSString *, NSString *> *> *userPropertiesArray = [[NSArray alloc] init];
        if (self.userProperties) {
            userPropertiesArray = [NSJSONSerialization JSONObjectWithData:self.userProperties options:0 error:nil];
        }

        [segue.destinationViewController performSelector:@selector(setUserProperties:)
                                              withObject:userPropertiesArray];
    }
    if ([segue.destinationViewController respondsToSelector:@selector(setEdit:)]) {
        [segue.destinationViewController performSelector:@selector(setEdit:)
                                              withObject:@(false)];
    }
}


@end
