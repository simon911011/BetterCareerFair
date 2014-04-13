//
//  SLRegisterViewController.m
//  BetterCareerFair
//
//  Created by Derek Quach on 4/12/14.
//  Copyright (c) 2014 Shao-Ping Lee. All rights reserved.
//

#import "SLRegisterViewController.h"
#import <Firebase/Firebase.h>
#import <FYX/FYXSightingManager.h>


@interface SLRegisterViewController (){
    NSArray *_keys;
}
@property (nonatomic) FYXVisitManager *visitManager;
@property NSMutableDictionary *nearbyBeacons;

@end

@implementation SLRegisterViewController

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
    
    
    self.companyName.delegate = self;
    _nearbyBeacons = [[NSMutableDictionary alloc] init];
    self.visitManager = [FYXVisitManager new];
    self.visitManager.delegate = self;
    [self.visitManager start];
    NSMutableDictionary *options = [NSMutableDictionary new];
    [options setObject:[NSNumber numberWithInt:5] forKey:FYXVisitOptionDepartureIntervalInSecondsKey];
    [options setObject:[NSNumber numberWithInt:FYXSightingOptionSignalStrengthWindowNone] forKey:FYXSightingOptionSignalStrengthWindowKey];
    [options setObject:[NSNumber numberWithInt:-70] forKey:FYXVisitOptionArrivalRSSIKey];
    [options setObject:[NSNumber numberWithInt:-90] forKey:FYXVisitOptionDepartureRSSIKey];
    [self.visitManager startWithOptions:options];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
}

- (void)didArrive:(FYXVisit *)visit;
{
    // this will be invoked when an authorized transmitter is sighted for the first time
    NSLog(@"I arrived at a Gimbal Beacon!!! %@", visit.transmitter.name);
}

- (void)didDepart:(FYXVisit *)visit;
{
    // this will be invoked when an authorized transmitter has not been sighted for some time
    NSLog(@"I left the proximity of a Gimbal Beacon!!!! %@", visit.transmitter.name);
    NSLog(@"I was around the beacon for %f seconds", visit.dwellTime);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}


// Send the company name and closest beacon name to the firebase
- (IBAction)submit:(id)sender {
    NSString * name = _companyName.text;
    
    NSDictionary *visitInfo = _nearbyBeacons[_keys[0]]; // Grab the closest beacon.
    FYXVisit *visit = visitInfo[@"visit"];
    NSString * beaconName = visit.transmitter.identifier;
    
    NSString * product = [NSString stringWithFormat:@"Company: %@, Beacon Key %@", name, beaconName];
   
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Result" message:product delegate:nil cancelButtonTitle:@"Yeah!" otherButtonTitles:nil];
    [alert show];
    
    Firebase * f = [[Firebase alloc] initWithUrl:@"https://company-id.firebaseIO.com/"];
    [[f childByAppendingPath:beaconName] setValue:name];
    
    NSUserDefaults *persistence = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject: beaconName forKey: @"beaconKey"];
    
    [persistence registerDefaults:dict];
}
@end
