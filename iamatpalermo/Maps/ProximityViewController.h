//
//  ProximityViewController.h
//  iamtcatania
//
//  Created by Dr Thief on 08/10/13.
//  Copyright (c) 2013 Dr Thief. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "MBProgressHUD.h"
#import "XMLReader.h"
#import "LineMenuViewController.h"

@interface ProximityViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, MBProgressHUDDelegate> {
    NSString *address;
	NSString *addressDetail;
}

@property (nonatomic, retain) IBOutlet MKMapView *myMapView;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UISlider *mySlider;
@property (weak, nonatomic) IBOutlet UILabel *myLabel;

@end
