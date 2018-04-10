//
//  CertificateTVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 09.04.18.
//  Copyright © 2018 Christoph Krey. All rights reserved.
//

#import "CertificateTVC.h"

@interface CertificateTVC ()
@property (strong, nonatomic) NSMutableArray *contents;
@property (strong, nonatomic) NSString *path;

@end

@implementation CertificateTVC

- (NSArray *)contents {
    if (!_contents) {

        NSError *error;
        NSURL *directoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                     inDomain:NSUserDomainMask
                                                            appropriateForURL:nil
                                                                       create:YES
                                                                        error:&error];
        self.path = directoryURL.path;
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path error:&error];
        _contents = [[NSMutableArray alloc] init];
        for (NSString *file in contents) {
            if ([file.pathExtension isEqualToString:@"mqtc"]) {
                NSString *path = [self.path stringByAppendingPathComponent:file];
                BOOL directory;
                if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&directory] && !directory) {

                    [_contents addObject:file];
                }
            }
        }

    }
    return _contents;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"certificate" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;

    NSString *file = self.contents[indexPath.row];
    cell.textLabel.text = file;

    if ([self.selectedFileName isEqualToString:file]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *fileToDelete = self.contents[indexPath.row];

        if ([self.selectedFileName isEqualToString:fileToDelete]) {
            self.selectedFileName = nil;
        }
        NSString *pathToDelete = [self.path stringByAppendingPathComponent:fileToDelete];
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:pathToDelete error:&error];
        [self.contents removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *file = self.contents[indexPath.row];

    if ([file isEqualToString:self.selectedFileName]) {
        self.selectedFileName = nil;
    } else {
        self.selectedFileName = file;
    }

    [tableView reloadData];
    return indexPath;
}


@end
