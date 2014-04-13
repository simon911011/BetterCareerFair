//
//  SLAppDelegate.h
//  BetterCareerFair
//
//  Created by Shao Ping Lee on 4/12/14.
//  Copyright (c) 2014 Shao-Ping Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FYX/FYX.h>
#import "SLUserViewController.h"

@interface SLAppDelegate : UIResponder <UIApplicationDelegate, FYXServiceDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SLUserViewController *viewController;

@end
