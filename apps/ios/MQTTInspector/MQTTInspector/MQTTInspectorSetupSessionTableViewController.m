//
//  MQTTInspectorSetupSessionTableViewController.m
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "MQTTInspectorSetupSessionTableViewController.h"

@interface MQTTInspectorSetupSessionTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITextField *hostText;
@property (weak, nonatomic) IBOutlet UITextField *portText;
@property (weak, nonatomic) IBOutlet UISwitch *tlsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *authSwitch;
@property (weak, nonatomic) IBOutlet UITextField *userText;
@property (weak, nonatomic) IBOutlet UITextField *passwdText;
@property (weak, nonatomic) IBOutlet UITextField *clientIdText;
@property (weak, nonatomic) IBOutlet UISwitch *cleansessionSwitch;
@property (weak, nonatomic) IBOutlet UITextField *keepaliveText;

@end

@implementation MQTTInspectorSetupSessionTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.session) {
        
        self.nameText.text = self.session.name;
        self.hostText.text = self.session.host;
        self.portText.text = [NSString stringWithFormat:@"%@", self.session.port];
        self.tlsSwitch.on = [self.session.tls boolValue];
        self.authSwitch.on = [self.session.auth boolValue];
        self.userText.text = self.session.user;
        self.passwdText.text = self.session.passwd;
        self.clientIdText.text = self.session.clientid;
        self.cleansessionSwitch.on = [self.session.cleansession boolValue];
        self.keepaliveText.text = [NSString stringWithFormat:@"%@", self.session.keepalive];
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"setSession:"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setSession:)]) {
            [segue.destinationViewController performSelector:@selector(setSession:)
                                                  withObject:self.session];
        }
    }
}


- (IBAction)save:(UIBarButtonItem *)sender {
    NSLog(@"save");
}

@end
