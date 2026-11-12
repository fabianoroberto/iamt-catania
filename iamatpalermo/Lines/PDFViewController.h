//
//  PDFViewController.h
//  iamtcatania
//
//  Created by Dr Thief on 03/10/13.
//  Copyright (c) 2013 Dr Thief. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDFViewController : UIViewController <UIWebViewDelegate> {
    NSString *lineId;
}

- (void) setNumberOfLine:(NSString *)numberOfLine;

@property (weak, nonatomic) IBOutlet UIWebView *myWebView;
@end
