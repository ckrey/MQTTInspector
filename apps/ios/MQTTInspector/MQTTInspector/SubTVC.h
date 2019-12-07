//
//  SubTVC.h
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright © 2013-2019 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Subscription+CoreDataClass.h"

@interface SubTVC : UITableViewController <UITextFieldDelegate>
@property (strong, nonatomic) Subscription *sub;

@end
