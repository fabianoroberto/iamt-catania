//
//  MapPin.m
//  iamtcatania
//
//  Created by Dr Thief on 15/10/13.
//  Copyright (c) 2013 Dr Thief. All rights reserved.
//

#import "MapPin.h"

@implementation MapPin

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:placeName description:description {
    self = [super init];
    
    if (self != nil) {
        coordinate = location;
        title = placeName;
        subtitle = description;
    }
    
    return self;
}

@end
