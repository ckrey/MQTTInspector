//
//  SubTVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright © 2013-2017 Christoph Krey. All rights reserved.
//

#import "SubTVC.h"
#import "DetailVC.h"
#import "UserPropertiesTVC.h"

#import "Model.h"


@interface SubTVC ()
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITextField *topicText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *qosSegment;
@property (weak, nonatomic) IBOutlet UISwitch *noLocalSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *retainAsPublishedSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *retainHandlingSegment;
@property (weak, nonatomic) IBOutlet UITextField *subscriptionIdentiferText;
@property (weak, nonatomic) IBOutlet UILabel *userPropertiesLabel;

@end

@implementation SubTVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.topicText.delegate = self;
    self.subscriptionIdentiferText.delegate = self;

    [self show];
}

- (void)show {
    self.title = self.sub.topic;

    self.nameText.text = self.sub.name;
    self.topicText.text = self.sub.topic;

    self.qosSegment.selectedSegmentIndex = (self.sub.qos).intValue;
    self.noLocalSwitch.on = (self.sub.noLocal).boolValue;
    self.retainAsPublishedSwitch.on = (self.sub.retainAsPublished).boolValue;
    self.retainHandlingSegment.selectedSegmentIndex = self.sub.retainHandling.intValue;

    self.subscriptionIdentiferText.text = self.sub.susbscriptionIdentifier.stringValue;

    if (self.sub.userProperties) {
        NSArray <NSDictionary <NSString *, NSString *> *> *p =
        [NSJSONSerialization JSONObjectWithData:self.sub.userProperties
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
        if (self.sub.userProperties) {
            p = [NSJSONSerialization JSONObjectWithData:self.sub.userProperties
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
            self.sub.userProperties = [NSJSONSerialization dataWithJSONObject:p
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

- (IBAction)topicChanged:(UITextField *)sender {
    self.sub.topic = sender.text;
    self.title = self.sub.topic;

}
- (IBAction)qosChanged:(UISegmentedControl *)sender {
    self.sub.qos = @(sender.selectedSegmentIndex);
}
- (IBAction)noLocalChanged:(UISwitch *)sender {
    self.sub.noLocal = @(sender.on);
}
- (IBAction)retainAsPublishedChanged:(UISwitch *)sender {
    self.sub.retainAsPublished = @(sender.on);
}
- (IBAction)retainHandlingChanged:(UISegmentedControl *)sender {
    self.sub.retainHandling = @(sender.selectedSegmentIndex);
}
- (IBAction)nameChanged:(UITextField *)sender {
    NSString *newName = sender.text;

    Subscription *existingSub = [Subscription existsSubscriptionWithName:newName
                                                                 session:self.sub.belongsTo
                                                  inManagedObjectContext:self.sub.managedObjectContext];
    if (!existingSub || (existingSub == self.sub)) {
        self.sub.name = newName;
        self.title = self.sub.name;

    } else {
        [DetailVC alert:@"Duplicate SUB"];
    }
}

- (IBAction)subscriptionIdentifierChanged:(UITextField *)sender {
    if (sender.text.length > 0) {
        self.sub.susbscriptionIdentifier = @(sender.text.integerValue);
    } else {
        self.sub.susbscriptionIdentifier = nil;
    }
}

@end
