//
//  DataVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright © 2013-2020 Christoph Krey. All rights reserved.
//

#import "DataVC.h"
#import "MessageInfoTVC.h"

#import "Model.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

@interface NSJSONSerialization (sorted)
+ (NSString *)sortedJson:(id)json indent:(unsigned int)indent final:(BOOL)final;
@end

@implementation NSJSONSerialization (sorted)
static const DDLogLevel ddLogLevel = DDLogLevelError;

+ (NSString *)sortedJson:(id)json indent:(unsigned int)indent final:(BOOL) final {
    DDLogVerbose(@"json %lu (%@) %@", (unsigned long)indent, [json class], json);
    
    NSString *finalString = @"";
    if (!final) {
        finalString = @",";
    }
    
    NSString *insetString = @"";
    for (NSUInteger i = 0; i < indent; i++) {
        insetString = [insetString stringByAppendingString:@"    "];
    }
    
    if ([json isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = json;
        NSString *dictionaryString = @"{\n";
        NSArray *keyArray = [dictionary.allKeys sortedArrayUsingSelector:@selector(compare:)];
        for (int i = 0; i < keyArray.count; i++) {
            NSString *dictionaryKey = keyArray[i];
            dictionaryString = [dictionaryString stringByAppendingString:
                                [NSString stringWithFormat:@"%@    \"%@\": %@",
                                 insetString,
                                 dictionaryKey,
                                 [NSJSONSerialization sortedJson:dictionary[dictionaryKey]
                                                          indent:indent + 1
                                                           final:(i == keyArray.count - 1)
                                  ]
                                 ]
                                ];
        }
        dictionaryString = [dictionaryString stringByAppendingString:[NSString stringWithFormat:@"%@}%@\n",
                                                                      insetString,
                                                                      finalString
                                                                      ]
                            ];
        return dictionaryString;
    } else if ([json isKindOfClass:[NSArray class]]) {
        NSArray *array = json;
        NSString *arrayString = @"[\n";
        for (int i = 0; i < array.count; i++) {
            id arrayComponent = array[i];
            arrayString = [arrayString stringByAppendingString:
                           [NSString stringWithFormat:@"%@    %@",
                            insetString,
                            [NSJSONSerialization sortedJson:arrayComponent
                                                     indent:indent + 1
                                                      final:(i == array.count - 1)
                             ]
                            ]
                           ];
        }
        arrayString = [arrayString stringByAppendingString:[NSString stringWithFormat:@"%@]%@\n",
                                                            insetString,
                                                            finalString
                                                            ]
                       ];
        return arrayString;
    } else {
        return [[NSJSONSerialization leafJson:json] stringByAppendingString:[NSString stringWithFormat:@"%@\n",
                                                                             finalString
                                                                             ]];
    }
}

+ (NSString *)leafJson:(id)json {
    if ([json isKindOfClass:[NSNumber class]]) {
        NSNumber *number = json;
        NSString *numberString = @"";
        if (number == [NSNumber numberWithBool:true]) {
            numberString = @"true";
        } else if (number == [NSNumber numberWithBool:false]) {
            numberString = @"false";
        } else {
            numberString = number.description;
        }
        return numberString;
    } else if ([json isKindOfClass:[NSString class]]) {
        NSString *string = [NSString stringWithFormat:@"\"%@\"", json];
        return string;
    }
    return @"illegal JSON leaf";
}

@end

@interface DataVC ()
@property (weak, nonatomic) IBOutlet UITextView *dataTextView;
@property (weak, nonatomic) IBOutlet UITextField *attributesTextView;
@property (weak, nonatomic) IBOutlet UIImageView *justupdatedImageView;
@property (weak, nonatomic) IBOutlet UISwitch *formatSwitch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *infoButton;

@end

@implementation DataVC

- (void)viewDidLoad {
    self.attributesTextView.delegate = self;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return FALSE;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.formatSwitch.on = TRUE;
    
    if ([self.object isKindOfClass:[Topic class]]) {
        Topic *topic = (Topic *)self.object;
        [topic addObserver:self forKeyPath:@"justupdated"
                   options:NSKeyValueObservingOptionNew                   context:nil];
        [topic addObserver:self forKeyPath:@"timestamp"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
        [topic addObserver:self forKeyPath:@"qos"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
        [topic addObserver:self forKeyPath:@"retain"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
        [topic addObserver:self forKeyPath:@"mid"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
        [topic addObserver:self forKeyPath:@"count"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
        [topic addObserver:self forKeyPath:@"data"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
    }
    
    [self show];
}

- (void)show {
    UIFont *fontBold = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    NSDictionary *aBold = @{NSFontAttributeName: fontBold};

    UIFont *fontLight = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    NSDictionary *aLight = @{NSFontAttributeName: fontLight};

    NSMutableAttributedString *as = [[NSMutableAttributedString alloc] init];

    if ([self.object isKindOfClass:[Topic class]]) {
        Topic *topic = (Topic *)self.object;
        self.title = topic.attributeTextPart2;
        self.formatSwitch.enabled = TRUE;
        self.infoButton.enabled = TRUE;
        [as appendAttributedString:
         [[NSAttributedString alloc]
          initWithString:topic.attributeTextPart1 attributes:aLight]];
        [as appendAttributedString:
         [[NSAttributedString alloc]
          initWithString:topic.attributeTextPart2 attributes:aBold]];
        [as appendAttributedString:
         [[NSAttributedString alloc]
          initWithString:topic.attributeTextPart3 attributes:aLight]];
        self.dataTextView.text = [self dataToPrettyString:topic.data];
        
    } else if ([self.object isKindOfClass:[Message class]]) {
        Message *message = (Message *)self.object;
        self.title = message.attributeTextPart2;
        self.formatSwitch.enabled = TRUE;
        self.infoButton.enabled = TRUE;
        [as appendAttributedString:
         [[NSAttributedString alloc]
          initWithString:message.attributeTextPart1 attributes:aLight]];
        [as appendAttributedString:
         [[NSAttributedString alloc]
          initWithString:message.attributeTextPart2 attributes:aBold]];
        [as appendAttributedString:
         [[NSAttributedString alloc]
          initWithString:message.attributeTextPart3 attributes:aLight]];
        self.dataTextView.text = [self dataToPrettyString:message.data];
        
    } else if ([self.object isKindOfClass:[Command class]]) {
        Command *command = (Command *)self.object;
        self.title = command.attributeTextPart2;
        self.formatSwitch.enabled = TRUE;
        self.infoButton.enabled = FALSE;
        [as appendAttributedString:
         [[NSAttributedString alloc]
          initWithString:command.attributeTextPart1 attributes:aLight]];
        [as appendAttributedString:
         [[NSAttributedString alloc]
          initWithString:command.attributeTextPart2 attributes:aBold]];
        [as appendAttributedString:
         [[NSAttributedString alloc]
          initWithString:command.attributeTextPart3 attributes:aLight]];
        self.dataTextView.text = [self dissect:command];
    }

    self.attributesTextView.attributedText = as;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([self.object isKindOfClass:[Topic class]]) {
        Topic *topic = (Topic *)self.object;
        if ([segue.destinationViewController respondsToSelector:@selector(setPayloadFormatIndicator:)]) {
            [segue.destinationViewController performSelector:@selector(setPayloadFormatIndicator:)
                                                  withObject:topic.payloadFormatIndicator];
        }
        if ([segue.destinationViewController respondsToSelector:@selector(setMessageExpiryInterval:)]) {
            [segue.destinationViewController performSelector:@selector(setMessageExpiryInterval:)
                                                  withObject:topic.messageExpiryInterval];
        }
        if ([segue.destinationViewController respondsToSelector:@selector(setTopicAlias:)]) {
            [segue.destinationViewController performSelector:@selector(setTopicAlias:)
                                                  withObject:topic.topicAlias];
        }
        if ([segue.destinationViewController respondsToSelector:@selector(setResponseTopic:)]) {
            [segue.destinationViewController performSelector:@selector(setResponseTopic:)
                                                  withObject:topic.responseTopic];
        }
        if ([segue.destinationViewController respondsToSelector:@selector(setCorrelationData:)]) {
            [segue.destinationViewController performSelector:@selector(setCorrelationData:)
                                                  withObject:topic.correlationData];
        }
        if ([segue.destinationViewController respondsToSelector:@selector(setContentType:)]) {
            [segue.destinationViewController performSelector:@selector(setContentType:)
                                                  withObject:topic.contentType];
        }
        if ([segue.destinationViewController respondsToSelector:@selector(setSubscriptionIdentifiers:)]) {
            [segue.destinationViewController performSelector:@selector(setSubscriptionIdentifiers:)
                                                  withObject:topic.subscriptionIdentifiers];
        }
        if ([segue.destinationViewController respondsToSelector:@selector(setUserProperties:)]) {
            [segue.destinationViewController performSelector:@selector(setUserProperties:)
                                                  withObject:topic.userProperties];
        }
    } else if ([self.object isKindOfClass:[Message class]]) {
        Message *message = (Message *)self.object;
        if ([segue.destinationViewController respondsToSelector:@selector(setPayloadFormatIndicator:)]) {
            [segue.destinationViewController performSelector:@selector(setPayloadFormatIndicator:)
                                                  withObject:message.payloadFormatIndicator];
        }
        if ([segue.destinationViewController respondsToSelector:@selector(setMessageExpiryInterval:)]) {
            [segue.destinationViewController performSelector:@selector(setMessageExpiryInterval:)
                                                  withObject:message.messageExpiryInterval];
        }
        if ([segue.destinationViewController respondsToSelector:@selector(setTopicAlias:)]) {
            [segue.destinationViewController performSelector:@selector(setTopicAlias:)
                                                  withObject:message.topicAlias];
        }
        if ([segue.destinationViewController respondsToSelector:@selector(setResponseTopic:)]) {
            [segue.destinationViewController performSelector:@selector(setResponseTopic:)
                                                  withObject:message.responstTopic];
        }
        if ([segue.destinationViewController respondsToSelector:@selector(setCorrelationData:)]) {
            [segue.destinationViewController performSelector:@selector(setCorrelationData:)
                                                  withObject:message.correlationData];
        }
        if ([segue.destinationViewController respondsToSelector:@selector(setContentType:)]) {
            [segue.destinationViewController performSelector:@selector(setContentType:)
                                                  withObject:message.contentType];
        }
        if ([segue.destinationViewController respondsToSelector:@selector(setSubscriptionIdentifiers:)]) {
            [segue.destinationViewController performSelector:@selector(setSubscriptionIdentifiers:)
                                                  withObject:message.subscriptionIdentifiers];
        }
        if ([segue.destinationViewController respondsToSelector:@selector(setUserProperties:)]) {
            [segue.destinationViewController performSelector:@selector(setUserProperties:)
                                                  withObject:message.userProperties];
        }
    }
}

- (IBAction)formatChanged:(UISwitch *)sender {
    [self show];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    DDLogVerbose(@"observeValueForKeyPath %@ %@ %@ %@", keyPath, object, change, context);
    Topic *topic = (Topic *)object;
    
    if ([keyPath isEqualToString:@"justupdated"]) {
        self.justupdatedImageView.image = nil;
        self.justupdatedImageView.animationImages = nil;
        [self.justupdatedImageView stopAnimating];
        self.justupdatedImageView.image = [UIImage imageNamed:@"old.png"];

        if (topic.justupdated.boolValue) {
            self.justupdatedImageView.animationImages = @[[UIImage imageNamed:@"new.png"],
                                                          [UIImage imageNamed:@"old.png"]];
            self.justupdatedImageView.animationDuration = 1.0;
            self.justupdatedImageView.animationRepeatCount = 1;
            [self.justupdatedImageView startAnimating];
        }
    }
    
    [self show];
}

- (NSString *)dataToPrettyString:(NSData *)data {
    NSString *hex = data.description;
    NSString *formatted = hex;

    if (self.formatSwitch.isEnabled) {
        NSString *utf8 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (utf8) {
            formatted = utf8;
            if (self.formatSwitch.isOn) {
                id json = [NSJSONSerialization JSONObjectWithData:data
                                                          options:0
                                                            error:nil];
                if (json) {
                    NSString *pretty = [NSJSONSerialization sortedJson:json indent:0 final:true];
                    if (pretty) {
                        self.formatSwitch.enabled = TRUE;
                        formatted = pretty;
                    } else {
                        self.formatSwitch.enabled = FALSE;
                        self.formatSwitch.on = FALSE;
                    }
                } else {
                    self.formatSwitch.enabled = FALSE;
                    self.formatSwitch.on = FALSE;
                }
            }
        } else {
            self.formatSwitch.enabled = FALSE;
            self.formatSwitch.on = FALSE;
        }
    }
    return formatted;
}

- (NSString *)dissect:(Command *)command {
    NSString *formatted = [[NSString alloc] init];

    for (int i = 0; i < command.data.length; i++) {
        UInt8 u;
        [command.data getBytes:&u range:NSMakeRange(i, 1)];
        formatted = [formatted stringByAppendingString:[NSString stringWithFormat:@"%02X", u]];
        if ((i + 1) % 16 == 0) {
            formatted = [formatted stringByAppendingString:@" "];
        }
    }

    if (self.formatSwitch.isOn) {
        NSString *dissected = [NSString stringWithFormat:@
                               "Fixed Header\n"
                               "   Byte 1 0x%02X\n"
                               "      1111 .... = Control Packet type (%d)\n"
                               "      .... 1... = Dup (%d)\n"
                               "      .... .11. = QoS (%d)\n"
                               "      .... ...1 = Retain (%d)\n"
                               "   Remaining Length .\n",
                               command.type.intValue << 4 |
                               command.duped.intValue << 3 |
                               command.qos.intValue << 1 |
                               command.retained.intValue,
                               command.type.intValue,
                               command.duped.intValue,
                               command.qos.intValue,
                               command.retained.intValue];

        formatted = dissected;
    }
    return formatted;
}

@end
