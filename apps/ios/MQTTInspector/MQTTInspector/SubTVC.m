//
//  SubTVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright © 2013-2017 Christoph Krey. All rights reserved.
//

#import "SubTVC.h"
#import "DetailVC.h"

#import "Model.h"


@interface SubTVC ()
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITextField *topicText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *qosSegment;
@property (weak, nonatomic) IBOutlet UISwitch *noLocalSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *retainAsPublishedSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *retainHandlingSegment;
@property (weak, nonatomic) IBOutlet UITextField *subscriptionIdentiferText;

@end

@implementation SubTVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = self.sub.topic;

    self.nameText.text = self.sub.name;
    self.topicText.text = self.sub.topic;
    self.topicText.delegate = self;

    self.qosSegment.selectedSegmentIndex = (self.sub.qos).intValue;
    self.noLocalSwitch.on = (self.sub.noLocal).boolValue;
    self.retainAsPublishedSwitch.on = (self.sub.retainAsPublished).boolValue;
    self.retainHandlingSegment.selectedSegmentIndex = self.sub.retainHandling.intValue;

    self.subscriptionIdentiferText.text = self.sub.susbscriptionIdentifier.stringValue;
    self.subscriptionIdentiferText.delegate = self;
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
    self.sub.susbscriptionIdentifier = @(sender.text.integerValue);
}

@end
