//
//  RoutesAndPathViewController.h
//  iamtcatania
//
//  Created by Dr Thief on 29/09/13.
//  Copyright (c) 2013 Dr Thief. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Line.h"

@interface RoutesAndPathViewController : UITableViewController {
    NSArray *items;
    NSCalendar *calendar;
    UIImage *cellImage;
}

- (void) setLine:(Line *)line forType:(NSInteger) type;

@property(nonatomic, retain) NSCalendar *calendar;
@property(nonatomic, strong) NSMutableArray *sections;
@property(nonatomic, strong) NSMutableArray *sectionsText;

@end
