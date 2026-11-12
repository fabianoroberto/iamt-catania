//
//  SettingsViewController.h
//  turniquintaps
//
//  Created by Dr Thief on 18/12/13.
//  Copyright (c) 2013 Dr Thief. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MyWebSite.h"
#import "AppDelegate.h"
#import "Constant.h"
#import <UIDeviceIdentifier/UIDeviceHardware.h>

@interface SettingsViewController : UITableViewController <MFMailComposeViewControllerDelegate> {

}

@property (nonatomic, strong) NSArray *dataArray;

@end
