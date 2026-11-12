//
//  ProximityViewController.m
//  iamtcatania
//
//  Created by Dr Thief on 08/10/13.
//  Copyright (c) 2013 Dr Thief. All rights reserved.
//

#import "ProximityViewController.h"
#import "MapPin.h"
#import "Constant.h"

@interface ProximityViewController ()

@end

@implementation ProximityViewController

@synthesize myMapView, locationManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    myMapView.delegate = self;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    #ifdef __IPHONE_8_0
    if(IS_OS_8_OR_LATER) {
        // Use one or the other, not both. Depending on what you put in info.plist
        [locationManager requestWhenInUseAuthorization];
        [locationManager requestAlwaysAuthorization];
    }
    #endif
    
    [locationManager startUpdatingLocation];
    
    myMapView.showsUserLocation = YES;
    [myMapView setMapType:MKMapTypeStandard];
    [myMapView setZoomEnabled:YES];
    [myMapView setScrollEnabled:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    NSLog(@"%@", [self deviceLocation]);
    
    //View Area
    MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
    region.center.latitude = locationManager.location.coordinate.latitude;
    region.center.longitude = locationManager.location.coordinate.longitude;
    region.span.longitudeDelta = 0.005f;
    region.span.longitudeDelta = 0.005f;
    [myMapView setRegion:region animated:YES];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 1000, 1000);
    [myMapView setRegion:[myMapView regionThatFits:region] animated:YES];
}

- (NSString *)deviceLocation {
    return [NSString stringWithFormat:@"latitude: %f longitude: %f", locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude];
}
- (NSString *)deviceLat {
    return [NSString stringWithFormat:@"%f", locationManager.location.coordinate.latitude];
}
- (NSString *)deviceLon {
    return [NSString stringWithFormat:@"%f", locationManager.location.coordinate.longitude];
}
- (NSString *)deviceAlt {
    return [NSString stringWithFormat:@"%f", locationManager.location.altitude];
}

- (IBAction)refresh:(id)sender {
    myMapView.showsUserLocation = NO;
	[myMapView removeAnnotations:myMapView.annotations];
	myMapView.showsUserLocation = YES;
	
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(myMapView.userLocation.location.coordinate, 1000, 1000);
    [myMapView setRegion:[myMapView regionThatFits:region] animated:YES];
}

- (IBAction)findByRay:(id)sender {
    self.myLabel.text = [NSString stringWithFormat:@"%@! %@: %.fm", NSLocalizedString(@"saved", "saved label"), NSLocalizedString(@"ray", "ray label"), self.mySlider.value];
    
    [self reloadTableData];
}

- (IBAction)sliderAction:(id)sender {
    self.myLabel.text = [NSString stringWithFormat:@"%@: %.fm", NSLocalizedString(@"ray", "ray label"), self.mySlider.value];
}

- (void)reverseGeocoder:(CLGeocoder *)geocoder byLatitude: (CGFloat) latitude andLongitude: (CGFloat) longitude {
    CLLocation *aLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    [geocoder reverseGeocodeLocation:aLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        dispatch_async(dispatch_get_main_queue(),^ {
            if (placemarks.count == 1) {
                CLPlacemark *place = [placemarks objectAtIndex:0];
                
                NSString *thoroughfare = place.thoroughfare;
                NSString *subThoroughfare = place.subThoroughfare;
                NSString *locality = place.locality;
                NSString *postalCode = place.postalCode;
                NSString *country = place.country;
                
                address = [NSString stringWithFormat:@"%@, %@", thoroughfare, subThoroughfare];
                addressDetail = [NSString stringWithFormat:@"%@ %@, %@", postalCode, locality, country];
                
                NSMutableArray *annotationList = [[NSMutableArray alloc] init];
                
                MapPin *pin = [[MapPin alloc] initWithCoordinates:CLLocationCoordinate2DMake(latitude, longitude) placeName:address description:addressDetail];
                [myMapView addAnnotation:pin];
                
                [annotationList addObject: pin];
            }
        });
    }];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (void)showDetails:(id)sender {
    [self performSegueWithIdentifier:@"prox2menu" sender:sender];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *name = [sender accessibilityHint];
    Line *l = [self getLineObjFromLineName:name];
    
    LineMenuViewController *stvc = (LineMenuViewController *)[segue destinationViewController];
    [stvc setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"lineMenu", "lineMenu label"), l.name]];
    [stvc setLine:l];
}

- (Line *) getLineObjFromLineName: (NSString *) lineName {
    NSString *searchUrl = [NSString stringWithFormat:SERVER_URL_BY_LINE, lineName];
    NSData *responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:searchUrl]];
    
    NSDictionary *allDataDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    NSDictionary *lines = [allDataDictionary objectForKey:@"Lines"];
    NSArray *arrayOfLine = [lines objectForKey:@"Line"];
    NSDictionary *dict = arrayOfLine[0];
    
    Line *l = [[Line alloc] init];
    NSDictionary *timetables = [dict objectForKey:@"timetables"];
    
    l.id = [dict objectForKey:@"id"];
    l.name = [dict objectForKey:@"name"];
    l.description = [[dict objectForKey:@"description"] componentsJoinedByString:@" - "];
    l.holidays = [timetables objectForKey:@"holidays"];
    l.weekdays = [timetables objectForKey:@"weekdays"];
    l.routes = [dict objectForKey:@"routes"];
    l.polyline = [dict objectForKey:@"polyline"];
    l.notes = [dict objectForKey:@"note"];
    
    return l;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    for (MKAnnotationView *annotationView in views) {
        if (annotationView.annotation == mapView.userLocation) {
            MKCoordinateSpan span = MKCoordinateSpanMake(0.02f, 0.02f);
            MKCoordinateRegion region = MKCoordinateRegionMake(mapView.userLocation.coordinate, span);
			
            [mapView setRegion:region animated:YES];
        }
    }
}

- (MKAnnotationView *) mapView: (MKMapView *) mapView viewForAnnotation: (id<MKAnnotation>) annotation {
	MKPinAnnotationView *pin = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier: [annotation title]];
	if (pin == nil) {
		pin = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: [annotation title]];
	} else {
		pin.annotation = annotation;
	}
	
	NSString *imageName;
	
	if (annotation == mapView.userLocation) {
		return nil;
	} else if ([[annotation title] isEqualToString:address]) {
		imageName = @"pinBlue";
	} else {
		switch ([[[annotation title] substringWithRange:NSMakeRange(0, 1)] intValue]) {
			case 1:
				imageName = @"pinCiano";
				break;
			case 2:
                imageName = @"pinGray";
				break;
			case 4:
                imageName = @"pinGreen";
				break;
			case 5:
                imageName = @"pinPink";
				break;
			case 6:
                imageName = @"pinPurple";
				break;
			case 7:
                imageName = @"pinRed";
				break;
			case 8:
                imageName = @"pinYellow";
				break;
			case 9:
                imageName = @"pinOrange";
				break;
			default:
                imageName = @"pinBlack";
				break;
		}
		
		//UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		//[rightButton addTarget:self action:@selector(showDetails:) forControlEvents:UIControlEventTouchUpInside];
		
		//rightButton.tag = [[annotation subtitle] intValue];
		
		//pin.rightCalloutAccessoryView = rightButton;
	}
    
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                    reuseIdentifier:[annotation title]];
    annotationView.canShowCallout = YES;
    annotationView.image = [UIImage imageNamed:imageName];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [rightButton addTarget:self
                    action:@selector(showDetails:)
          forControlEvents:UIControlEventTouchUpInside];
    
    [rightButton setTitle:[annotation title] forState:UIControlStateNormal];
    [rightButton setTag:[[annotation subtitle] integerValue]];
    [rightButton setAccessibilityHint:[annotation title]];
    
    annotationView.rightCalloutAccessoryView = rightButton;
    annotationView.draggable = NO;
    
    return annotationView;
}

- (void) reloadTableData {
    [self showWithLabelMixed];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGFloat latitude = myMapView.userLocation.coordinate.latitude;
        CGFloat longitude = myMapView.userLocation.coordinate.longitude;
        CGFloat ray = self.mySlider.value;
        
        NSString *link = [NSString stringWithFormat:PROXIMITY, latitude, longitude, ray];
        
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:link]];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}

- (void)fetchedData:(NSData *)responseData {
    @try {
        [myMapView removeAnnotations:myMapView.annotations];
        
        NSError *parseError = nil;
        NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLData:responseData error:&parseError];
        NSDictionary *lines = [xmlDictionary objectForKey:@"Linee"];
        NSDictionary *arrayOfLine = [lines objectForKey:@"Linea"];

        if (arrayOfLine) {
            for (NSDictionary *dict in arrayOfLine) {
                NSString *name = [self getValueFromDict:dict andKey:@"name"];
                NSString *description = [self getValueFromDict:dict andKey:@"desc"];
                CGFloat latitude = [[self getValueFromDict:dict andKey:@"latitudine"] floatValue];
                CGFloat longitude = [[self getValueFromDict:dict andKey:@"longitudine"] floatValue];
                
                NSLog(@"%@ (%@) [%.6f, %6f]", description, name, latitude, longitude);
                
                NSMutableArray *annotationList = [[NSMutableArray alloc] init];
                
                MapPin *pin = [[MapPin alloc] initWithCoordinates:CLLocationCoordinate2DMake(latitude, longitude) placeName:name description:description];
                
                [myMapView addAnnotation:pin];
                
                [annotationList addObject: pin];
            }
        } else {
            [self showAlertWithTitle:@"Oops..." andMessage:[NSString stringWithFormat:NSLocalizedString(@"noLineWithinXm", "noLineWithinXm label"), self.mySlider.value]];
        }
        
        [self hideMBProgress];
    } @catch (NSException *exception) {
        [self showAlertWithTitle:@"Oops..." andMessage:NSLocalizedString(@"errorDownloadDataMessage", "errorDownloadDataMessage label")];
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    }
}

- (void) showAlertWithTitle: (NSString *) title andMessage: (NSString *) message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

- (NSString *) getValueFromDict: (NSDictionary *) dict andKey: (NSString *) key {
    return [self trimString:[[dict objectForKey:key] objectForKey:@"text"]];
}

- (NSString *) trimString: (NSString *) string {
    NSString *trimmedString = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return [trimmedString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

#pragma mark - MBProgress

- (void) showWithLabelMixed {
	MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	HUD.labelText = NSLocalizedString(@"pleaseWait", "pleaseWait label");
    HUD.detailsLabelText = NSLocalizedString(@"downloading", "downloading label");
	HUD.minSize = CGSizeMake(135.f, 135.f);
}

- (void) hideMBProgress {
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
