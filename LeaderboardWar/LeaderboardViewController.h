//
//  LeaderboardViewController.h
//  LeaderboardWar
//
//  Created by He JiaBin on 12-5-11.
//  Copyright (c) 2012年 FancyBlockGames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookManager.h"
#import "CoreGame.h"


// operation mode
enum OperationMode 
{
    eAttackMode = 0,
    eAddSelfMode = 1,
    eHelpMode = 2
};

@interface LeaderboardViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    int m_operateMode;
    NSMutableArray* m_leaderboard;
    
    CoreGame* m_coreGame;
    NSIndexPath* m_curSelectCell;
}

@property (nonatomic, retain) IBOutlet UITableView* viewLeaderboard;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* uiLoading;
@property (nonatomic, retain) IBOutlet UIProgressView* uiProgress;
@property (nonatomic, retain) IBOutlet UILabel* txtInfo;

@property (nonatomic, retain) IBOutlet UIBarButtonItem* btnRefresh;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* btnAttack;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* btnAddSelf;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* btnHelp;



- (IBAction)RefreshLeaderboard:(id)sender;

- (IBAction)Attack:(id)sender;

- (IBAction)AddSelf:(id)sender;

- (IBAction)Help:(id)sender;


@end
