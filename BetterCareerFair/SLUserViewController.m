//
//  SLUserViewController.m
//  BetterCareerFair
//
//  Created by Shao Ping Lee on 4/12/14.
//  Copyright (c) 2014 Shao-Ping Lee. All rights reserved.
//

#import "SLUserViewController.h"
#import "Firebase/Firebase.h"

@interface SLUserViewController () {
    UIDocumentInteractionController *_documentController;
    Firebase *f;
}

@end

@implementation SLUserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"View Did load");
    f = [[Firebase alloc] initWithUrl:@"https://amber-fire-5695.firebaseio.com/testBeaconID2"];
    _emailField.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == _emailField) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

- (IBAction)sendResume:(id)sender
{
    NSData *pdfData = [NSData dataWithContentsOfURL:_pdfUrl];
    NSString *pdfString = [pdfData base64EncodedStringWithOptions:0];
    NSLog(@"pdfString: %@", pdfString);
    Firebase *pushRef = [f childByAutoId];
    [pushRef setValue:@{@"name": _emailField.text, @"data": pdfString}];
}

- (void)handleDocumentOpenURL: (NSURL *)url
{
    _pdfUrl = url;
    _documentController = [UIDocumentInteractionController interactionControllerWithURL: [_pdfUrl filePathURL]];
    _documentController.delegate = self;
    _documentController.UTI = @"com.adobe.pdf";
    [_documentController presentPreviewAnimated:YES];
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller
       willBeginSendingToApplication:(NSString *)application {
    
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller
          didEndSendingToApplication:(NSString *)application {
    
}

- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    return self;
}

-(void)documentInteractionControllerDidDismissOpenInMenu:
(UIDocumentInteractionController *)controller {
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
