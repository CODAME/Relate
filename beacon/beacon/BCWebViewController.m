//
//  BCWebViewController.m
//  beacon
//
//  Created by Zac Bowling on 1/5/14.
//  Copyright (c) 2014 Hackathon. All rights reserved.
//

#import "BCWebViewController.h"

@interface BCWebViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation BCWebViewController

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
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.initialPage];
    [self.webView loadRequest:request];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
