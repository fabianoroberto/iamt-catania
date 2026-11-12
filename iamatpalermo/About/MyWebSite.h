//
//  MyWebSite.h
//  Turnario VVF
//
//  Created by Dr Thief on 08/01/14.
//  Copyright (c) 2013 Dr Thief. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyWebSite : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) NSString *webPage;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end