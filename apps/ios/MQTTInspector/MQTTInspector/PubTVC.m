//
//  PubTVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright © 2013-2020 Christoph Krey. All rights reserved.
//

#import "PubTVC.h"
#import "DetailVC.h"
#import "DataVC.h"
#import "UserPropertiesTVC.h"

#import "Model.h"

@interface PubTVC ()
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITextField *topicText;
@property (weak, nonatomic) IBOutlet UITextField *dataText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *qosSegment;
@property (weak, nonatomic) IBOutlet UISwitch *retainSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *payloadFormatIndicatorSwitch;
@property (weak, nonatomic) IBOutlet UITextField *messageExpiryIntervalText;
@property (weak, nonatomic) IBOutlet UITextField *topicAliasText;
@property (weak, nonatomic) IBOutlet UITextField *responseTopicText;
@property (weak, nonatomic) IBOutlet UITextField *correlationDataText;
@property (weak, nonatomic) IBOutlet UITextField *contentTypeText;
@property (weak, nonatomic) IBOutlet UILabel *userPropertiesLabel;

@end

@implementation PubTVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.nameText.delegate = self;
    self.topicText.delegate = self;
    self.dataText.delegate = self;
    self.dataText.delegate = self;
    self.messageExpiryIntervalText.delegate = self;
    self.topicAliasText.delegate = self;
    self.topicAliasText.delegate = self;
    self.responseTopicText.delegate = self;
    self.correlationDataText.delegate = self;
    self.contentTypeText.delegate = self;

    [self show];
}

- (void)show {
    self.title = self.pub.name;
    
    self.nameText.text = self.pub.name;
    self.topicText.text = self.pub.topic;
    self.dataText.text = [[NSString alloc] initWithData:self.pub.data encoding:NSUTF8StringEncoding];
    self.qosSegment.selectedSegmentIndex = (self.pub.qos).intValue;
    self.retainSwitch.on = (self.pub.retained).boolValue;
    self.payloadFormatIndicatorSwitch.on = (self.pub.payloadFormatIndicator).boolValue;
    self.messageExpiryIntervalText.text = self.pub.messageExpiryInterval ? self.pub.messageExpiryInterval.stringValue : nil;
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

- (IBAction)nameChanged:(UITextField *)sender {
    NSString *newName = sender.text;
    
    Publication *existingPub = [Publication existsPublicationWithName:newName
                                                             session:self.pub.belongsTo
                                              inManagedObjectContext:self.pub.managedObjectContext];
    if (!existingPub || (existingPub == self.pub)) {
        self.pub.name = newName;
        self.title = self.pub.name;

    } else {
        [DetailVC alert:@"Duplicate PUB"];
    }

}
- (IBAction)topicChanged:(UITextField *)sender {
    self.pub.topic = sender.text;
}

- (IBAction)dataChanged:(UITextField *)sender {
    self.pub.data = [sender.text dataUsingEncoding:NSUTF8StringEncoding];
}

- (IBAction)contentTypeChanged:(UITextField *)sender {
    if (sender.text.length) {
        self.pub.contentType = sender.text;
    } else {
        self.pub.contentType = nil;
    }
}

- (IBAction)qosChanged:(UISegmentedControl *)sender {
    self.pub.qos = @(sender.selectedSegmentIndex);
}

- (IBAction)correlationDataChanged:(UITextField *)sender {
    if (sender.text.length) {
        self.pub.correlationData = [sender.text dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        self.pub.correlationData = nil;
    }
}

- (IBAction)responseTopicChanged:(UITextField *)sender {
    if (sender.text.length) {
        self.pub.responseTopic = sender.text;
    } else {
        self.pub.responseTopic = nil;
    }
}

- (IBAction)retainChanged:(UISwitch *)sender {
    self.pub.retained = @(sender.on);
}

- (IBAction)topicAliasChanged:(UITextField *)sender {
    if (sender.text.length) {
        self.pub.topicAlias = @(sender.text.intValue);
    } else {
        self.pub.topicAlias = nil;
    }
}

- (IBAction)messageExpiryIntervalChanged:(UITextField *)sender {
    if (sender.text.length) {
        self.pub.messageExpiryInterval = @(sender.text.intValue);
    } else {
        self.pub.messageExpiryInterval = nil;
    }
}

@end
