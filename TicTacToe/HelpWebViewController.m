//
//  HelpWebViewController.m
//  TicTacToe
//
//  Created by Taylor Wright-Sanson on 10/3/14.
//  Copyright (c) 2014 Taylor Wright-Sanson. All rights reserved.
//

#import "HelpWebViewController.h"

@interface HelpWebViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@end

@implementation HelpWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURL *url = [NSURL URLWithString:@"http://en.wikipedia.org/wiki/Tic-tac-toe"];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:urlRequest];
    self.navBar.tintColor = [UIColor whiteColor];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (IBAction)onPressCloseButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
