//
//  ShowSubsTVC.h
//  MQTTInspector
//
//  Created by Christoph Krey on 12.11.13.
//  Copyright © 2013-2020 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailVC.h"
#import "CoreDataTVC.h"

@interface ShowSubsTVC : CoreDataTVC
@property (strong, nonatomic) DetailVC *mother;

@end
