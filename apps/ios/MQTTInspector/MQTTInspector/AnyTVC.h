//
//  AnyTVC.h
//  MQTTInspector
//
//  Created by Christoph Krey on 25.11.19.
//  Copyright © 2019-2020 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnyTVC : UITableViewController
@property (strong, nonatomic) NSString *emptyText;
- (void)empty;
- (void)nonempty;

@end

NS_ASSUME_NONNULL_END
