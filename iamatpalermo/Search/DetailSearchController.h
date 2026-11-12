//
//  DetailSearchController.h
//  iamtcatania
//
//  Created by Dr Thief on 04/01/14.
//  Copyright (c) 2014 Dr Thief. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "XMLReader.h"
#import "Constant.h"
#import "LineMenuViewController.h"

@interface DetailSearchController : UITableViewController <MBProgressHUDDelegate> {
    
}

@property (nonatomic, strong) NSDictionary *linesDict;
@property (nonatomic, strong) NSArray *lines;
@property (strong, nonatomic) NSString *url;

@end
