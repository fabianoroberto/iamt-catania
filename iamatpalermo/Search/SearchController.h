//
//  SearchController.h
//  iamtcatania
//
//  Created by Dr Thief on 02/01/14.
//  Copyright (c) 2014 Dr Thief. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailSearchController.h"
#import "TextFieldCell.h"
#import "SliderCell.h"
#import "SearchObject.h"
#import "Constant.h"

@interface SearchController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate> {
}

@property (strong, nonatomic) SearchObject *searchObj;

@property (retain, nonatomic) NSArray *alternatives;
@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, strong) NSIndexPath *pickerIndexPath;
@property (assign) NSInteger pickerCellRowHeight;

@property (retain, nonatomic) IBOutlet UIPickerView *pickerView;

@end
