//
//  MQTTInspectorDataViewController.m
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright © 2013-2016 Christoph Krey. All rights reserved.
//

#import "MQTTInspectorDataViewController.h"

#import "Model.h"

@interface NSJSONSerialization (sorted)
+ (NSString *)sortedJson:(id)json indent:(unsigned int)indent final:(BOOL)final;
@end

@implementation NSJSONSerialization (sorted)
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
        NSString *string = json;
        return string;
    }
    return @"illegal JSON leaf";
}

@end

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
    DDLogVerbose(@"observeValueForKeyPath %@ %@ %@ %@", keyPath, object, change, context);
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

- (NSString *)dataToPrettyString:(NSData *)data {
    NSString *formatted = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSString *utf8 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (utf8) {
        formatted = utf8;
    }
    if (self.formatSwitch.isOn) {
        id json = [NSJSONSerialization JSONObjectWithData:data
                                                  options:0
                                                    error:nil];
        if (json) {
            self.formatSwitch.enabled = TRUE;
            NSString *pretty = [NSJSONSerialization sortedJson:json indent:0 final:true];
            // NSJSONSerialization does not sort!!!
            //            NSString *pretty = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:json
            //                                                                                              options:NSJSONWritingPrettyPrinted
            //                                                                                                error:nil] encoding:NSUTF8StringEncoding];
            if (pretty) {
                formatted = pretty;
            }
        }
    }
    return formatted;
}

@end
