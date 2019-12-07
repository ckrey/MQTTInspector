//
//  UserPropertyTVC.h
//  MQTTInspector
//
//  Created by Christoph Krey on 31.08.17.
//  Copyright © 2017-2019 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnyTVC.h"

@interface UserPropertiesTVC : AnyTVC
@property (strong, nonatomic) NSArray <NSDictionary <NSString *, NSString *> *> *userProperties;
@property (nonatomic) NSNumber *edit;

@end
