//
//  PolylineViewController.h
//  iamtcatania
//
//  Created by Dr Thief on 05/10/13.
//  Copyright (c) 2013 Dr Thief. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface PolylineViewController : UIViewController <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *myMapView;
@property (strong, nonatomic) NSArray *arrayCoordinate;
@end
