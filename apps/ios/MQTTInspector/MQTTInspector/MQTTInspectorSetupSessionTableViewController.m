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
@property (weak, nonatomic) IBOutlet UIPickerView *servicePicker;

@property (strong, nonatomic) SRVResolver *resolver;
@property (strong, nonatomic) NSMutableArray *resolverResults;

@end

@implementation MQTTInspectorSetupSessionTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.resolverResults = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.servicePicker.delegate = self;
    self.servicePicker.dataSource = self;
    
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

- (void)viewWillDisappear:(BOOL)animated
{
    [self.resolver stop];
    [super viewWillDisappear:animated];
}

#include <netdb.h>
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
- (IBAction)domainChanged:(UITextField *)sender {
    NSString *service = [NSString stringWithFormat:@"%@._tcp.%@.",
                         [self.session.tls boolValue] ? @"_secure-mqtt" : @"_mqtt",
                         sender.text];
    [self.resolverResults removeAllObjects];
    [self.servicePicker reloadAllComponents];
    [self getService:service];
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

- (void)getService:(NSString *)srvName
{
    self.resolver = [[SRVResolver alloc] initWithSRVName:srvName];
    self.resolver.delegate = self;
    
    [self.resolver start];
}

- (void)srvResolver:(SRVResolver *)resolver didReceiveResult:(NSDictionary *)result
{
    NSLog(@"didReceiveResult %@", result);
    [self.resolverResults addObject:result];
    [self.servicePicker reloadAllComponents];
}

- (void)srvResolver:(SRVResolver *)resolver didStopWithError:(NSError *)error
{
    NSLog(@"didStopWithError %@", error);
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"didSelectRow %d", row);
    self.hostText.text = [self.resolverResults[row] objectForKey:kSRVResolverTarget];
    self.session.host = [self.resolverResults[row] objectForKey:kSRVResolverTarget];
    
    self.portText.text = [NSString stringWithFormat:@"%@",
                          [self.resolverResults[row] objectForKey:kSRVResolverPort]];
    self.session.port = @([[self.resolverResults[row] objectForKey:kSRVResolverPort] intValue]);
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.resolverResults count];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 32;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *text = [NSString stringWithFormat:@"%@:%d",
                      [self.resolverResults[row] objectForKey:kSRVResolverTarget],
                      [[self.resolverResults[row] objectForKey:kSRVResolverPort    ] intValue]
                      ];
    return text;
}

-  (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return self.servicePicker.bounds.size.width;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

@end
