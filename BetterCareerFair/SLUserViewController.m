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
    BOOL _shouldUpdate;
    BOOL _selectedFromTable;
    NSString *_companyID;
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
    _emailField.delegate = self;

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
    
    _shouldUpdate = YES;
    _selectedFromTable = NO;
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
    if (_shouldUpdate) {
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

        Firebase *f = [[Firebase alloc] initWithUrl:[@"https://company-id.firebaseio.com/" stringByAppendingString:topVisit.transmitter.identifier]];
        [f observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            _companyLabel.text = snapshot.value;
        }];
        
    }
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
    if ([_emailField.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoa" message:@"Name is empty" delegate:nil cancelButtonTitle:@"Got it." otherButtonTitles:nil];
        [alert show];
    } else {
        _shouldUpdate = NO;
        if (!_selectedFromTable) {
            FYXVisit *topVisit = _nearbyBeacons[_keys[0]][@"visit"];
            _companyID = topVisit.transmitter.identifier;
        }
        
        _f = [[Firebase alloc] initWithUrl:[@"https://bettercareerfair.firebaseio.com/" stringByAppendingString: _companyID]];
        NSData *pdfData = [NSData dataWithContentsOfURL:_pdfUrl];
        NSString *pdfString = [pdfData base64EncodedStringWithOptions:0];
        Firebase *pushRef = [_f childByAutoId];
        [pushRef setValue:@{@"name": _emailField.text, @"data": pdfString}];
        _shouldUpdate = YES;
        _selectedFromTable = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congrats" message:@"Resume is sent!" delegate:nil cancelButtonTitle:@"Aye" otherButtonTitles:nil];
        [alert show];
    }
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

#pragma mark - SLCompanyDidSelect method
- (void)companySelectDidFinishSelecting:(NSString *)beaconId
{
    _shouldUpdate = NO;
    _selectedFromTable = YES;
    _companyID = beaconId;
    Firebase *f = [[Firebase alloc] initWithUrl:[@"https://company-id.firebaseio.com/" stringByAppendingString:beaconId]];
    [f observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        _companyLabel.text = snapshot.value;
    }];
    NSLog(@"Assigned ID: %@", _companyID);
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    SLCompanySelectTableViewController *selTableViewController = [segue destinationViewController];
    selTableViewController.myDelegate = self;
    selTableViewController.nearbyBeacons = _nearbyBeacons;
    selTableViewController.keys = _keys;
}


@end
