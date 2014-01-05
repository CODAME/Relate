//
//  BCSecondViewController.m
//  beacon
//
//  Created by Zac Bowling on 1/4/14.
//  Copyright (c) 2014 Hackathon. All rights reserved.
//

#import "BCProfileViewController.h"
#import <Parse/Parse.h>
#import "BCWebViewController.h"

@interface BCProfileViewController()<PFLogInViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation BCProfileViewController

- (void)viewDidLoad
{       
    [super viewDidLoad];

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://relate.parseapp.com/profile.html"]];
    [self.webView loadRequest:request];

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    /*if (![PFUser currentUser]){
        PFLogInViewController *logInController = [[PFLogInViewController alloc] init];
        logInController.delegate = self;
        logInController.facebookPermissions = @[@"friends_about_me"];
        logInController.fields = PFLogInFieldsUsernameAndPassword
                                | PFLogInFieldsFacebook;

        [[self parentViewController] presentViewController:logInController animated:YES completion:nil];
    }*/

}

- (void)loadProfile
{
    
}

- (void)logInViewController:(PFLogInViewController *)controller
               didLogInUser:(PFUser *)user {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
