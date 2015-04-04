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

- (void) configureOriginOfPdfURL{
    NSLog(@"En configureOriginOfPdfURL la url del pdf es: %@",[self.model.pdfURL absoluteString]);
    
    if ([self isPdfURLRemote]) {
        [self activateViewIndicator];
        [self loadPDFFromRemote];
    }
    else{
        [self activateViewIndicator];
        [self loadPDFFromSandbox];
    }
}

// Check if the pdf url of the model is local or remote
- (BOOL) isPdfURLRemote{
    if ([[self.model.pdfURL absoluteString] hasPrefix:@"http"] || [[self.model.pdfURL absoluteString] hasPrefix:@"https"]) {
        NSLog(@"PDF remote");
        return YES;
    }
    else{
        NSLog(@"PDF local");
        return NO;
    }
}

- (void) activateViewIndicator{
    self.activityView.hidden = NO;
    [self.activityView startAnimating];
}

- (void) deactivateViewIndicator{
    self.activityView.hidden = YES;
    [self.activityView stopAnimating];
}

- (void) displayPDF{
    NSLog(@"Showing pdf with url: %@", [self.model.pdfURL absoluteString]);
    [self deactivateViewIndicator];
    [self.browser loadData:self.pdfData MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:nil];
}


#pragma mark - Sandbox

- (void) savePDFInSandbox: (NSData *) pdfData withFilename: (NSString *) filename{
    // Save image in /Documents/PDFs
    NSURL *url = [DTCSandboxURL URLToDocumentsCustomFolder:@"PDFs" forFilename:filename];
    NSError *error;
    BOOL ec = NO;
    
    // Save image in local directory
    ec = [pdfData writeToURL:url
                       options:kNilOptions
                         error:&error];
    
    // Error when saving image
    if (ec==NO) {
        NSLog(@"Error %@. Couldn't save pdf at %@", error.localizedDescription,[url absoluteString]);
    }
    else{
        // Initialize every book with its local image path
        
        NSLog(@"PDF successfully downloaded to %@", [url absoluteString]);
    }
}

- (void) loadPDFFromSandbox{
    NSLog(@"Entro en loadPDFFromSandbox");
    NSError *error;
    NSURL *localURL = [DTCSandboxURL URLToDocumentsCustomFolder:@"PDFs" forFilename:[DTCSandboxURL filenameFromURL:self.model.pdfURL]];
    
    self.pdfData = [NSData dataWithContentsOfURL:localURL options:kNilOptions error:&error];
    if (!self.pdfData) {
        // Error
        NSLog(@"Error while loading PDF from Sandbox: %@",error.localizedDescription);
    }
    else{
        NSLog(@"Load pdf from Sandbox");
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
        //return YES;
    }
    else{
        // Errors when connecting
        NSLog(@"Error in viewDidLoad. Couldn't connect to server");
        //return NO;
    }
}


#pragma mark - UIWebViewDelegate
- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self deactivateViewIndicator];
    NSLog(@"Error when loading url: %@", error.localizedDescription);
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
    
    NSLog(@"URLConnection finished loading...");
    
    // Once data is received, create pdf with it and ask the browser to display it
    self.pdfData = [NSData dataWithData:self.receivedData];
    NSString *cleanPathname = [self trimSpacesFromString:[self.model.pdfURL absoluteString]];
    NSString *newFilename = [DTCSandboxURL filenameFromURL:[NSURL URLWithString:cleanPathname]];
    
    // Update PDF url in model and JSON
    self.model.pdfURL = [NSURL URLWithString:newFilename];

    //NSLog(@"After downloading, notify that pdf url has changed. New: %@", [self.model.pdfURL absoluteString]);
    
    // Save pdf in Sandbox
    [self savePDFInSandbox:self.pdfData withFilename:newFilename];
    
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
    NSLog(@"notify the PDFViewer that the library selected a book with pdf: %@",[book.pdfURL absoluteString]);
    self.model = book;
    
    [self configureOriginOfPdfURL];
}



#pragma mark - Utils
- (NSString *) trimSpacesFromString: (NSString *) aString{
    NSString *auxString = [aString stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    return auxString;
}
@end
