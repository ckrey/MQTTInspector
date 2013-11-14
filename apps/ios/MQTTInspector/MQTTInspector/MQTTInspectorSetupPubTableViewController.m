//
//  MQTTInspectorSetupPubTableViewController.m
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "MQTTInspectorSetupPubTableViewController.h"
#import "MQTTInspectorDetailViewController.h"
#import "MQTTInspectorDataViewController.h"

@interface MQTTInspectorSetupPubTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITextField *topicText;
@property (weak, nonatomic) IBOutlet UITextField *dataText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *qosSegment;
@property (weak, nonatomic) IBOutlet UISwitch *retainSwitch;

@end

@implementation MQTTInspectorSetupPubTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = self.pub.name;
    
    self.nameText.text = self.pub.name;
    self.topicText.text = self.pub.topic;
    self.dataText.text = [MQTTInspectorDataViewController dataToString:self.pub.data];
    self.qosSegment.selectedSegmentIndex = [self.pub.qos intValue];
    self.retainSwitch.on = [self.pub.retained boolValue];
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
        [MQTTInspectorDetailViewController alert:@"Duplicate PUB"];
    }

}
- (IBAction)topicChanged:(UITextField *)sender {
    self.pub.topic = sender.text;
}
- (IBAction)dataChanged:(UITextField *)sender {
    self.pub.data = [sender.text dataUsingEncoding:NSUTF8StringEncoding];
}
- (IBAction)qosChanged:(UISegmentedControl *)sender {
    self.pub.qos = @(sender.selectedSegmentIndex);
}
- (IBAction)retainChanged:(UISwitch *)sender {
    self.pub.retained = @(sender.on);
}


@end
