//
//  RoutesAndPathViewController.m
//  iamtcatania
//
//  Created by Dr Thief on 29/09/13.
//  Copyright (c) 2013 Dr Thief. All rights reserved.
//

#import "RoutesAndPathViewController.h"
#import "Constant.h"

@interface RoutesAndPathViewController ()

@end

@implementation RoutesAndPathViewController

@synthesize calendar = _calendar;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void) setLine:(Line *)line forType:(NSInteger) type {
    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [self.calendar setLocale:[NSLocale currentLocale]];
    
    switch (type) {
        case weekdays:
            items = line.weekdays;
            cellImage = [UIImage imageNamed:@"date_to-25"];
            break;
        case holidays:
            items = line.holidays;
            cellImage = [UIImage imageNamed:@"date_from-25"];
            break;
        case routes:
            items = line.routes;
            cellImage = [UIImage imageNamed:@"right_footprint-25"];
            break;
        case next10departures:
            items = [self getNextTenDeparturesByLine:line];
            cellImage = [UIImage imageNamed:@"alarm_clock-25"];
            break;
        default:
            break;
    }
    
    self.sectionsText = [NSMutableArray arrayWithObject:[NSString stringWithFormat:@"%@: \"%@\"", line.name, line.description]];
    self.sections = [NSMutableArray arrayWithObject:@"#"];
    
    if ([line.notes count] > 0) {
        for(int i = 0; i < [line.notes count]; i++){
            [self.sectionsText addObject:[line.notes objectAtIndex:i]];
            [self.sections addObject:[NSString stringWithFormat:@"*"]];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionArray = [self getFilteredArrayForSearchText:[self.sections objectAtIndex:section]];
    NSInteger count = [sectionArray count];
    
    if (count == 0 && section == 0) {
        count = 1;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sectionArray = [self getFilteredArrayForSearchText:[self.sections objectAtIndex:indexPath.section]];
    
    NSInteger count = [sectionArray count];
    
    if (count > 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemCell" forIndexPath:indexPath];
        
        cell.textLabel.text = [sectionArray objectAtIndex:indexPath.row];
        cell.imageView.image = cellImage;
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemCell" forIndexPath:indexPath];
        
        cell.textLabel.text = NSLocalizedString(@"noData", "noData label");
        
        return cell;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sectionsText objectAtIndex:section];
}

- (NSArray *) getFilteredArrayForSearchText:(NSString*)searchText {
    NSString *toSearch = @"SELF endswith %@";
    
    if ([searchText isEqualToString:@"#"]) {
        //searchText = @"0-9";
        toSearch = @"(SELF MATCHES '[0-9][0-9]:[0-9][0-9]') OR (SELF MATCHES '^[a-zA-Z].*')";
    }
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:toSearch, searchText];
    
    return [items filteredArrayUsingPredicate:resultPredicate];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSArray *) getNextTenDeparturesByLine: (Line *) line {
    NSDate *today = [NSDate date];
    
    //Estraggo da NSDate l'ora corrente e il giorno della settimana
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [currentCalendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:today];
    
    // Estraggo i valori di ogni variabile e li salvo in degli interi
    NSInteger hour = [dateComponents hour];
    NSInteger min = [dateComponents minute];
    
    //salvo l'ora corrente in un intero
    NSInteger localTime = hour * 60 + min;
    NSArray *toReturn;
    
    if ([self isHoliday:today]) {
        toReturn = [self getNextTenDeparturesByTimesheet:line.holidays andLocalTime:localTime];
    } else {
        toReturn = [self getNextTenDeparturesByTimesheet:line.weekdays andLocalTime:localTime];
    }
    
    return toReturn;
}


- (NSArray *) getNextTenDeparturesByTimesheet: (NSArray *) timesheet andLocalTime: (NSInteger) localTime {
    NSMutableArray *toReturn = [[NSMutableArray alloc] initWithCapacity:10];
    int i = 0;
    
    if ([timesheet count] > 0) {
        for (int j = 0; j < [timesheet count]; j++) {
            @try {
                //prendo la componente hh:mm
                NSString *tempOraMinuti = [timesheet objectAtIndex:j];
                
                //e la separo in base a ":"
                NSArray *tempOrario = [tempOraMinuti componentsSeparatedByString: @":"];
                
                //creo due array temporanei per contenere le stringhe ora e minuti
                NSString *tempOra = [tempOrario objectAtIndex:0];
                NSString *tempMinuti = [tempOrario objectAtIndex:1];
                
                //e me le trasformo in interi
                NSCharacterSet* nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
                int valueOra = [[tempOra stringByTrimmingCharactersInSet:nonDigits] intValue];
                int valueMinuti = [[tempMinuti stringByTrimmingCharactersInSet:nonDigits] intValue];
                
                //salvo l'ora del db in un intero
                int dbTime = valueOra * 60 + valueMinuti;
                
                //ed effettuo il confronto tra l'ora attuale e quella del db
                if (dbTime > localTime) {
                    if (i < 10) {
                        [toReturn addObject:tempOraMinuti];
                        i++;
                    } else {
                        return toReturn;
                    }
                }
            } @catch (NSException *exception) {
                NSLog(@"%@", exception);
                [toReturn addObject:[timesheet objectAtIndex:j]];
            }
        }
    }
    
    return toReturn;
}

#pragma mark Calendar

- (NSDate *) calculateEasterDateByYear:(NSInteger) year {
    NSInteger C = floor(year/100);
    NSInteger N = year - (19 * floor(year/19));
    NSInteger K = floor((C - 17)/25);
    NSInteger I = C - floor(C/4) - floor((C - K)/3) + 19 * N + 15;
    
    I = I - 30 * floor((I/30));
    I = I - floor(I/28) * (1 - floor(I/28) * floor(29/(I + 1)) * floor((21 - N)/11));
    
    NSInteger J = year + floor(year/4) + I + 2 - C + floor(C/4);
    J = J - 7 * floor(J/7);
    
    NSInteger L = I - J;
    NSInteger month = 3 + floor((L + 40)/44);
    NSInteger day = L + 28 - 31 * floor(month/4);
    
    return [self getDateFromYear:year month:month andDay:day];
}

- (BOOL) isHoliday: (NSDate *) date {
    BOOL isHoliday = false;
    NSInteger year = [self getYearFromDate:date];
    NSInteger weekday = [[self.calendar components:NSCalendarUnitWeekday fromDate:date] weekday];
    
    NSDate *newYearDay = [self getDateFromYear:year month:1 andDay:1];
    NSDate *epiphanyDay = [self getDateFromYear:year month:1 andDay:6];
    NSDate *sundayEasterDay = [self calculateEasterDateByYear:year];
    NSDate *mondayEasterDay = [self addDay:sundayEasterDay];
    NSDate *liberationDay = [self getDateFromYear:year month:4 andDay:25];
    NSDate *laborDay = [self getDateFromYear:year month:5 andDay:1];
    NSDate *republicDay = [self getDateFromYear:year month:6 andDay:2];
    NSDate *assumptionDay = [self getDateFromYear:year month:8 andDay:15];
    NSDate *allSaintDay = [self getDateFromYear:year month:11 andDay:2];
    NSDate *immaculateDay = [self getDateFromYear:year month:12 andDay:8];
    NSDate *christmasDay = [self getDateFromYear:year month:12 andDay:25];
    NSDate *sStephanDay = [self getDateFromYear:year month:12 andDay:26];
    
    if ([date isEqualToDate:newYearDay] || [date isEqualToDate:epiphanyDay] || [date isEqualToDate:sundayEasterDay] || [date isEqualToDate:mondayEasterDay] || [date isEqualToDate:liberationDay] || [date isEqualToDate:laborDay] || [date isEqualToDate:republicDay] || [date isEqualToDate:assumptionDay] || [date isEqualToDate:allSaintDay] || [date isEqualToDate:immaculateDay] || [date isEqualToDate:christmasDay] || [date isEqualToDate:sStephanDay] || weekday == [self.calendar firstWeekday]) {
        isHoliday = true;
    }
    
    return isHoliday;
}

#pragma mark Calendar Functions

- (NSInteger) getYearFromDate:(NSDate *)date {
    NSDateComponents *components = [self.calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    
    return [components year];
}

- (NSDate *) getDateFromYear:(NSInteger) year month:(NSInteger) month andDay:(NSInteger) day {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    [components setDay:day];
    [components setMonth:month];
    [components setYear:year];
    
    return [self.calendar dateFromComponents:components];
}

- (NSDate *)addDay:(NSDate *)date {
    NSDateComponents *components = [self.calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    components.day = components.day + 1;
    
    return [self.calendar dateFromComponents:components];
}

@end
