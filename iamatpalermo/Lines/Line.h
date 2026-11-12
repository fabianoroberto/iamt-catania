//
//  Line.h
//  iamtcatania
//
//  Created by Dr Thief on 15/09/13.
//  Copyright (c) 2013 Dr Thief. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Line : NSObject
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSArray *weekdays;
@property (strong, nonatomic) NSArray *holidays;
@property (strong, nonatomic) NSArray *routes;
@property (strong, nonatomic) NSArray *polyline;
@property (strong, nonatomic) NSArray *notes;
@end
