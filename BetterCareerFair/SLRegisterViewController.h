//
//  SLRegisterViewController.h
//  BetterCareerFair
//
//  Created by Derek Quach on 4/12/14.
//  Copyright (c) 2014 Shao-Ping Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FYX/FYXVisitManager.h>

@interface SLRegisterViewController : UIViewController <FYXVisitDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *companyName;
@property (weak, nonatomic) IBOutlet UIButton *submit;
- (IBAction)submit:(id)sender;

@end
