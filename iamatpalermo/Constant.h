//
//  Constant.h
//  iamtcatania
//
//  Created by Dr Thief on 15/09/13.
//  Copyright (c) 2013 Dr Thief. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
#define SCREEN_HEIGHT ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

extern NSString * const SERVER_URL;
extern NSString * const SERVER_URL_BY_LINE;
extern NSString * const PROXIMITY;
extern NSString * const PDF_URL;
extern NSString * const MAP_URL;
extern NSString * const SEARCH_URL;
extern NSString * const GOOGLE_API;

typedef enum {
    weekdays = 0,
    holidays = 1,
    routes = 2,
    next10departures = 3,
    pdf = 4,
    maps = 5
} MENUSECTIONS;