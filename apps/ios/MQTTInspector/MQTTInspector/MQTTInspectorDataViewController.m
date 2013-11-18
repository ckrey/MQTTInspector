//
//  MQTTInspectorDataViewController.m
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "MQTTInspectorDataViewController.h"
size_t isutf8(unsigned char *str, size_t len);
/*
 Check if the given unsigned char * is a valid utf-8 sequence.
 
 Return value :
 If the string is valid utf-8, 0 is returned.
 Else the position, starting from 1, is returned.
 
 Valid utf-8 sequences look like this :
 0xxxxxxx
 110xxxxx 10xxxxxx
 1110xxxx 10xxxxxx 10xxxxxx
 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
 111110xx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
 1111110x 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
 */

size_t isutf8(unsigned char *str, size_t len)
{
    size_t i = 0;
    size_t continuation_bytes = 0;
    
    while (i < len)
    {
        if (str[i] <= 0x7F)
            continuation_bytes = 0;
        else if (str[i] >= 0xC0 /*11000000*/ && str[i] <= 0xDF /*11011111*/)
            continuation_bytes = 1;
        else if (str[i] >= 0xE0 /*11100000*/ && str[i] <= 0xEF /*11101111*/)
            continuation_bytes = 2;
        else if (str[i] >= 0xF0 /*11110000*/ && str[i] <= 0xF4 /* Cause of RFC 3629 */)
            continuation_bytes = 3;
        else
            return i + 1;
        i += 1;
        while (i < len && continuation_bytes > 0
               && str[i] >= 0x80
               && str[i] <= 0xBF)
        {
            i += 1;
            continuation_bytes -= 1;
        }
        if (continuation_bytes != 0)
            return i + 1;
    }
    return 0;
}

@interface MQTTInspectorDataViewController ()
@property (weak, nonatomic) IBOutlet UITextView *dataTextView;

@end

@implementation MQTTInspectorDataViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = self.topic;
    self.dataTextView.text = [MQTTInspectorDataViewController dataToString:self.data];
}

+ (NSString *)dataToString:(NSData *)data
{
    for (int i = 0; i < data.length; i++) {
        char c;
        [data getBytes:&c range:NSMakeRange(i, 1)];
    }
    
    NSString *message = [[NSString alloc] init];
    
    for (int i = 0; i < data.length; i++) {
        char c;
        [data getBytes:&c range:NSMakeRange(i, 1)];
        message = [message stringByAppendingFormat:@"%c", c];
    }

    if (isutf8((unsigned char*)[data bytes], data.length) == 0) {
        const char *cp = [message cStringUsingEncoding:NSISOLatin1StringEncoding];
        if (cp) {
            NSString *u = [NSString stringWithUTF8String:cp];
            return [NSString stringWithFormat:@"%@", u];
        } else {
            return [NSString stringWithFormat:@"%@", [data description]];
        }
    }
    return [NSString stringWithFormat:@"%@", [data description]];
}


@end
