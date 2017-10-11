//
//  UserPropertyTVC.h
//  MQTTInspector
//
//  Created by Christoph Krey on 10.10.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserPropertyTVC : UITableViewController <UITextFieldDelegate>
@property (strong, nonatomic) NSMutableDictionary <NSString *, NSString *> *keyValue;
@property (strong, nonatomic) NSNumber *position;

@end
