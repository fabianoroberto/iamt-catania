//
//  SettingsViewController.m
//  turniquintaps
//
//  Created by Dr Thief on 18/12/13.
//  Copyright (c) 2013 Dr Thief. All rights reserved.
//

#import "SettingsViewController.h"

#define kTitleKey @"title"
#define kSubTitleKey @"subtitle"
#define kImageKey @"image"
#define kUrlKey @"url"

#define SECTION_HEADER_HEIGHT 100;
#define SECTION_IPAD_HEADER_HEIGHT 160;
#define SECTION_FOOTER_HEIGHT 50;
#define SECTION_IPAD_FOOTER_HEIGHT 100;

static NSString *kInfoCell = @"settingsCell";

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadData];
}

- (void) reloadData {
    NSMutableDictionary *item1 = [@{ kTitleKey : @"iAMT Catania", kSubTitleKey : @"Facebook", kImageKey : @"facebook", kUrlKey : @"https://www.facebook.com/iamtcatania"} mutableCopy];
    //NSMutableDictionary *item2 = [@{ kTitleKey : @"eMail", kSubTitleKey : @"fabiano.roberto@alice.it", kImageKey : @"email-25" } mutableCopy];
    NSMutableDictionary *item3 = [@{ kTitleKey : NSLocalizedString(@"buy", @"buy"), kSubTitleKey : NSLocalizedString(@"ticketSubscriptions", @"ticketSubscriptions"), kImageKey : @"add_ticket", kUrlKey : @"http://www.amt.ct.it/?page_id=932" } mutableCopy];
    NSMutableDictionary *item4 = [@{ kTitleKey : @"App icon by", kSubTitleKey : @"icons8", kImageKey : @"bus-25", kUrlKey : @"http://icons8.com/license/" } mutableCopy];
    
    self.dataArray = @[item1, item3, item4];
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
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kInfoCell];
    NSDictionary *itemData = [self.dataArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [itemData valueForKey:kTitleKey];
    cell.detailTextLabel.text = [itemData valueForKey:kSubTitleKey];
    cell.imageView.image = [UIImage imageNamed:[itemData valueForKey:kImageKey]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat toReturn = 0.0;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        toReturn = SECTION_IPAD_HEADER_HEIGHT
    } else {
        toReturn = SECTION_HEADER_HEIGHT;
    }
    
    return toReturn;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat toReturn = 0.0;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        toReturn = SECTION_IPAD_FOOTER_HEIGHT
    } else {
        toReturn = SECTION_FOOTER_HEIGHT;
    }
    
    return toReturn;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
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

- (UIView *)tableView:(UITableView *)tv viewForFooterInSection:(NSInteger)section
{
    CGRect footerFrame = [tv rectForFooterInSection:0];
    CGRect labelFrame = CGRectMake(20, 0, footerFrame.size.width - 40, footerFrame.size.height);
    
    UIView *footer = [[UIView alloc] initWithFrame:footerFrame];
    
    UILabel *footerLabel = [[UILabel alloc] initWithFrame:labelFrame];
    
    footerLabel.text = [NSString stringWithFormat:@"Fabiano Roberto \n%@ %@", NSLocalizedString(@"version", "version label"), [self getAppVersionFromBuild:NO]];
    
    footerLabel.backgroundColor = [UIColor clearColor];
    footerLabel.font = [UIFont systemFontOfSize:14];
    footerLabel.textColor = UIColorFromRGB(0x1d5b91);
    
    footerLabel.lineBreakMode = NSLineBreakByCharWrapping;
    footerLabel.textAlignment = NSTextAlignmentLeft;
    footerLabel.numberOfLines = 0;
    
    [footer addSubview:footerLabel];
    
    return footer;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    BOOL toReturn = YES;
    
    switch (indexPath.row) {
        case 0:
            toReturn = YES;
            break;
        case 1:
        case 2:
        case 3:{
            NSDictionary *itemData = [self.dataArray objectAtIndex:indexPath.row];
            
            [self openURLInSafari:[itemData valueForKey:kUrlKey]];
            
            toReturn = NO;
            break;
        }
        case 4: {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            [self sendEmailToAddress:cell.detailTextLabel.text withSubject:[self getAppNameAndVersionFromBuild:YES]];
            
            toReturn = NO;
            break;
        }
        default:
            break;
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    return toReturn;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSDictionary *itemData = [self.dataArray objectAtIndex:indexPath.row];
    
    MyWebSite *webSite = (MyWebSite *) [segue destinationViewController];
    
    [webSite setWebPage:[itemData valueForKey:kUrlKey]];
    [webSite setTitle:[itemData valueForKey:kSubTitleKey]];
}

- (void) openURLInSafari: (NSString *) webSite {
    NSURL *url = [NSURL URLWithString: webSite];
    
    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"Failed to open url: %@", [url description]);
    }
}

- (NSString *) getAppVersionFromBuild: (BOOL) showBuild {
    NSString *key = @"CFBundleShortVersionString";
    
    if (showBuild) {
        key = @"CFBundleVersion";
    }
    
    return [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:key]];
}

- (NSString *) getAppNameAndVersionFromBuild: (BOOL) showBuild {
    return [NSString stringWithFormat:@"%@ - %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"], [self getAppVersionFromBuild:showBuild]];
}

#pragma mark Mail

- (void) sendEmailToAddress: (NSString *) address withSubject: (NSString *) subject {
    MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
    mail.mailComposeDelegate = self;
    
    if([MFMailComposeViewController canSendMail]){
        NSString *platform = [UIDeviceHardware platform];
        NSString *iOSVersion = [[UIDevice currentDevice] systemVersion];
        
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
        
        NSString *supportText = [NSString stringWithFormat:@"<html><body><table><tr><td><b>%@</b></td></tr><tr><td><i>Version: %@</i></td></tr><tr><td><i>Device: %@</i></td></tr><tr><td><i>iOS Version: %@</i></td></tr><tr><td>&nbsp;</td></tr><tr><td>%@</td></tr>", appName, [self getAppVersionFromBuild:NO], platform, iOSVersion, NSLocalizedString(@"writeHere...", "writeHere")];
        
        [mail setToRecipients:[NSArray arrayWithObjects:address, nil]];
        [mail setSubject:subject];
        [mail setMessageBody:supportText isHTML:YES];
        [mail.navigationBar setTintColor:UIColorFromRGB(0x1d5b91)];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    if (result == MFMailComposeResultFailed){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"messageNotSent!", "Message not sent!") message:NSLocalizedString(@"errorSentEmail", "Error sent Email") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", "Cancel") otherButtonTitles:nil];
        [alert show];
    }
}

- (NSString *) getAllFilesPathInDocumentRoot {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *filePathsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentsDirectory  error:nil];
    
    return [filePathsArray componentsJoinedByString:@"<br>"];
}

@end
