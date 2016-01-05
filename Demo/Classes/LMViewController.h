//
//  LMViewController.h
//  Logmatic_Demo
//
//  Created by Roland Borgese on 04/01/2016.
//  Copyright © 2016 Applidium. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMViewController : UIViewController
@property (nonatomic, strong) IBOutlet UITextField * textField;
@property (nonatomic) NSInteger count;

- (IBAction)sendSimpleJson:(id)sender;
@end

