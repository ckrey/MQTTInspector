//
//  SplitVC.m
//  MQTTInspector
//
//  Created by Christoph Krey on 12.10.17.
//  Copyright © 2017-2019 Christoph Krey. All rights reserved.
//

#import "SplitVC.h"

@interface SplitVC ()

@end

@implementation SplitVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
collapseSecondaryViewController:(UIViewController *)secondaryViewController
  ontoPrimaryViewController:(UIViewController *)primaryViewController {
    return true;
}

@end
