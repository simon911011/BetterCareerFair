//
//  SLUserViewController.h
//  BetterCareerFair
//
//  Created by Shao Ping Lee on 4/12/14.
//  Copyright (c) 2014 Shao-Ping Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FYX/FYXVisitManager.h>

@interface SLUserViewController : UIViewController <UIDocumentInteractionControllerDelegate, UITextFieldDelegate, FYXVisitDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIButton *viewTableButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (strong, nonatomic) NSURL * pdfUrl;

- (void)handleDocumentOpenURL: (NSURL *)url;
- (IBAction)sendResume:(id)sender;

@end
