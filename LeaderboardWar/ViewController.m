//
//  ViewController.m
//  LeaderboardWar
//
//  Created by He JiaBin on 12-5-10.
//  Copyright (c) 2012年 FancyBlockGames. All rights reserved.
//

#import "ViewController.h"
#import "FacebookManager.h"

@interface ViewController(private) 

- (void)gotoLeaderboard;

@end


@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    m_viewLeaderboard = [[LeaderboardViewController alloc] initWithNibName:@"LeaderboardViewController" bundle:nil];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if( [FacebookManager sharedInstance].IsAuthenticated )
    {
        [self gotoLeaderboard];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return NO;//(interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


/**
 * @desc    login the facebook
 * @para    sender
 * @return  none
 */
- (IBAction)LoginFacebook:(id)sender
{
    [[FacebookManager sharedInstance] Authenticate:self withCallback:@selector(_onAuthComplete)];
}


//----------------------------- private function ------------------------------


// go to leaderboard view
- (void)gotoLeaderboard
{
    m_viewLeaderboard.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:m_viewLeaderboard animated:YES completion:NULL];
}

//---------------------------- callback function ------------------------------


// callback when auth success
- (void)_onAuthComplete
{
    NSLog( @"Auth success" );
    
    [self gotoLeaderboard];
}


@end
