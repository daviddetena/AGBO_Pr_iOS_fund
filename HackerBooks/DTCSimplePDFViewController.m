//
//  DTCSimplePDFViewController.m
//  HackerBooks
//
//  Created by David de Tena on 27/03/15.
//  Copyright (c) 2015 David de Tena. All rights reserved.
//

#import "DTCSimplePDFViewController.h"
#import "DTCBook.h"

@interface DTCSimplePDFViewController ()

@end

@implementation DTCSimplePDFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (id) initWithModel:(DTCBook *)aModel{
    if(self = [super initWithNibName:nil bundle:nil]){
        _model = aModel;
        self.title = aModel.title;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    // This class will be the delegate for the browser
    self.browser.delegate = self;
    [self displayPdfFromURL:self.model.pdfURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Utils
- (void) displayPdfFromURL:(NSURL *) aURL{
    // Activity indicator is visible and animating
    self.activityView.hidden = NO;
    [self.activityView startAnimating];
    
    // Load PDF
    NSError *error;
    NSData *pdfData = [NSData dataWithContentsOfURL:aURL
                                            options:kNilOptions
                                              error:&error];
    if(pdfData==nil){
        //Error
        NSLog(@"Error when loading pdf within the browser: %@",error.localizedDescription);
    }
    else{
        [self.browser loadData:pdfData MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:nil];
    }
}

#pragma mark - UIWebViewDelegate
- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    self.activityView.hidden = YES;
    NSLog(@"Error when loading url: %@", error.localizedDescription);
}

- (void) webViewDidFinishLoad:(UIWebView *)webView{
    // Activity indicator is hidden
    [self.activityView stopAnimating];
    self.activityView.hidden = YES;
}

- (BOOL) webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
  navigationType:(UIWebViewNavigationType)navigationType{

    // Disable links within the pdf
    if(navigationType == UIWebViewNavigationTypeLinkClicked){
        return NO;
    }
    return YES;
}

@end
