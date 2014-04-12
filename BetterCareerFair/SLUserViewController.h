//
//  SLUserViewController.h
//  BetterCareerFair
//
//  Created by Shao Ping Lee on 4/12/14.
//  Copyright (c) 2014 Shao-Ping Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLUserViewController : UIViewController <UIDocumentInteractionControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) NSURL * pdfUrl;

- (void)handleDocumentOpenURL: (NSURL *)url;
- (IBAction)sendResume:(id)sender;

@end
