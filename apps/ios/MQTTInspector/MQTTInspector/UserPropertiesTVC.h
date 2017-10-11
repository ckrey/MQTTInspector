//
//  UserPropertyTVC.h
//  MQTTInspector
//
//  Created by Christoph Krey on 31.08.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserPropertiesTVC : UITableViewController
@property (strong, nonatomic) NSArray <NSDictionary <NSString *, NSString *> *> *userProperties;
@property (nonatomic) NSNumber *edit;

@end
