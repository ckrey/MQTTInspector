//
//  UserPropertyTVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 10.10.17.
//  Copyright © 2017-2018 Christoph Krey. All rights reserved.
//

#import "UserPropertyTVC.h"

@interface UserPropertyTVC ()
@property (weak, nonatomic) IBOutlet UITextField *key;
@property (weak, nonatomic) IBOutlet UITextField *value;

@end

@implementation UserPropertyTVC

- (IBAction)keyChanged:(UITextField *)sender {
    [self.keyValue removeAllObjects];
    self.keyValue[sender.text] = self.value.text;
    [self show];
}

- (IBAction)valueChanged:(UITextField *)sender {
    self.keyValue[self.key.text] = sender.text;
    [self show];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.key.delegate = self;
    self.value.delegate = self;

    [self show];
}

- (void)show {
    for (NSString *key in self.keyValue.allKeys) {
        self.key.text = key;
        self.value.text = self.keyValue[key];
        break;
    }
}

@end
