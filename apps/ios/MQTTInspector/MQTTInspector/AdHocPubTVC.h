//
//  AdHocPubTVC.h
//  MQTTInspector
//
//  Created by Christoph Krey on 15.11.13.
//  Copyright © 2013-2020 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailVC.h"

@interface AdHocPubTVC : UITableViewController <UITextFieldDelegate>
@property (strong, nonatomic) DetailVC *mother;
@end
