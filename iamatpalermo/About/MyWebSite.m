//
//  MyWebSite.m
//  Turnario VVF
//
//  Created by Dr Thief on 08/01/14.
//  Copyright (c) 2013 Dr Thief. All rights reserved.
//

#import "MyWebSite.h"

@implementation MyWebSite

@synthesize webPage, webView;

- (void) dealloc {
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [webView setDelegate:self];
    
    NSMutableURLRequest * request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:webPage]];
    [webView loadRequest:request];
}

- (void)viewDidUnload {
    
}

#pragma mark -
#pragma mark UIViewController delegate methods

- (void)viewWillAppear:(BOOL)animated
{
    webView.delegate = self;	// setup the delegate as the web view is shown
}

- (void)viewWillDisappear:(BOOL)animated
{
    [webView stopLoading];	// in case the web view is still loading its content
    webView.delegate = nil;	// disconnect the delegate as the webview is hidden
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // we support rotation in this view controller
    return YES;
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"Loading URL :%@",request.URL.absoluteString);
    
    //return FALSE; //to stop loading
    return YES;
}

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
    NSLog(@"Failed to load with error :%@", [error debugDescription]);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"anErrorHasOccurred", @"Error occurred") message:[error localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"back");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end