//
//  LeaderboardViewController.m
//  LeaderboardWar
//
//  Created by He JiaBin on 12-5-11.
//  Copyright (c) 2012年 FancyBlockGames. All rights reserved.
//

#import "LeaderboardViewController.h"
#import "BoardCellView.h"
#import "MBProgressHUD.h"


@interface LeaderboardViewController(private)

- (void)loadLeaderboard;
- (void)setModeButton:(UIBarButtonItem*)btn;
- (void)getMark;
- (void)_onUserProfileComplete;
- (void)_onFriendListComplete;
- (void)_onScoreComplete;
- (void)_onTick;
- (void)_onOperateComplete;
- (void)_onPicLoaded;

@end

@implementation LeaderboardViewController

@synthesize txtInfo;
@synthesize uiProgress;
@synthesize viewLeaderboard;
@synthesize btnAddSelf;
@synthesize btnAttack;
@synthesize btnHelp;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // initial core game
    m_coreGame = [[CoreGame alloc] init];
    
    // add the refresh view
    m_refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake( 0,
                                                                                -self.viewLeaderboard.bounds.size.height, 
                                                                                self.view.frame.size.width, 
                                                                                self.viewLeaderboard.bounds.size.height )];
    m_refreshView.delegate = self;
    [self.viewLeaderboard addSubview:m_refreshView];
    m_isRefreshing = NO;
    
    m_operateMode = eAddSelfMode;
    [self setModeButton:self.btnAddSelf];
    [self loadLeaderboard];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_onPicLoaded) name:@"icon_load_complete" object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [m_coreGame Close];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"icon_load_complete" object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//-------------------------------- private function --------------------------------------

// set the button status
- (void)setModeButton:(UIBarButtonItem*)btn
{
    [self.btnAttack setTintColor:[UIColor blackColor]];
    [self.btnAddSelf setTintColor:[UIColor blackColor]];
    [self.btnHelp setTintColor:[UIColor blackColor]];
    
    [btn setTintColor:[UIColor redColor]];
}

// load leaderboard
- (void)loadLeaderboard
{
    if( [FacebookManager sharedInstance]._userInfo == nil )
    {
        [[FacebookManager sharedInstance] GetProfile:self withCallback:@selector(_onUserProfileComplete)];
    }
    else 
    {
        [self getMark];
    }
}

// get the mark from the parse
- (void)getMark
{
    [m_coreGame RequestScores:self withCallback:@selector(_onScoreComplete)];
    
    [m_coreGame RegisitTick:self withCallback:@selector(_onTick)];
}

// tick callback
- (void)_onTick
{
    self.txtInfo.text = [NSString stringWithFormat:@"Point: %d", m_coreGame.POINT];
    [self.uiProgress setProgress:m_coreGame.PROGRESS];
}

//--------------------------------- event callback -------------------------------------- 

// callback when the scores received
- (void)_onScoreComplete
{
    m_leaderboard = [m_coreGame GetFriendsList];
    
    m_isRefreshing = NO;
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    [m_refreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self.viewLeaderboard];
    
    [viewLeaderboard setHidden:NO];
    [self.viewLeaderboard reloadData];
}

// callback when the user info received
- (void)_onUserProfileComplete
{
    [[FacebookManager sharedInstance] GetFriendList:self withCallback:@selector(_onFriendListComplete)];
}

// callback when the friendlist received
- (void)_onFriendListComplete
{
    [m_coreGame InitialScore:self withCallback:@selector(getMark)];
}

// callback after submit the operation
- (void)_onOperateComplete
{
    [m_coreGame SortLocalList];
    
    [self.viewLeaderboard setAllowsSelection:YES];
    [viewLeaderboard reloadData];
    [self.viewLeaderboard deselectRowAtIndexPath:m_curSelectCell animated:YES];
    [m_curSelectCell release];
}

// callback when pic loaded
- (void)_onPicLoaded
{
    [self.viewLeaderboard reloadData];
}


//------------------------------- controllor events ------------------------------------- 


- (IBAction)Attack:(id)sender
{
    m_operateMode = eAttackMode;
    
    [self setModeButton:self.btnAttack];
}

- (IBAction)AddSelf:(id)sender
{
    m_operateMode = eAddSelfMode;
    
    [self setModeButton:self.btnAddSelf];
}

- (IBAction)Help:(id)sender
{
    m_operateMode = eHelpMode;
    
    [self setModeButton:self.btnHelp];
}

//------------------------------ delegate functions -------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( m_leaderboard == nil )
    {
        return 0;
    }
    
    return [m_leaderboard count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BoardCellView* cell = nil;
    
    NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"BoardCellView" owner:self options:nil];
    cell = (BoardCellView*)[nib objectAtIndex:0];
    
    NSInteger row = [indexPath row];
    LeaderboardItem* item = [m_leaderboard objectAtIndex:row];
    
    cell.txtSequence.text = [NSString stringWithFormat:@"%d", row + 1];
    cell.txtName.text = item._name;
    cell.txtMark.text = [NSString stringWithFormat:@"%.1f", item._score];
    
    //load image
    if( item._fbUser._pic == nil )
    {
        item._fbUser._imageHost = cell.imageView;
        [[FacebookManager sharedInstance] LoadPicture:item._fbUser];
    }
    else 
    {
        [cell.iconProfile setImage:item._fbUser._pic];
    }

    return cell;
}

// fixed font style. use custom view (UILabel) if you want something different
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if( m_leaderboard != nil )
    {
        UserInfo* me = [FacebookManager sharedInstance]._userInfo;
        
        int count = [m_leaderboard count];
        for( int i = 0; i < count; i++ )
        {
            LeaderboardItem* item = [m_leaderboard objectAtIndex:i];
            if( [me._uid isEqualToString:item._uid] )
            {
                int index = i + 1;
                
                return [NSString stringWithFormat:@"You are at %dth of leaderboard", index];
            }
        }
    }
    
    return @"You are at xxxth of leaderboard";
}

// callback when user select the row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // disable some ui for safity
    [self.viewLeaderboard setAllowsSelection:NO];
    
    NSInteger row = [indexPath row];
    BOOL result;
    
    if( m_operateMode == eAttackMode )
    {
        result = [m_coreGame Attack:row withSender:self andCallback:@selector(_onOperateComplete)];
    }
    if( m_operateMode == eAddSelfMode )
    {
        result = [m_coreGame AddSelf:row withSender:self andCallback:@selector(_onOperateComplete)];
    }
    if( m_operateMode == eHelpMode )
    {
        result = [m_coreGame Help:row withSender:self andCallback:@selector(_onOperateComplete)];
    }
    
    m_curSelectCell = [indexPath retain];

    if( result == NO )
    {
        [self _onOperateComplete];
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
	[m_refreshView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[m_refreshView egoRefreshScrollViewDidEndDragging:scrollView];
}


// begin to refresh
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    m_isRefreshing = YES;
    
    [self loadLeaderboard];
}


// if refresh done
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return m_isRefreshing;
}


@end
