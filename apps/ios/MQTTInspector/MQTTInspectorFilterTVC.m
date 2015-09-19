//
//  MQTTInspectorFilterTVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 27.01.14.
//  Copyright (c) 2014 Christoph Krey. All rights reserved.
//

#import "MQTTInspectorFilterTVC.h"

@interface MQTTInspectorFilterTVC ()
@property (weak, nonatomic) IBOutlet UITextView *topicFilter;
@property (weak, nonatomic) IBOutlet UITextView *dataFilter;
@property (weak, nonatomic) IBOutlet UITextView *attributeFilter;
@property (weak, nonatomic) IBOutlet UISwitch *filterInclude;

@end

@implementation MQTTInspectorFilterTVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.topicFilter.text = self.mother.session.topicfilter ? self.mother.session.topicfilter : @".*";
    self.dataFilter.text = self.mother.session.datafilter ? self.mother.session.datafilter : @".*";
    self.attributeFilter.text = self.mother.session.attributefilter ? self.mother.session.attributefilter : @".*";
    self.filterInclude.on = self.mother.session.includefilter ? [self.mother.session.includefilter boolValue] : TRUE;
    self.topicFilter.delegate = self;
    self.dataFilter.delegate = self;
    self.attributeFilter.delegate = self;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    return YES;
}

- (IBAction)save:(UIButton *)sender {
    NSError *error;
    NSRegularExpression *regex;
    
    regex = [NSRegularExpression regularExpressionWithPattern:self.attributeFilter.text options:0 error:&error];
    if (!regex) {
        [MQTTInspectorDetailViewController alert:[NSString stringWithFormat:@"Invalid regex '%@' for attribute filter (%@)", self.attributeFilter.text, error]];
    }
    
    regex = [NSRegularExpression regularExpressionWithPattern:self.dataFilter.text options:0 error:&error];
    if (!regex) {
        [MQTTInspectorDetailViewController alert:[NSString stringWithFormat:@"Invalid regex '%@' for data filter (%@)", self.dataFilter.text, error]];
    }
    
    regex = [NSRegularExpression regularExpressionWithPattern:self.topicFilter.text options:0 error:&error];
    if (!regex) {
        [MQTTInspectorDetailViewController alert:[NSString stringWithFormat:@"Invalid regex '%@' for topic filter (%@)", self.topicFilter.text, error]];
    }
    
    self.mother.session.topicfilter = self.topicFilter.text;
    self.mother.session.datafilter = self.dataFilter.text;
    self.mother.session.attributefilter = self.attributeFilter.text;
    self.mother.session.includefilter = @(self.filterInclude.on);
}


@end
