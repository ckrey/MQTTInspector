//
//  MQTTInspectorAdHocPubTableViewController.m
//  MQTTInspector
//
//  Created by Christoph Krey on 15.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "MQTTInspectorAdHocPubTableViewController.h"

@interface MQTTInspectorAdHocPubTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *topicText;
@property (weak, nonatomic) IBOutlet UITextField *dataText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *qosSegment;
@property (weak, nonatomic) IBOutlet UISwitch *retainSwitch;

@end

@implementation MQTTInspectorAdHocPubTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    self.topicText.text = @"MQTTInspector";
    self.dataText.text = @"manual ping";
    self.qosSegment.selectedSegmentIndex = 0;
    self.retainSwitch.on = FALSE;
}


- (IBAction)pubNow:(UIButton *)sender {
    [self.mother.mqttSession publishData:[self.dataText.text dataUsingEncoding:NSUTF8StringEncoding]
                                 onTopic:self.topicText.text
                                  retain:self.retainSwitch.on
                                     qos:self.qosSegment.selectedSegmentIndex];
}

@end
