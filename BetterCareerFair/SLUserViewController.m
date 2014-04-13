//
//  SLUserViewController.m
//  BetterCareerFair
//
//  Created by Shao Ping Lee on 4/12/14.
//  Copyright (c) 2014 Shao-Ping Lee. All rights reserved.
//

#import "SLUserViewController.h"
#import "Firebase/Firebase.h"
#import <FYX/FYXSightingManager.h>
#import "SLCompanySelectTableViewController.h"

@interface SLUserViewController () {
    UIDocumentInteractionController *_documentController;
    Firebase *_f;
    NSArray *_keys;
}
@property FYXVisitManager *visitManager;
@property NSMutableDictionary *nearbyBeacons;
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
    _f = [[Firebase alloc] initWithUrl:@"https://amber-fire-5695.firebaseio.com/testBeaconID2"];
    _emailField.delegate = self;
    // Do any additional setup after loading the view.
    _nearbyBeacons = [[NSMutableDictionary alloc] init];
    _visitManager = [FYXVisitManager new];
    _visitManager.delegate = self;
    NSMutableDictionary *options = [NSMutableDictionary new];
    [options setObject:[NSNumber numberWithInt:5] forKey:FYXVisitOptionDepartureIntervalInSecondsKey];
    [options setObject:[NSNumber numberWithInt:FYXSightingOptionSignalStrengthWindowNone] forKey:FYXSightingOptionSignalStrengthWindowKey];
    [options setObject:[NSNumber numberWithInt:-70] forKey:FYXVisitOptionArrivalRSSIKey];
    [options setObject:[NSNumber numberWithInt:-90] forKey:FYXVisitOptionDepartureRSSIKey];
    [self.visitManager startWithOptions:options];
    [_visitManager start];
}

#pragma mark - Gimbal FYXVisitManager
- (void)didArrive:(FYXVisit *)visit;
{
    // this will be invoked when an authorized transmitter is sighted for the first time
    NSLog(@"I arrived at a Gimbal Beacon!!! %@", visit.transmitter.name);
}
- (void)receivedSighting:(FYXVisit *)visit updateTime:(NSDate *)updateTime RSSI:(NSNumber *)RSSI;
{
    // this will be invoked when an authorized transmitter is sighted during an on-going visit
    NSLog(@"%@: %@", visit.transmitter.name, RSSI);
    NSDictionary *visitInfo = @{@"visit": visit, @"rssi": RSSI};
    [_nearbyBeacons setObject:visitInfo forKey:visit.transmitter.identifier];
    
    _keys = [_nearbyBeacons keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDictionary *dict1 = (NSDictionary *)obj1;
        NSDictionary *dict2 = (NSDictionary *)obj2;
        if ([dict1[@"rssi"] integerValue]> [dict2[@"rssi"] integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if ([dict1[@"rssi"] integerValue] < [dict2[@"rssi"] integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    FYXVisit *topVisit = _nearbyBeacons[_keys[0]][@"visit"];
    _companyLabel.text = topVisit.transmitter.name;
}
- (void)didDepart:(FYXVisit *)visit;
{
    // this will be invoked when an authorized transmitter has not been sighted for some time
    NSLog(@"I left the proximity of a Gimbal Beacon!!!! %@", visit.transmitter.name);
    NSLog(@"I was around the beacon for %f seconds", visit.dwellTime);
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
    Firebase *pushRef = [_f childByAutoId];
    [pushRef setValue:@{@"name": _emailField.text, @"data": pdfString}];
}

#pragma mark - Document Handle

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



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    SLCompanySelectTableViewController *selTableViewController = [segue destinationViewController];
    NSLog(@"%@", _nearbyBeacons);
    selTableViewController.nearbyBeacons = _nearbyBeacons;
    NSLog(@"%@", _keys);                                         
    selTableViewController.keys = _keys;
}


@end
