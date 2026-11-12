//
//  PDFViewController.m
//  iamtcatania
//
//  Created by Dr Thief on 03/10/13.
//  Copyright (c) 2013 Dr Thief. All rights reserved.
//

#import "PDFViewController.h"
#import "Constant.h"

@interface PDFViewController ()

@end

@implementation PDFViewController

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
    
	NSString *link = [NSString stringWithFormat:PDF_URL, lineId];
	[self.myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setNumberOfLine:(NSString *)numberOfLine {
    numberOfLine = [numberOfLine stringByReplacingOccurrencesOfString:[@" (Andata)" uppercaseString] withString:@""];
	numberOfLine = [numberOfLine stringByReplacingOccurrencesOfString:[@" (Ritorno)" uppercaseString] withString:@""];
	numberOfLine = [numberOfLine stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    lineId = numberOfLine;
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	// starting the load, show the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	// finished loading, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	// load error, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "error label") message:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"anErrorWasOccurred", "anErrorWasOccurred label"), [error localizedDescription]] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	
	[alert show];
}

@end
