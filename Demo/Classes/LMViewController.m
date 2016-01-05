//
//  LMViewController.m
//  Logmatic_Demo
//
//  Created by Roland Borgese on 04/01/2016.
//  Copyright © 2016 Applidium. All rights reserved.
//

#import "LMViewController.h"
#import "LMLogger.h"

@implementation LMViewController

- (void)sendSimpleJson:(id)sender {
    NSDictionary * simpleJson = @{@"counter": @(self.count), @"a": @{@"b": @"val1", @"c": @"val2"}};
    [[LMLogger sharedLogger] log:simpleJson withMessage:self.textField.text];
    self.count++;
    self.textField.text = nil;
}

@end
