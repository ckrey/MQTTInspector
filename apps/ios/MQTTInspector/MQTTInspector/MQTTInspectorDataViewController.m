//
//  MQTTInspectorDataViewController.m
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#define SB

#import "MQTTInspectorDataViewController.h"
#ifdef SB
#import "SBJson4.h"
#endif

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
@property (weak, nonatomic) IBOutlet UITextField *attributesTextView;
@property (weak, nonatomic) IBOutlet UIImageView *justupdatedImageView;
@property (weak, nonatomic) IBOutlet UISwitch *formatSwitch;

@end

@implementation MQTTInspectorDataViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.formatSwitch.on = TRUE;
    
    if ([self.object isKindOfClass:[Topic class]]) {
        Topic *topic = (Topic *)self.object;
        [topic addObserver:self forKeyPath:@"justupdated"
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                        context:nil];
        [topic addObserver:self forKeyPath:@"timestamp"
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                        context:nil];
        [topic addObserver:self forKeyPath:@"qos"
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                        context:nil];
        [topic addObserver:self forKeyPath:@"retain"
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                        context:nil];
        [topic addObserver:self forKeyPath:@"mid"
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                        context:nil];
        [topic addObserver:self forKeyPath:@"count"
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                        context:nil];
        [topic addObserver:self forKeyPath:@"data"
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                        context:nil];
    }

    [self show];
}

- (void)show
{
    if ([self.object isKindOfClass:[Topic class]]) {
        Topic *topic = (Topic *)self.object;
        self.title = [topic attributeTextPart2];
        self.attributesTextView.text = [NSString stringWithFormat:@"%@ %@",
                                        [topic attributeTextPart1],
                                        [topic attributeTextPart3]];
        self.dataTextView.text = [self dataToPrettyString:topic.data];
    } else if ([self.object isKindOfClass:[Message class]]) {
        Message *message = (Message *)self.object;
        self.title = [message attributeTextPart2];
        self.attributesTextView.text = [NSString stringWithFormat:@"%@ %@",
                                        [message attributeTextPart1],
                                        [message attributeTextPart3]];
        self.dataTextView.text = [self dataToPrettyString:message.data];
    } else if ([self.object isKindOfClass:[Command class]]) {
        Command *command = (Command *)self.object;
        self.title = [command attributeTextPart2];
        self.attributesTextView.text = [NSString stringWithFormat:@"%@ %@",
                                        [command attributeTextPart1],
                                        [command attributeTextPart3]];
        self.dataTextView.text = [self dataToPrettyString:command.data];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.object isKindOfClass:[Topic class]]) {
        Topic *topic = (Topic *)self.object;
        [topic removeObserver:self forKeyPath:@"data"];
        [topic removeObserver:self forKeyPath:@"count"];
        [topic removeObserver:self forKeyPath:@"mid"];
        [topic removeObserver:self forKeyPath:@"retain"];
        [topic removeObserver:self forKeyPath:@"qos"];
        [topic removeObserver:self forKeyPath:@"timestamp"];
        [topic removeObserver:self forKeyPath:@"justupdated"];
    }
}

- (IBAction)formatChanged:(UISwitch *)sender {
    [self show];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
#ifdef DEBUG
    NSLog(@"observeValueForKeyPath %@ %@ %@ %@", keyPath, object, change, context);
#endif
    Topic *topic = (Topic *)object;
    
    if ([keyPath isEqualToString:@"justupdated"]) {
        self.justupdatedImageView.image = nil;
        self.justupdatedImageView.animationImages = nil;
        [self.justupdatedImageView stopAnimating];
        
        if ([topic isJustupdated]) {
            self.justupdatedImageView.image = [UIImage imageNamed:@"new.png"];
            self.justupdatedImageView.animationImages = @[[UIImage imageNamed:@"new.png"],
                                                          [UIImage imageNamed:@"old.png"]];
            self.justupdatedImageView.animationDuration = 1.0;
            [self.justupdatedImageView startAnimating];
            [topic performSelector:@selector(setOld) withObject:nil afterDelay:3.0];
        } else  {
            self.justupdatedImageView.image = [UIImage imageNamed:@"old.png"];
        }
    }
    
    [self show];
}

- (NSString *)dataToPrettyString:(NSData *)data
{
    if (self.formatSwitch.isOn) {
        __block id json;
#ifdef SB
        SBJson4Parser *parser = [SBJson4Parser parserWithBlock:^(id item, BOOL *stop){
#ifdef DEBUG
            NSLog(@"parser value %@", item);
#endif
            json = item;
        }
                                                allowMultiRoot:NO
                                               unwrapRootArray:NO
                                                  errorHandler:^(NSError *error) {
#ifdef DEBUG
                                                      NSLog(@"parser error %@", error);
#endif
                                                      
        }];
        SBJson4ParserStatus status = [parser parse:data];
        if (status == SBJson4ParserComplete) {
            SBJson4Writer *writer = [[SBJson4Writer alloc] init];
            writer.humanReadable = YES;
            writer.sortKeys = YES;
            self.formatSwitch.enabled = TRUE;
            return [writer stringWithObject:json];
        } else {
            self.formatSwitch.enabled = FALSE;
            return [MQTTInspectorDataViewController dataToString:data];
        }
        
#else // SB
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (dict) {
            NSData *prettyData = [NSJSONSerialization dataWithJSONObject:dict
                                                                 options:NSJSONWritingPrettyPrinted
                                                                   error:&error];
            NSString *message = [[NSString alloc] init];
            for (int i = 0; i < prettyData.length; i++) {
                char c;
                [prettyData getBytes:&c range:NSMakeRange(i, 1)];
                message = [message stringByAppendingFormat:@"%c", c];
            }
            self.formatSwitch.enabled = TRUE;
            return message;
        } else {
            self.formatSwitch.enabled = FALSE;
            return [MQTTInspectorDataViewController dataToString:data];
        }
#endif // SB
    } else {
        return [MQTTInspectorDataViewController dataToString:data];
    }
}

+ (NSString *)dataToString:(NSData *)data
{
    if (isutf8((unsigned char *)[data bytes], data.length) == 0) {
        NSString *message = [[NSString alloc] init];
        for (int i = 0; i < data.length; i++) {
            char c;
            [data getBytes:&c range:NSMakeRange(i, 1)];
            message = [message stringByAppendingFormat:@"%c", c];
        }

        const char *cp = [message cStringUsingEncoding:NSISOLatin1StringEncoding];
        if (cp) {
            NSString *u = @(cp);
            return [NSString stringWithFormat:@"%@", u];
        } else {
            return [NSString stringWithFormat:@"%@", [data description]];
        }
    } else {
        return [NSString stringWithFormat:@"%@", [data description]];
    }
}

@end
