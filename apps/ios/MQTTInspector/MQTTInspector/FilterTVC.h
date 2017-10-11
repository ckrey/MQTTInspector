//
//  FilterTVC.h
//  MQTTInspector
//
//  Created by Christoph Krey on 27.01.14.
//  Copyright © 2014-2017 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session+CoreDataClass.h"

@interface FilterTVC : UITableViewController <UITextViewDelegate>
@property (strong, nonatomic) Session *session;

@end
