//
//  PolylineViewController.m
//  iamtcatania
//
//  Created by Dr Thief on 05/10/13.
//  Copyright (c) 2013 Dr Thief. All rights reserved.
//

#import "PolylineViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ASPolylineRenderer.h"

@implementation PolylineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self drawPolyline: self.arrayCoordinate];
}

- (void) drawPolyline: (NSArray *) arrayCoordinate {
    NSInteger numberOfPoints = [arrayCoordinate count];
    CLLocationCoordinate2D pointsToUse[numberOfPoints];
    
    for(NSInteger i = 0; i < numberOfPoints; i++) {
        NSArray *locations = [arrayCoordinate objectAtIndex:i];
        
        CGFloat latitude = [[locations objectAtIndex:0] floatValue];
        CGFloat longitude = [[locations objectAtIndex:1] floatValue];
        
        pointsToUse[i] = CLLocationCoordinate2DMake(latitude, longitude);
    }

	[self.myMapView addOverlay:[MKPolyline polylineWithCoordinates:pointsToUse count:numberOfPoints]];
	[self.myMapView setVisibleMapRect:[self mapRectForCoordinates:pointsToUse count:numberOfPoints]];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
	if ([overlay isKindOfClass:[MKPolyline class]]) {
		ASPolylineRenderer *polylineRenderer = [[ASPolylineRenderer alloc] initWithPolyline:(MKPolyline *)overlay];
		polylineRenderer.strokeColor    = [UIColor yellowColor];
		polylineRenderer.lineWidth      = 8.0f;
        polylineRenderer.lineJoin		= kCGLineJoinRound;
        polylineRenderer.lineCap		= kCGLineCapButt;
		
        return polylineRenderer;
	} else {
		return nil;
	}
}

- (MKMapRect)mapRectForCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count {
    MKMapRect mapRect = MKMapRectNull;
	for (int i = 0; i < count; i++) {
        MKMapPoint mapPoint = MKMapPointForCoordinate(coordinates[i]);
        MKMapRect newRect = MKMapRectMake(mapPoint.x, mapPoint.y, 1.0, 1.0);
        mapRect = MKMapRectUnion(mapRect, newRect);
    }
    
    return mapRect;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
