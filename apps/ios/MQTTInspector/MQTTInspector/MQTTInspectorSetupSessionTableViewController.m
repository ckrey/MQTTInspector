//
//  MQTTInspectorSetupSessionTableViewController.m
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "MQTTInspectorSetupSessionTableViewController.h"
#import "Session+Create.h"
#import "MQTTInspectorDetailViewController.h"

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
    
    self.title = self.session.name;
    
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"setSession:"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setSession:)]) {
            [segue.destinationViewController performSelector:@selector(setSession:)
                                                  withObject:self.session];
        }
    }
}
- (IBAction)nameChanged:(UITextField *)sender {
    
    NSString *newName = sender.text;
    
    Session *existingSession = [Session existSessionWithName:newName inManagedObjectContext:self.session.managedObjectContext];
    if (!existingSession || (existingSession == self.session)) {
        self.session.name = newName;
        self.title = self.session.name;
    } else {
        [MQTTInspectorDetailViewController alert:@"Duplicate Session"];
    }
}
- (IBAction)hostChanged:(UITextField *)sender {
    self.session.host = sender.text;
}
- (IBAction)portChanged:(UITextField *)sender {
    self.session.port = @([sender.text intValue]);
}
- (IBAction)tlsChanged:(UISwitch *)sender {
    self.session.tls = @(sender.on);
}
- (IBAction)authChanged:(UISwitch *)sender {
    self.session.auth = @(sender.on);
}
- (IBAction)userChanged:(UITextField *)sender {
    self.session.user = sender.text;
}
- (IBAction)passwdChanged:(UITextField *)sender {
    self.session.passwd = sender.text;
}
- (IBAction)clientIdChanged:(UITextField *)sender {
    self.session.clientid = sender.text;
}
- (IBAction)cleansessionChanged:(UISwitch *)sender {
    self.session.cleansession = @(sender.on);
}
- (IBAction)keepalvieChanged:(UITextField *)sender {
    self.session.keepalive = @([sender.text intValue]);
}

@end
