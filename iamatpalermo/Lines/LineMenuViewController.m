//
//  LineMenuViewController.m
//  iamtcatania
//
//  Created by Dr Thief on 16/09/13.
//  Copyright (c) 2013 Dr Thief. All rights reserved.
//

#import "LineMenuViewController.h"
#import "MenuCollctionCell.h"
#import "RoutesAndPathViewController.h"
#import "PDFViewController.h"
#import "PolylineViewController.h"
#import "Constant.h"

@implementation LineMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 6;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MenuCollctionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MenuCell" forIndexPath:indexPath];
    
    [cell.layer setBorderWidth:1.0f];
    [cell.layer setBorderColor:UIColorFromRGB(0xDAE1E6).CGColor];
    
    cell.backgroundColor = UIColorFromRGB(0xFFFFFF);
    cell.menuItemLabel.textColor = UIColorFromRGB(0x000000);
    
    [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];

    switch (indexPath.row) {
        case weekdays:
            cell.menuItemLabel.text = NSLocalizedString(@"weekdays", "weekdays label");
            cell.menuItemImage.image = [UIImage imageNamed:@"date_to-32"];

            break;
        case holidays:
            cell.menuItemLabel.text = NSLocalizedString(@"holidays", "holidays label");
            cell.menuItemImage.image = [UIImage imageNamed:@"date_from-32"];
            
            break;
        case routes:
            cell.menuItemLabel.text = NSLocalizedString(@"routes", "routes label");
            cell.menuItemImage.image = [UIImage imageNamed:@"right_footprint-32"];

            break;
        case next10departures:
            cell.menuItemLabel.text = NSLocalizedString(@"next10departuresBR", "next10departuresBR label");
            cell.menuItemLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.menuItemLabel.numberOfLines = 2;
            cell.menuItemImage.image = [UIImage imageNamed:@"alarm_clock-32"];

            break;
        case pdf:
            cell.menuItemLabel.text = @"PDF";
            cell.menuItemImage.image = [UIImage imageNamed:@"pdf-32"];

            break;
        case maps:
            cell.menuItemLabel.text = NSLocalizedString(@"lineMap", "lineMap label");
            cell.menuItemImage.image = [UIImage imageNamed:@"polyline-32"];

            break;
        default:
            break;
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout  *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Adjust cell size for orientation
    CGFloat frameWidth = self.collectionView.frame.size.width - 4;
    CGFloat frameHeigth = [self getMenuHeight];
    
    NSInteger cellPerRow = 2;
    NSInteger cellPerCol = 3;
    
    CGFloat width = ceil(frameWidth / cellPerRow);
    CGFloat height = ceil(frameHeigth / cellPerCol);
    
    UIDeviceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
    
    if (UIDeviceOrientationIsLandscape(interfaceOrientation)) {
        cellPerRow = 3;
        cellPerCol = 2;
        
        frameWidth = frameWidth - 4;
        
        width = ceil(frameWidth / cellPerRow);
        height = ceil(frameHeigth / cellPerCol);
    }
    
    if (height > width) {
        height = width;
    }
    
    return CGSizeMake(width, height);
}

- (CGFloat) getMenuHeight {
    CGFloat frameHeigth = self.collectionView.frame.size.height;
    CGFloat tabBarHeight = 0;//self.tabBarController.tabBar.frame.size.height;
    CGFloat navBarHeight = 0;//self.navigationController.navigationBar.frame.size.height;
    
    return (frameHeigth - tabBarHeight - navBarHeight - 4);
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                               duration:(NSTimeInterval)duration {
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case weekdays:
        case holidays:
        case routes:
        case next10departures:
            [self performSegueWithIdentifier:@"RPView" sender:indexPath];
            break;
        case pdf:
            [self performSegueWithIdentifier:@"PDFView" sender:indexPath];
            break;
        case maps:
            if ([_line.polyline count] > 0) {
                [self performSegueWithIdentifier:@"PolyView" sender:indexPath];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"warning", "warning label") message:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"mapNotAvailable", "mapNotAvailable label"), _line.name] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
            
            break;
        default:
            break;
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.collectionView indexPathsForSelectedItems][0];
    
    RoutesAndPathViewController *detail;
    PDFViewController *pdfDetail;
    PolylineViewController * polyDetail;
    
    switch (indexPath.row) {
        case weekdays:
            detail = (RoutesAndPathViewController *)[segue destinationViewController];
            [detail setTitle:NSLocalizedString(@"weekdays", "weekdays label")];
            [detail setLine:_line forType:indexPath.row];
            
            break;
        case holidays:
            detail = (RoutesAndPathViewController *)[segue destinationViewController];
            [detail setTitle:NSLocalizedString(@"holidays", "holidays label")];
            [detail setLine:_line forType:indexPath.row];
            
            break;
        case routes:
            detail = (RoutesAndPathViewController *)[segue destinationViewController];
            [detail setTitle:NSLocalizedString(@"routes", "routes label")];
            [detail setLine:_line forType:indexPath.row];
            
            break;
        case next10departures:
            detail = (RoutesAndPathViewController *)[segue destinationViewController];
            [detail setTitle:NSLocalizedString(@"next10departures", "next10departures label")];
            [detail setLine:_line forType:indexPath.row];
            
            break;
        case pdf:
            pdfDetail = (PDFViewController *)[segue destinationViewController];
            [pdfDetail setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"linePDF", "linePDF label"), _line.name]];
            [pdfDetail setNumberOfLine:[_line.name uppercaseString]];
            
            break;
        case maps:
            polyDetail = (PolylineViewController *)[segue destinationViewController];
            [polyDetail setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"lineMap", "lineMap label"), _line.name]];
            [polyDetail setArrayCoordinate:_line.polyline];
            
        default:
            break;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
    BOOL toReturn = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "error label") message:NSLocalizedString(@"featureNotAvailable", "featureNotAvailable label") delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
    switch (indexPath.row) {
        case weekdays:
        case holidays:
        case routes:
        case next10departures:
        case pdf:
            break;
        case maps:
            if ([_line.polyline count] > 0) {
                toReturn = YES;
            } else {
                [alert show];
                toReturn = NO;
            }
        
            break;
        default:
            [alert show];
            toReturn = NO;
            
            break;
    }
    
    return toReturn;
}

@end
