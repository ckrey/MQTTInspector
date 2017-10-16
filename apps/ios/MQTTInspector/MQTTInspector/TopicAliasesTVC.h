//
//  TopicAliasesTVC.h
//  MQTTInspector
//
//  Created by Christoph Krey on 16.10.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopicAliasesTVC : UITableViewController
@property (strong, nonatomic) NSDictionary <NSNumber *, NSString *> * _Nonnull topicAliases;

@end
