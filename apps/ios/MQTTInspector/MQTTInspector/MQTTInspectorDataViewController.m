//
//  MQTTInspectorDataViewController.m
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "MQTTInspectorDataViewController.h"

@interface MQTTInspectorDataViewController ()
@property (weak, nonatomic) IBOutlet UITextView *dataTextView;

@end

@implementation MQTTInspectorDataViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = self.topic;
    self.dataTextView.text = [self dataToString:self.data];
}

- (NSString *)dataToString:(NSData *)data
{
    BOOL binary = FALSE;
    
    for (int i = 0; i < data.length; i++) {
        char c;
        [data getBytes:&c range:NSMakeRange(i, 1)];
    }
    
    NSString *message = [[NSString alloc] init];
    
    for (int i = 0; i < data.length; i++) {
        char c;
        [data getBytes:&c range:NSMakeRange(i, 1)];
        if (!isprint(c)) {
            binary = TRUE;
            break;
        }
        message = [message stringByAppendingFormat:@"%c", c];
    }
    
    if (binary) {
        return [data description];
    }
    return message;
}


@end
