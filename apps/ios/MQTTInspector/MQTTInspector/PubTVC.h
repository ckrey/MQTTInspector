//
//  PubTVC.h
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright © 2013-2019 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Publication+CoreDataClass.h"

@interface PubTVC : UITableViewController <UITextFieldDelegate>
@property (strong, nonatomic) Publication *pub;

@end
