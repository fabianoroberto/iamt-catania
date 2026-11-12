//
//  LinesViewController.h
//  iamtcatania
//
//  Created by Dr Thief on 15/09/13.
//  Copyright (c) 2013 Dr Thief. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface LinesViewController : UITableViewController <MBProgressHUDDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate>  {
    NSArray *searchResults;
    UIBarButtonItem *cancelButton;
}

@property (strong, nonatomic) UISearchController *searchController;

@property (nonatomic, strong) NSArray *lines;
@property (nonatomic, strong) NSArray *sections;

@end
