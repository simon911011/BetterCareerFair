//
//  SLCompanySelectTableViewController.h
//  BetterCareerFair
//
//  Created by Shao Ping Lee on 4/13/14.
//  Copyright (c) 2014 Shao-Ping Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SLCompanySelectDelegate <NSObject>

- (void) companySelectDidFinishSelecting: (NSString *)beaconId;

@end

@interface SLCompanySelectTableViewController : UITableViewController {
    id _myDelegate;
}
@property (nonatomic, strong) NSMutableDictionary *nearbyBeacons;
@property (nonatomic, strong) NSArray *keys;
@property id<SLCompanySelectDelegate> myDelegate;

@end
