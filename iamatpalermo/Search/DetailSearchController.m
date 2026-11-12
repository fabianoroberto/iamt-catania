//
//  DetailSearchController.m
//  iamtcatania
//
//  Created by Dr Thief on 04/01/14.
//  Copyright (c) 2014 Dr Thief. All rights reserved.
//

#import "DetailSearchController.h"

@interface DetailSearchController ()

@end

@implementation DetailSearchController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.lines = [[NSArray alloc] init];
    [self reloadTableData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.lines count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LineCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *line = [self.lines objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [line objectForKey:@"name"];
    cell.detailTextLabel.text = [line objectForKey:@"description"];
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSDictionary *line = [self.lines objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    NSString *numberOfLine = [self getIdByString:[line objectForKey:@"name"]];
    
    Line *l = [self.linesDict objectForKey:numberOfLine];
    
    LineMenuViewController *stvc = (LineMenuViewController *)[segue destinationViewController];
    [stvc setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"lineMenu", "lineMenu label"), l.name]];
    [stvc setLine:l];
}

- (void) reloadTableData {
    [self showWithLabelMixed];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *lineData = [NSData dataWithContentsOfURL:[NSURL URLWithString:SERVER_URL]];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.url]];
        [self performSelectorOnMainThread:@selector(fetchedLineData:) withObject:lineData waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}

- (void) fetchedData:(NSData *) responseData {
    NSMutableArray *tmpLines = [[NSMutableArray alloc] init];
    
    @try {
        NSArray *allDataDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        
        for (NSDictionary *dict in allDataDictionary) {
            NSString *name = [dict objectForKey:@"name"];
            NSString *description = [dict objectForKey:@"desc"];
            NSString *p0 = [dict objectForKey:@"p0"];
            
            if ([p0 isEqualToString:@"off"]) {
                NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
                [tempDictionary setObject:description forKey:@"description"];
                [tempDictionary setObject:name forKey:@"name"];
                
                [tmpLines addObject:tempDictionary];
            }
        }
        
        self.lines = [NSArray arrayWithArray:tmpLines];
        [self hideMBProgress];
    } @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops..." message:NSLocalizedString(@"errorDownloadDataMessage", "errorDownloadDataMessage label") delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        [alert show];
    }
}

- (void)fetchedLineData:(NSData *)responseData {
    @try {
        NSDictionary *allDataDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        NSDictionary *lines = [allDataDictionary objectForKey:@"Lines"];
        NSArray *arrayOfLine = [lines objectForKey:@"Line"];
        NSMutableDictionary *linesTMP = [[NSMutableDictionary alloc] init];
        
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
            
            NSString *numberOfLine = [self getIdByString:l.name];
           
            [linesTMP setObject:l forKey:numberOfLine];
        }
        
        self.linesDict = [linesTMP copy];
    } @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops..." message:NSLocalizedString(@"errorDownloadDataMessage", "errorDownloadDataMessage label") delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        [alert show];
    }
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
    [self.tableView reloadData];
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

- (NSString *) getIdByString: (NSString *) numberOfLine {
    numberOfLine = [numberOfLine lowercaseString];
    numberOfLine = [numberOfLine stringByReplacingOccurrencesOfString:@"(andata)" withString:@""];
    numberOfLine = [numberOfLine stringByReplacingOccurrencesOfString:@"(ritorno)" withString:@""];
    numberOfLine = [numberOfLine stringByReplacingOccurrencesOfString:@" " withString:@""];
    numberOfLine = [numberOfLine uppercaseString];
    
    return numberOfLine;
}

@end
