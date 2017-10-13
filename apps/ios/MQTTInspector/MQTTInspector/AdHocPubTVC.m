//
//  AdHocPubTVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 15.11.13.
//  Copyright © 2013-2017 Christoph Krey. All rights reserved.
//

#import "AdHocPubTVC.h"

#import "Model.h"

#import "DataVC.h"
#import "UserPropertiesTVC.h"

@interface AdHocPubTVC ()
@property (weak, nonatomic) IBOutlet UITextField *topicText;
@property (weak, nonatomic) IBOutlet UITextField *dataText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *qosSegment;
@property (weak, nonatomic) IBOutlet UISwitch *retainSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *payloadFormatIndicatorSwitch;
@property (weak, nonatomic) IBOutlet UITextField *publicationExpiryIntervalText;
@property (weak, nonatomic) IBOutlet UITextField *topicAliasText;
@property (weak, nonatomic) IBOutlet UITextField *responseTopicText;
@property (weak, nonatomic) IBOutlet UITextField *correlationDataText;
@property (weak, nonatomic) IBOutlet UITextField *contentTypeText;
@property (weak, nonatomic) IBOutlet UILabel *userPropertiesLabel;

@property (strong, nonatomic) Publication *pub;

@end

@implementation AdHocPubTVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.topicText.delegate = self;
    self.dataText.delegate = self;
    self.publicationExpiryIntervalText.delegate = self;
    self.topicAliasText.delegate = self;
    self.responseTopicText.delegate = self;
    self.correlationDataText.delegate = self;
    self.contentTypeText.delegate = self;
    
    self.pub = [Publication publicationWithName:@"<last>"
                                          topic:@"MQTTInspector"
                                            qos:0
                                       retained:FALSE
                                           data:[@"manual ping %t %c" dataUsingEncoding:NSUTF8StringEncoding] session:self.mother.session
                         inManagedObjectContext:self.mother.session.managedObjectContext];

    [self show];
}

- (void)show {
    self.topicText.text = self.pub.topic;
    self.dataText.text = [[NSString alloc] initWithData:self.pub.data encoding:NSUTF8StringEncoding];
    self.qosSegment.selectedSegmentIndex = (self.pub.qos).intValue;
    self.retainSwitch.on = (self.pub.retained).boolValue;
    self.payloadFormatIndicatorSwitch.on = (self.pub.payloadFormatIndicator).boolValue;
    self.publicationExpiryIntervalText.text = self.pub.publicationExpiryInterval ? self.pub.publicationExpiryInterval.stringValue : nil;
    self.topicAliasText.text = self.pub.topicAlias ? self.pub.topicAlias.stringValue : nil;
    self.responseTopicText.text = self.pub.responseTopic;
    self.correlationDataText.text = [[NSString alloc] initWithData:self.pub.correlationData
                                                          encoding:NSUTF8StringEncoding];
    self.contentTypeText.text = self.pub.contentType;

    if (self.pub.userProperties) {
        NSArray <NSDictionary <NSString *, NSString *> *> *p =
        [NSJSONSerialization JSONObjectWithData:self.pub.userProperties
                                        options:0
                                          error:nil];
        if (p) {
            self.userPropertiesLabel.text = [NSString stringWithFormat:@"%lu",
                                             (unsigned long)p.count];
        } else {
            self.userPropertiesLabel.text = @"0";
        }
    } else {
        self.userPropertiesLabel.text = @"0";
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController respondsToSelector:@selector(setUserProperties:)]) {
        NSArray <NSDictionary <NSString *, NSString *> *> *p;
        if (self.pub.userProperties) {
            p = [NSJSONSerialization JSONObjectWithData:self.pub.userProperties
                                                options:0
                                                  error:nil];
        }
        [segue.destinationViewController performSelector:@selector(setUserProperties:)
                                              withObject:p];
    }
    if ([segue.destinationViewController respondsToSelector:@selector(setEdit:)]) {
        [segue.destinationViewController performSelector:@selector(setEdit:)
                                              withObject:@(true)];
    }
}

- (IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    if ([segue.sourceViewController respondsToSelector:@selector(userProperties)]) {
        NSArray <NSDictionary <NSString *, NSString *> *> *p = [segue.sourceViewController
                                                                performSelector:@selector(userProperties)
                                                                withObject:nil];
        if (p) {
            self.pub.userProperties = [NSJSONSerialization dataWithJSONObject:p
                                                                      options:0
                                                                        error:nil];
        }
    }
    [self show];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)pubNow:(UIBarButtonItem *)sender {
    self.pub.topic = self.topicText.text;
    self.pub.data = [self.dataText.text dataUsingEncoding:NSUTF8StringEncoding];
    self.pub.retained = @(self.retainSwitch.on);
    self.pub.qos = @(self.qosSegment.selectedSegmentIndex);
    if (self.payloadFormatIndicatorSwitch.on) {
        self.pub.payloadFormatIndicator = @(true);
    } else {
        self.pub.payloadFormatIndicator = @(false);
    }

    if (self.contentTypeText.text.length) {
        self.pub.contentType = self.contentTypeText.text;
    } else {
        self.pub.contentType = nil;
    }

    if (self.correlationDataText.text.length) {
        self.pub.correlationData = [self.correlationDataText.text dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        self.pub.correlationData = nil;
    }

    if (self.responseTopicText.text.length) {
        self.pub.responseTopic = self.responseTopicText.text;
    } else {
        self.pub.responseTopic = nil;
    }

    if (self.topicAliasText.text.length) {
        self.pub.topicAlias = @(self.topicAliasText.text.intValue);
    } else {
        self.pub.topicAlias = nil;
    }

    if (self.publicationExpiryIntervalText.text.length) {
        self.pub.publicationExpiryInterval = @(self.publicationExpiryIntervalText.text.intValue);
    } else {
        self.pub.publicationExpiryInterval = nil;
    }

    [self.mother publish:self.pub];
    [self.navigationController popViewControllerAnimated:TRUE];
}

@end