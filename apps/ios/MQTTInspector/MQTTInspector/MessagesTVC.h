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

typedef NS_ENUM(UInt8, MessagesType) {
    MessagesTopics = 0,
    MessagesLogs = 1,
    MessagesCommands = 2
};

@interface MessagesTVC : UITableViewController <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) DetailVC *mother;
@property (nonatomic) MessagesType messagesType;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
