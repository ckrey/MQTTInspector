//
//  MQTTInspectorSetupSubTableViewController.m
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright © 2013-2016 Christoph Krey. All rights reserved.
//

#import "MQTTInspectorSetupSubTableViewController.h"

#import "Model.h"


@interface MQTTInspectorSetupSubTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *topicText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *qosSegment;

@end

@implementation MQTTInspectorSetupSubTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = self.sub.topic;
    
    self.topicText.text = self.sub.topic;
    self.qosSegment.selectedSegmentIndex = [self.sub.qos intValue];
    self.topicText.delegate = self;
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

@end
