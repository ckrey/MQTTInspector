//
//  TopicAliasesTVC.h
//  MQTTInspector
//
//  Created by Christoph Krey on 16.10.17.
//  Copyright © 2017-2019 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnyTVC.h"

@interface TopicAliasesTVC : AnyTVC
@property (strong, nonatomic) NSDictionary <NSNumber *, NSString *> * _Nonnull topicAliases;

@end
