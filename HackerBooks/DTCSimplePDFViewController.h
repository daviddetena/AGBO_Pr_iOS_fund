//
//  DTCSimplePDFViewController.h
//  HackerBooks
//
//  Created by David de Tena on 27/03/15.
//  Copyright (c) 2015 David de Tena. All rights reserved.
//

#import <UIKit/UIKit.h>

// Forward declaration
@class DTCBook;

@interface DTCSimplePDFViewController : UIViewController<UIWebViewDelegate, NSURLConnectionDelegate>

#pragma mark - Properties
@property (weak,nonatomic) IBOutlet UIWebView *browser;
@property (weak,nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (strong,nonatomic) DTCBook *model;
@property (strong,nonatomic) NSURLConnection *urlConnection;

#pragma mark - Init
- (id) initWithModel:(DTCBook *) aModel;

@end
