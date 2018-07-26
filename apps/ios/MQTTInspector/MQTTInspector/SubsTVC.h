//
//  SubsTVC.h
//  MQTTInspector
//
//  Created by Christoph Krey on 14.11.13.
//  Copyright © 2013-2018 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session+CoreDataClass.h"
#import "CoreDataTVC.h"

@interface SubsTVC : CoreDataTVC
@property (strong, nonatomic) Session *session;

@end
