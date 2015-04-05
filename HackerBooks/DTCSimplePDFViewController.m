//
//  DTCSimplePDFViewController.m
//  HackerBooks
//
//  Created by David de Tena on 27/03/15.
//  Copyright (c) 2015 David de Tena. All rights reserved.
//

#import "DTCSimplePDFViewController.h"
#import "DTCBook.h"
#import "DTCLibraryTableViewController.h"
#import "DTCSandboxURL.h"

@interface DTCSimplePDFViewController ()

// Data being received from the server
@property (strong,nonatomic) NSMutableData *receivedData;
@property (strong,nonatomic) NSData *pdfData;

@end

@implementation DTCSimplePDFViewController

#pragma mark - Init

- (id) initWithModel:(DTCBook *)aModel{
    if(self = [super initWithNibName:nil bundle:nil]){
        _model = aModel;
        _pdfData = nil;
        self.title = aModel.title;
    }
    return self;
}

#pragma mark - View Lifecycle
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    // Suscribe for notifications
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(notifyThatPdfUrlDidChange:) name:NOTIF_NAME_BOOK_SELECTED_PDF_URL object:nil];
    
    // This class will be the delegate for the browser
    self.browser.delegate = self;
    [self activateViewIndicator];
    [self configureOriginOfPdfURL];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    // Unsuscribe from notification center
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self];
}


#pragma mark - Memory
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Utils

// Set pdf origin (local or remote)
- (void) configureOriginOfPdfURL{
    
    if ([self isPdfURLRemote]) {
        [self loadPDFFromRemote];
    }
    else{
        [self loadPDFFromSandbox];
    }
}

// Check if the pdf url of the model is local or remote
- (BOOL) isPdfURLRemote{
    if ([[self.model.pdfURL absoluteString] hasPrefix:@"http"] || [[self.model.pdfURL absoluteString] hasPrefix:@"https"]) {
        return YES;
    }
    else{
        return NO;
    }
}

// Shows activity indicator and starts animating
- (void) activateViewIndicator{
    self.activityView.hidden = NO;
    [self.activityView startAnimating];
}

// Hides activity indicator and stops animating
- (void) deactivateViewIndicator{
    self.activityView.hidden = YES;
    [self.activityView stopAnimating];
}

// Display pdf in browser
- (void) displayPDF{
    [self deactivateViewIndicator];
    [self.browser loadData:self.pdfData MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:nil];
}


#pragma mark - Sandbox

- (void) savePDFToSandbox: (NSData *) pdfData withFilename: (NSString *) filename{
    // Save image to /Documents/PDFs
    NSURL *url = [DTCSandboxURL URLToCacheCustomFolder:@"PDFs" forFilename:filename];
    NSError *error;
    BOOL ec = NO;
    
    // Save image to local directory
    ec = [pdfData writeToURL:url
                       options:kNilOptions
                         error:&error];
    
    // Error while saving pdf
    if (ec==NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                        message:@"Error while saving pdf to sandbox"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Done", nil];
        [alert show];
    }
}

- (void) loadPDFFromSandbox{
    NSError *error;
    NSURL *localURL = [DTCSandboxURL URLToCacheCustomFolder:@"PDFs" forFilename:[DTCSandboxURL filenameFromURL:self.model.pdfURL]];
    
    self.pdfData = [NSData dataWithContentsOfURL:localURL options:kNilOptions error:&error];
    if (!self.pdfData) {
        // Error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                        message:@"Error while loading PDF from disk"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Done", nil];
        [alert show];
    }
    else{
        // Display pdf from sandbox
        [self displayPDF];
    }
}


#pragma mark - Network
- (void) loadPDFFromRemote{
    // Request the pdf url to server, with a timeout of 10 segs and ignoring cache
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.model.pdfURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    
    // Create the connection and start loading data. The Controller is the connection delegate
    NSURLConnection *urlConnection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    if (urlConnection) {
        // If connection, alloc receivedData
        _receivedData = [[NSMutableData alloc]init];
    }
    else{
        // Error while connecting
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                        message:@"Error while connecting to server to download PDF"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Done", nil];
        [alert show];
    }
}


#pragma mark - UIWebViewDelegate
- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self deactivateViewIndicator];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                    message:@"Error while loading url in browser"
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Done", nil];
    [alert show];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView{
    [self deactivateViewIndicator];
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


#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    //NSLog(@"Error in didFailWithError: %@", error.localizedDescription);
    [self deactivateViewIndicator];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"%@",error.localizedDescription] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alertView show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{

    // Once data is received, create pdf with it and ask the browser to display it
    self.pdfData = [NSData dataWithData:self.receivedData];
    
    NSString *cleanPathname = [self trimSpacesFromString:[self.model.pdfURL absoluteString]];
    NSString *newFilename = [DTCSandboxURL filenameFromURL:[NSURL URLWithString:cleanPathname]];
    
    // Update PDF url in model and JSON
    self.model.pdfURL = [NSURL URLWithString:newFilename];

    // Save pdf in Sandbox
    [self savePDFToSandbox:self.pdfData withFilename:newFilename];
    
    // Display PDF
    [self displayPDF];
    
    //NOTIFY THE LIBRARY THAT THE PDF URL OF MODEL HAS CHANGED
    NSNotification *notification = [NSNotification notificationWithName:NOTIF_NAME_URL_PDF_CHANGE object:self userInfo:@{NOTIF_KEY_URL_PDF_CHANGE:self.model}];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}


#pragma mark - Notifications
- (void) notifyThatPdfUrlDidChange: (NSNotification *) n{    
    // Get the model from Notification
    NSDictionary *dict = [n userInfo];
    DTCBook *book = [dict objectForKey:NOTIF_KEY_BOOK];
    self.model = book;
    
    [self configureOriginOfPdfURL];
}


#pragma mark - Utils
- (NSString *) trimSpacesFromString: (NSString *) aString{
    NSString *auxString = [aString stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    return auxString;
}
@end
