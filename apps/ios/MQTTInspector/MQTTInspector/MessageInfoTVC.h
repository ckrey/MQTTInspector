//
//  MessageInfoTVC.h
//  MQTTInspector
//
//  Created by Christoph Krey on 12.10.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageInfoTVC : UITableViewController
@property (strong, nonatomic, nullable) NSNumber *payloadFormatIndicator;
@property (strong, nonatomic, nullable) NSNumber *messageExpiryInterval;
@property (strong, nonatomic, nullable) NSNumber *topicAlias;
@property (strong, nonatomic, nullable) NSData *userProperties;
@property (strong, nonatomic, nullable) NSData *subscriptionIdentifiers;
@property (strong, nonatomic, nullable) NSString *responseTopic;
@property (strong, nonatomic, nullable) NSString *contentType;
@property (strong, nonatomic, nullable) NSData *correlationData;

@end
