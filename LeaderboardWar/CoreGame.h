//
//  CoreGame.h
//  LeaderboardWar
//
//  Created by He jia bin on 5/11/12.
//  Copyright (c) 2012 FancyBlockGames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookManager.h"

#define INITIAL_SCORE   10.0f
#define POINT_TIME  60
#define TABLE_NAME  @"LeaderboardWar"

#define SCORE_ADDSELF   -1.0f
#define SCORE_ATTACK    1.5f
#define SCORE_HELP      -0.5f

#define POINT_INIT_VAL  3


// leaderboard item
@interface LeaderboardItem : NSObject

@property (nonatomic, retain) NSString* _name;
@property (nonatomic, retain) NSString* _uid;
@property (nonatomic, readwrite) float _score;
@property (nonatomic, retain) UserInfo* _fbUser;

@end


@interface CoreGame : NSObject
{
    NSMutableArray* m_friendlist;
    
    int m_point;
    int m_count;
    
    id m_tickSender;
    SEL m_tickCallback;
    
    NSTimer* m_timer;
}

@property (nonatomic, readonly) int POINT;
@property (nonatomic, readonly) float PROGRESS;


- (void)InitialScore:(id)sender withCallback:(SEL)callback;

- (void)RequestScores:(id)sender withCallback:(SEL)callback;

- (void)RegisitTick:(id)sender withCallback:(SEL)callback;

- (NSMutableArray*)GetFriendsList;

- (void)SortLocalList;

- (BOOL)Attack:(int)index withSender:(id)sender andCallback:(SEL)callback;

- (BOOL)AddSelf:(int)index withSender:(id)sender andCallback:(SEL)callback;

- (BOOL)Help:(int)index withSender:(id)sender andCallback:(SEL)callback;

- (void)Close;

@end
