//
//  SearchObject.h
//  iamtcatania
//
//  Created by Dr Thief on 03/01/14.
//  Copyright (c) 2014 Dr Thief. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchObject : NSObject
@property (nonatomic, strong) NSString *departure;
@property (nonatomic, strong) NSString *destination;
@property (assign) NSInteger alternative;
@property (assign) NSInteger distance;
@end
