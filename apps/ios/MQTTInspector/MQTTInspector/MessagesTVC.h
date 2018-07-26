//
//  MessagesTVC.h
//  MQTTInspector
//
//  Created by Christoph Krey on 17.11.13.
//  Copyright © 2013-2018 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailVC.h"
#import "Session+CoreDataClass.h"

@interface MessagesTVC : UITableViewController <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) DetailVC *mother;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (UIColor *)matchingTopicColor:(NSString *)topic inSession:(Session *)session;

@end
