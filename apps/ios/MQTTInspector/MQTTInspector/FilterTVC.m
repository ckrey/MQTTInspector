//
//  FilterTVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 27.01.14.
//  Copyright © 2014-2020 Christoph Krey. All rights reserved.
//

#import "FilterTVC.h"
#import "AppDelegate.h"
#import "DetailVC.h"

@interface FilterTVC ()
@property (weak, nonatomic) IBOutlet UITextView *topicFilter;
@property (weak, nonatomic) IBOutlet UITextView *dataFilter;
@property (weak, nonatomic) IBOutlet UITextView *attributeFilter;
@property (weak, nonatomic) IBOutlet UISwitch *filterInclude;

@end

@implementation FilterTVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.topicFilter.text = self.session.topicfilter ? self.session.topicfilter : @".*";
    self.dataFilter.text = self.session.datafilter ? self.session.datafilter : @".*";
    self.attributeFilter.text = self.session.attributefilter ? self.session.attributefilter : @".*";
    self.filterInclude.on = self.session.includefilter ? (self.session.includefilter).boolValue : TRUE;
    self.topicFilter.delegate = self;
    self.dataFilter.delegate = self;
    self.attributeFilter.delegate = self;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    NSError *error;
    NSRegularExpression *regex;
    
    regex = [NSRegularExpression regularExpressionWithPattern:self.attributeFilter.text options:0 error:&error];
    if (!regex) {
        [DetailVC alert:[NSString stringWithFormat:@"Invalid regex '%@' for attribute filter (%@)", self.attributeFilter.text, error]];
    }
    
    regex = [NSRegularExpression regularExpressionWithPattern:self.dataFilter.text options:0 error:&error];
    if (!regex) {
        [DetailVC alert:[NSString stringWithFormat:@"Invalid regex '%@' for data filter (%@)", self.dataFilter.text, error]];
    }
    
    regex = [NSRegularExpression regularExpressionWithPattern:self.topicFilter.text options:0 error:&error];
    if (!regex) {
        [DetailVC alert:[NSString stringWithFormat:@"Invalid regex '%@' for topic filter (%@)", self.topicFilter.text, error]];
    }
    
    self.session.topicfilter = self.topicFilter.text;
    self.session.datafilter = self.dataFilter.text;
    self.session.attributefilter = self.attributeFilter.text;
    self.session.includefilter = @(self.filterInclude.on);
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate saveContext];
}

@end
