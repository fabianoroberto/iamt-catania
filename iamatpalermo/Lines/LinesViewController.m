//
//  LinesViewController.m
//  iamtcatania
//
//  Created by Dr Thief on 15/09/13.
//  Copyright (c) 2013 Dr Thief. All rights reserved.
//

#import "LinesViewController.h"
#import "LineMenuViewController.h"
#import "Line.h"
#import "Constant.h"

@implementation LinesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.hidesNavigationBarDuringPresentation = false;
    self.searchController.dimsBackgroundDuringPresentation = false;
    self.searchController.definesPresentationContext = true;
    self.searchController.searchBar.placeholder = NSLocalizedString(@"searchLines", "searchLines label");
    
    [self.searchController.searchBar sizeToFit];

    self.navigationItem.titleView = self.searchController.searchBar;
    self.searchController.delegate = self;

    //self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];

    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPad"]) {
        cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(stopEditing)];
    }

    self.sections = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"*", nil];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = UIColorFromRGB(0xDAE1E6);
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(reloadData)
                  forControlEvents:UIControlEventValueChanged];

    [self reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger toReturn = 1;
    
    if (!self.searchController.active) {
        toReturn = [self.sections count];
    }
    
    return toReturn;
}

/*- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.sections;
}*/

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    //return index;
    if (tableView == self.tableView) {
        if (index > 0) {
            return index;
        } else {
            self.tableView.contentOffset = CGPointZero;
            return NSNotFound;
        }
    } else {
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *toReturn = NSLocalizedString(@"searchResults", "searchResults label");
    
    if (!self.searchController.active) {
        toReturn = [NSString stringWithFormat:@"%@ %@**", NSLocalizedString(@"section", "section label"), [self.sections objectAtIndex:section]];
    }
    
    return toReturn;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger toReturn = 0;
    
    if (self.searchController.active) {
        toReturn = [searchResults count];
    } else {
        NSArray *sectionArray = [self getFilteredArrayForSearchText:[self.sections objectAtIndex:section]];
        
        toReturn = [sectionArray count];
    }
    
    if (toReturn == 0) {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, self.view.bounds.size.width - 30, self.view.bounds.size.height)];
        
        if (self.searchController.active) {
            messageLabel.text = NSLocalizedString(@"noResult", "noResult label");
        } else {
            messageLabel.text = NSLocalizedString(@"noLine", "noLine label");
        }
        
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    } else {
        self.tableView.backgroundView = [UIView new];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    
    return toReturn;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LineCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (self.searchController.active) {
        cell.textLabel.text = [[searchResults objectAtIndex:indexPath.row] name];
        cell.detailTextLabel.text = [[searchResults objectAtIndex:indexPath.row] description];
    } else {
        NSArray *sectionArray = [self getFilteredArrayForSearchText:[self.sections objectAtIndex:indexPath.section]];
        
        cell.textLabel.text = [[sectionArray objectAtIndex:indexPath.row] name];
        cell.detailTextLabel.text = [[sectionArray objectAtIndex:indexPath.row] description];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
        return 0;
    } else {
        return 30;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    Line *l;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    if (self.searchController.active) {
        NSLog(@"Search Display Controller");
        l = [searchResults objectAtIndex:indexPath.row];
    } else {
        NSLog(@"Default Display Controller");
        NSArray *sectionArray = [self getFilteredArrayForSearchText:[self.sections objectAtIndex:self.tableView.indexPathForSelectedRow.section]];
        
        l = [sectionArray objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    }
    
    LineMenuViewController *stvc = (LineMenuViewController *)[segue destinationViewController];
    [stvc setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"lineMenu", "lineMenu label"), l.name]];
    [stvc setLine:l];
}

#pragma mark - SEARCH

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString scope:searchController.searchBar.selectedScopeButtonIndex];
    [self.tableView reloadData];
}

- (void)searchForText:(NSString *)searchText scope:(NSInteger)scopeOption
{
    NSString *toSearch = @"(name CONTAINS[c] %@) OR (description CONTAINS[c] %@)";
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:toSearch, searchText, searchText];
    
    searchResults = [_lines filteredArrayUsingPredicate:resultPredicate];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    NSString *toSearch = @"(name CONTAINS[c] %@) OR (description CONTAINS[c] %@)";
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:toSearch, searchText, searchText];
    
    searchResults = [_lines filteredArrayUsingPredicate:resultPredicate];
}

- (NSArray *) getFilteredArrayForSearchText:(NSString*)searchText {
    NSString *toSearch = @"name beginswith[c] %@";
    if ([searchText isEqualToString:@"*"]) {
        toSearch = @"name MATCHES '^[a-zA-Z].*'";
    }
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:toSearch, searchText];
    
    return [_lines filteredArrayUsingPredicate:resultPredicate];
}

- (void)didPresentSearchController:(UISearchController *)searchController
{
    [self.navigationItem setRightBarButtonItem:cancelButton animated:YES];
    [self.refreshControl setHidden:true];
}

- (void)stopEditing {
    [self.searchController setActive:NO];
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    [self.refreshControl setHidden:false];
    [self.searchController.searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self stopEditing];
}

#pragma mark - PARSING DATA

- (IBAction)startSearch:(id)sender {
    if (self.searchController.active) {
        [self.searchController setActive:NO];
        //self.searchController.searchBar.hidden = NO;
        self.searchController.searchBar.text = @"";
        [self.searchController.searchBar resignFirstResponder];
    } else {
        [self.searchController setActive:YES];
        //self.searchController.searchBar.hidden = NO;
        self.searchController.searchBar.text = @"";
        [self.searchController.searchBar becomeFirstResponder];
    }
}

- (void) reloadData {
    if (self.searchController.active) {
        [self.refreshControl endRefreshing];
    } else {
        [self showWithLabelMixed];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:SERVER_URL]];
            [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
        });        
    }
}

- (void)fetchedData:(NSData *)responseData {
    @try {
        NSDictionary *allDataDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        NSDictionary *lines = [allDataDictionary objectForKey:@"Lines"];
        NSArray *arrayOfLine = [lines objectForKey:@"Line"];
        NSMutableArray *linesTMP = [[NSMutableArray alloc] initWithCapacity:[allDataDictionary count]];
        
        for (NSDictionary *dict in arrayOfLine) {
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
            
            [linesTMP addObject:l];
        }
        
        self.lines = [linesTMP copy];
        [self hideMBProgress];
        
        if (self.refreshControl) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:NSLocalizedString(@"dateFormatter", "dateFormatter label")];
            NSString *title = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"lastUpdate", "lastUpdate label"), [formatter stringFromDate:[NSDate date]]];
            NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                        forKey:NSForegroundColorAttributeName];
            NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
            self.refreshControl.attributedTitle = attributedTitle;
            
            [self.refreshControl endRefreshing];
        }
    } @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops..." message:NSLocalizedString(@"errorDownloadDataMessage", "errorDownloadDataMessage label") delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        [self.refreshControl endRefreshing];
        [alert show];
    }
}

#pragma mark - MBProgress

- (void) showWithLabelMixed {
	MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	HUD.labelText = NSLocalizedString(@"pleaseWait", "pleaseWait label");
    HUD.detailsLabelText = NSLocalizedString(@"downloading", "downloading label");
	HUD.minSize = CGSizeMake(135.f, 135.f);
}

- (void) hideMBProgress {
    [self.tableView reloadData];
   /*
    if ([_lines count] > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    */
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

@end
