//
//  SearchController.m
//  iamtcatania
//
//  Created by Dr Thief on 02/01/14.
//  Copyright (c) 2014 Dr Thief. All rights reserved.
//

#import "SearchController.h"

#define kPickerAnimationDuration 0.40
#define kPickerTag 99

#define kTitleKey @"title"
#define kValueKey @"value"
#define kPlaceholderKey @"placeholder"

#define SECTION_HEADER_HEIGHT 100;
#define SECTION_IPAD_HEADER_HEIGHT 160;
#define SECTION_FOOTER_HEIGHT 50;
#define SECTION_IPAD_FOOTER_HEIGHT 100;

static NSString *kDepartureCell = @"departureCell";
static NSString *kAlternativeCell = @"alternativeCell";
static NSString *kPickerID = @"pickerCell";
static NSString *kSliderCell = @"sliderCell";

@implementation SearchController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self.pickerView setDataSource:self];
        [self.pickerView setDelegate:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _searchObj = [[SearchObject alloc] init];
    _searchObj.departure = @"";
    _searchObj.destination = @"";
    _searchObj.alternative = 1;
    _searchObj.distance = 250;

    self.alternatives = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", nil];
    
    NSMutableDictionary *itemOne = [@{ kTitleKey : NSLocalizedString(@"departure", "departure label"), kValueKey : @"", kPlaceholderKey : @"es. via Etnea" } mutableCopy];
    NSMutableDictionary *itemTwo = [@{ kTitleKey : NSLocalizedString(@"destination", "destination label"), kValueKey : @"", kPlaceholderKey : @"es. piazza Roma" } mutableCopy];
    
    NSMutableDictionary *itemThree = [@{ kTitleKey : NSLocalizedString(@"alternative", "alternative label"), kValueKey: [NSString stringWithFormat:@"%ld", (long)_searchObj.alternative] } mutableCopy];
    
    NSMutableDictionary *itemFour = [@{ kTitleKey : NSLocalizedString(@"distance", "distance label"), kValueKey : [NSString stringWithFormat:@"%ld", (long)_searchObj.distance] } mutableCopy];
    NSMutableDictionary *itemFive = [@{ kValueKey : [NSString stringWithFormat:@"%ld", (long)_searchObj.distance] } mutableCopy];

    self.dataArray = @[@[itemOne, itemTwo], @[itemThree], @[itemFour, itemFive]];
    
    
    UITableViewCell *pickerViewCellToCheck = [self.tableView dequeueReusableCellWithIdentifier:kPickerID];
    self.pickerCellRowHeight = pickerViewCellToCheck.frame.size.height;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Text Field data souce

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == 2) {
        _searchObj.departure = textField.text;
    } else if(textField.tag == 3) {
        _searchObj.destination = textField.text;
    }
}

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL toReturn = YES;
    
    if([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
    }
    
    return toReturn;
}

#pragma mark PickerView Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.alternatives count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *toReturn = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"alternative", "alternative label"), [self.alternatives objectAtIndex:row]];
    
    return toReturn;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *selectedAlternative = [self.alternatives objectAtIndex: row];
    NSIndexPath *targetedCellIndexPath = nil;
    
    if ([self hasInlinePicker]) {
        // inline date picker: update the cell's date "above" the date picker cell
        targetedCellIndexPath = [NSIndexPath indexPathForRow:self.pickerIndexPath.row - 1 inSection:1];
    } else {
        // external date picker: update the current "selected" cell's date
        targetedCellIndexPath = [self.tableView indexPathForSelectedRow];
    }
    
    _searchObj.alternative = row;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:targetedCellIndexPath];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", selectedAlternative];
}

#pragma mark - Locale

/*
 * Responds to region format or locale changes.
 */
- (void)localeChanged:(NSNotification *)notif
{
    // the user changed the locale (region format) in Settings, so we are notified here to
    // update the date format in the table view cells
    [self.tableView reloadData];
}

#pragma mark - Utilities

/*
 * Returns the major version of iOS, (i.e. for iOS 6.1.3 it returns 6)
 */
NSUInteger DeviceSystemMajorVersion()
{
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    
    return _deviceSystemMajorVersion;
}

#define EMBEDDED_DATE_PICKER (DeviceSystemMajorVersion() >= 7)
/*
 * Determines if the given indexPath has a cell below it with a UIPickerView.
 * @param indexPath The indexPath to check if its cell has a UIPickerView below it.
 */
- (BOOL)hasPickerForIndexPath:(NSIndexPath *)indexPath
{
    BOOL hasDatePicker = NO;
    
    NSInteger targetedRow = indexPath.row;
    targetedRow++;
    
    UITableViewCell *checkDatePickerCell =
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:targetedRow inSection:1]];
    UIPickerView *checkDatePicker = (UIPickerView *)[checkDatePickerCell viewWithTag:kPickerTag];
    
    hasDatePicker = (checkDatePicker != nil);
    return hasDatePicker;
}

/*
 * Updates the UIPickerView's value to match with the date of the cell above it.
 */
- (void) updatePickerView
{
    if (self.pickerIndexPath != nil)
    {
        UITableViewCell *associatedDatePickerCell = [self.tableView cellForRowAtIndexPath:self.pickerIndexPath];
        
        UIPickerView *targetedDatePicker = (UIPickerView *)[associatedDatePickerCell viewWithTag:kPickerTag];
        
        if (targetedDatePicker != nil)
        {
//            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//            NSInteger sectionRow = [prefs integerForKey:@"section"];
//            NSInteger jumpRow = [prefs integerForKey:@"jump"];
            
//            [targetedDatePicker selectRow:sectionRow inComponent:0 animated:YES];
//            [targetedDatePicker selectRow:jumpRow inComponent:1 animated:YES];
        }
    }
}

/*
 * Determines if the UITableViewController has a UIPickerView in any of its cells.
 */
- (BOOL)hasInlinePicker
{
    return (self.pickerIndexPath != nil);
}

/*
 * Determines if the given indexPath points to a cell that contains the UIPickerView.
 * @param indexPath The indexPath to check if it represents a cell with the UIPickerView.
 */
- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath
{
    return ([self hasInlinePicker] && self.pickerIndexPath.row == indexPath.row);
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger height = self.tableView.rowHeight;
    
    if (indexPath.section == 1 && [self indexPathHasPicker:indexPath]) {
        height = self.pickerCellRowHeight;
    }
    
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = [[self.dataArray objectAtIndex:section] count];
    
    if (section == 1 && [self hasInlinePicker]) {
        return ++numRows;
    }
    
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    NSDictionary *itemData;
    NSString *cellID;
    NSInteger modelRow = indexPath.row;
    NSInteger tag = pow(2, indexPath.section) + pow(2, indexPath.row);
    
    switch ([indexPath section]) {
        case 0: {
            cellID = kDepartureCell;
            TextFieldCell *textFieldCell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
            
            itemData = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:modelRow];
            
            textFieldCell.myLabel.text = [itemData valueForKey:kTitleKey];
            textFieldCell.myTextField.text = [NSString stringWithFormat:@"%@", [itemData valueForKey:kValueKey]];
            textFieldCell.myTextField.placeholder = [NSString stringWithFormat:@"%@", [itemData valueForKey:kPlaceholderKey]];
            
            [textFieldCell.myTextField setTag: tag];
            
            textFieldCell.myLabel.font = [UIFont systemFontOfSize:15];
            textFieldCell.myTextField.font = [UIFont systemFontOfSize:15];
            
            textFieldCell.myTextField.delegate = self;
            textFieldCell.myTextField.returnKeyType = UIReturnKeyDone;
            
            cell = textFieldCell;
            
            break;
        }
        case 1:
            cellID = kAlternativeCell;
            
            if ([self indexPathHasPicker:indexPath]) {
                // the indexPath is the one containing the inline date picker
                // the current/opened date picker cell
                cellID = kPickerID;
                modelRow--;
            }
            
            cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            
            if (indexPath.row == 0) {
                // we decide here that first cell in the table is not selectable (it's just an indicator)
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            itemData = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:modelRow];
            
            // proceed to configure our cell
            if ([cellID isEqualToString:kAlternativeCell]) {
                // we have either start or end date cells, populate their date field
                cell.textLabel.text = [itemData valueForKey:kTitleKey];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [itemData valueForKey:kValueKey]];
            }
            
            break;
        case 2: {
            if (modelRow == 0) {
                cellID = kAlternativeCell;
                cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                
                itemData = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:modelRow];
                
                cell.textLabel.text = [itemData valueForKey:kTitleKey];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [itemData valueForKey:kValueKey]];
            } else {
                cellID = kSliderCell;
                SliderCell *sliderCell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
                
                itemData = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:modelRow];
                
                sliderCell.mySlider.value = [[itemData valueForKey:kValueKey] integerValue];
                
                [sliderCell.mySlider addTarget:self action:@selector(onChangeSlider:) forControlEvents:UIControlEventValueChanged];
                cell = sliderCell;
            }
            
            break;
        }
    }
    
	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    CGFloat height = SECTION_HEADER_HEIGHT;
    CGFloat scale = 1.5;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        height = SECTION_IPAD_HEADER_HEIGHT;
        scale = 1;
    }
    
    static UIView *headerView;
    
    if (headerView != nil) {
        return headerView;
    }
    
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, height)];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIImage *originalImage = [UIImage imageNamed:@"Banner"];
    // scaling set to 2.0 makes the image 1/2 the size.
    UIImage *scaledImage = [UIImage imageWithCGImage:[originalImage CGImage] scale:(originalImage.scale * scale) orientation:(originalImage.imageOrientation)];
    
    UIImageView *headerImage = [[UIImageView alloc] initWithImage:scaledImage];
    
    headerImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    headerImage.center = CGPointMake(headerView.bounds.size.width/2, headerView.bounds.size.height/2);
    
    [headerView addSubview:headerImage];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat toReturn = 0.0;
    
    if (section == 2) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            toReturn = SECTION_IPAD_FOOTER_HEIGHT
        } else {
            toReturn = SECTION_FOOTER_HEIGHT;
        }
    }
    
    return toReturn;
}

- (void) onChangeSlider:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSInteger sliderValue = [[NSNumber numberWithFloat:[slider value]] integerValue];
    
    NSIndexPath *targetedCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:targetedCellIndexPath];
    
    _searchObj.distance = sliderValue;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)sliderValue];
}

/*
 * Adds or removes a UIPickerView cell below the given indexPath.
 * @param indexPath The indexPath to reveal the UIPickerView.
 */
- (void)togglePickerForSelectedIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:1]];
    
    // check if 'indexPath' has an attached date picker below it
    if ([self hasPickerForIndexPath:indexPath]) {
        // found a picker below it, so remove it
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    } else {
        // didn't find a picker below it, so we should insert it
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.tableView endUpdates];
}

/*
 * Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath".
 * @param indexPath The indexPath to reveal the UIPickerView.
 */
- (void)displayInlineDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // display the date picker inline with the table content
    [self.tableView beginUpdates];
    
    // indicates if the date picker is below "indexPath", help us determine which row to reveal
    BOOL before = NO;
    if ([self hasInlinePicker]) {
        before = self.pickerIndexPath.row < indexPath.row;
    }
    
    BOOL sameCellClicked = (self.pickerIndexPath.row - 1 == indexPath.row);
    
    // remove any date picker cell if it exists
    if ([self hasInlinePicker]) {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.pickerIndexPath.row inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
        self.pickerIndexPath = nil;
    }
    
    if (!sameCellClicked) {
        // hide the old date picker and display the new one
        NSInteger rowToReveal = (before ? indexPath.row - 1 : indexPath.row);
        NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:rowToReveal inSection:1];
        
        [self togglePickerForSelectedIndexPath:indexPathToReveal];
        self.pickerIndexPath = [NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:1];
    }
    
    // always deselect the row containing the start or end date
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView endUpdates];
    
    // inform our date picker of the current date to match the current cell
    [self updatePickerView];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndex:2];
//    [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationAutomatic];
//    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    switch (indexPath.section) {
        case 1:
            if (cell.reuseIdentifier == kAlternativeCell) {
                [self displayInlineDatePickerForRowAtIndexPath:indexPath];
            } else {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
            
            break;
        default:
            break;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *departure = [self addressLocation:[NSString stringWithFormat:@"Catania, %@", _searchObj.departure]];
    NSString *destination = [self addressLocation:[NSString stringWithFormat:@"Catania, %@", _searchObj.destination]];
    
    NSString *searchUrl = [NSString stringWithFormat:SEARCH_URL, departure, _searchObj.distance, destination, _searchObj.alternative];
    
    DetailSearchController *stvc = (DetailSearchController *)[segue destinationViewController];
    [stvc setUrl:searchUrl];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    BOOL toReturn = YES;
    
    if ([_searchObj.departure length] == 0 || [_searchObj.destination length] == 0) {
        toReturn = NO;
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "error label") message:NSLocalizedString(@"insertDepartureAndDestination", "insertDepartureAndDestination label") delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		
		[alert show];
	}
    
    return toReturn;
}

-(NSString *) addressLocation: (NSString *) tmpIndirizzo {
	NSString *urlString = [NSString stringWithFormat:GOOGLE_API, [tmpIndirizzo stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSData *responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
	NSDictionary *allDataDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
	
	NSDictionary *results = allDataDictionary[@"results"][0];
	NSDictionary *geometry = results[@"geometry"];
	NSDictionary *location = geometry[@"location"];
	NSString *latitude = location[@"lat"];
	NSString *longitude = location[@"lng"];
	
	return [NSString stringWithFormat:@"%@,%@", latitude, longitude];
}

@end
