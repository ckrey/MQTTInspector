//
//  SubscriptionIdentifiersTVC.h
//  MQTTInspector
//
//  Created by Christoph Krey on 12.10.17.
//  Copyright © 2017-2020 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnyTVC.h"

@interface SubscriptionIdentifiersTVC : AnyTVC
@property (strong, nonatomic, nullable) NSData *subscriptionIdentifiers;

@end
