//
//  MQTTInspectorAdHocPubTableViewController.m
//  MQTTInspector
//
//  Created by Christoph Krey on 15.11.13.
//  Copyright © 2013-2016 Christoph Krey. All rights reserved.
//

#import "MQTTInspectorAdHocPubTableViewController.h"

#import "Model.h"

#import "MQTTInspectorDataViewController.h"

@interface MQTTInspectorAdHocPubTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *topicText;
@property (weak, nonatomic) IBOutlet UITextField *dataText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *qosSegment;
@property (weak, nonatomic) IBOutlet UISwitch *retainSwitch;

@property (strong, nonatomic) Publication *pub;

@end

@implementation MQTTInspectorAdHocPubTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.pub = [Publication publicationWithName:@"<last>"
                                          topic:@"MQTTInspector"
                                            qos:0
                                       retained:FALSE
                                           data:[@"manual ping %t %c" dataUsingEncoding:NSUTF8StringEncoding] session:self.mother.session
                         inManagedObjectContext:self.mother.session.managedObjectContext];
    
    self.topicText.text = self.pub.topic;
    self.dataText.text = [[NSString alloc] initWithData:self.pub.data encoding:NSUTF8StringEncoding];
    self.qosSegment.selectedSegmentIndex = [self.pub.qos intValue];
    self.retainSwitch.on = [self.pub.retained boolValue];
    self.topicText.delegate = self;
    self.dataText.delegate = self;
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
    
    [self.mother publish:self.pub];
    [self.navigationController popViewControllerAnimated:TRUE];
}

@end
