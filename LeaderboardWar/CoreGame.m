//
//  CoreGame.m
//  LeaderboardWar
//
//  Created by He jia bin on 5/11/12.
//  Copyright (c) 2012 FancyBlockGames. All rights reserved.
//

#import "CoreGame.h"
#import "Parse/Parse.h"


// leaderboard item
@implementation LeaderboardItem

@synthesize _name;
@synthesize _uid;
@synthesize _score;
@synthesize _fbUser;

@end


@interface CoreGame(private)

- (void)cleanFriendlist;
- (void)startAccumlation;
- (void)timerFireMethod:(NSTimer*)theTimer;

@end


@implementation CoreGame

@synthesize POINT = m_point;


// return the PROGRESS property
- (float)PROGRESS
{
    return (float)m_count/60.0f;
}


/**
 * @desc    submit the first score
 * @para    sender
 * @para    callback
 * @return  none
 */
- (void)InitialScore:(id)sender withCallback:(SEL)callback
{
    PFQuery* query = [PFQuery queryWithClassName:TABLE_NAME];
    
    NSString* uid = [FacebookManager sharedInstance]._userInfo._uid;
    NSString* name = [FacebookManager sharedInstance]._userInfo._name;
    [query whereKey:@"uid" equalTo:uid];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError* error )
     {
         if( error == nil )
         {
             PFObject* scoreInfo = nil;
             
             if( [objects count] <= 0 )
             {
                 scoreInfo = [PFObject objectWithClassName:TABLE_NAME];
                 [scoreInfo setObject:uid forKey:@"uid"];
                 [scoreInfo setObject:name forKey:@"name"];
                 [scoreInfo setObject:[NSNumber numberWithFloat:INITIAL_SCORE] forKey:@"score"];
                 [scoreInfo save];
                 
                 m_point = POINT_INIT_VAL;
             }
             
             [sender performSelector:callback];
         }
     }];
    
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    m_point = [userDefault integerForKey:@"point"];
    
    [self startAccumlation];
}


/**
 * @desc    request all the score
 * @para    sender
 * @para    callback
 * @return  none
 */
- (void)RequestScores:(id)sender withCallback:(SEL)callback
{
    PFQuery* query = [PFQuery queryWithClassName:TABLE_NAME];
    
    if( m_friendlist != nil )
    {
        [self cleanFriendlist];
    }
    else 
    {
        m_friendlist = [[NSMutableArray alloc] init];
    }
    
    int i;
    int count = [[FacebookManager sharedInstance]._friendList count];
    UserInfo* userInfo;
    NSMutableArray* uids = [[NSMutableArray alloc] init];
    for( i = 0; i < count; i++ )
    {
        userInfo = [[FacebookManager sharedInstance]._friendList objectAtIndex:i];
        
        [uids addObject:userInfo._uid];
    }
    [uids addObject:[FacebookManager sharedInstance]._userInfo._uid];
    
    [query whereKey:@"uid" containedIn:uids];
    [query findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError* error)
     {
         if( error == nil )
         {
             int i;
             int j;
             int count;
             int countFbFriend = [[FacebookManager sharedInstance]._friendList count];
             LeaderboardItem* item = nil;
             
             count = [objects count];
             for( i = 0; i < count; i++ )
             {
                 item = [[LeaderboardItem alloc] init];
                 
                 item._name = [[objects objectAtIndex:i] objectForKey:@"name"];
                 item._uid = [[objects objectAtIndex:i] objectForKey:@"uid"];
                 item._score = [[[objects objectAtIndex:i] objectForKey:@"score"] floatValue];
                 
                 UserInfo* userInfo = nil;
                 for( j = 0; j < countFbFriend; j++ )
                 {
                     userInfo = [[FacebookManager sharedInstance]._friendList objectAtIndex:j];
                     
                     if( [userInfo._uid isEqualToString:item._uid] )
                     {
                         item._fbUser = userInfo;
                         
                         break;
                     }
                 }
                 if( item._fbUser == nil )
                 {
                     item._fbUser = [FacebookManager sharedInstance]._userInfo;
                 }
                 
                 [m_friendlist addObject:item];
             }
             
             // sort the leaderboard
             [self SortLocalList];
             
             [sender performSelector:callback];

         }
     }];
    
}


/**
 * @desc    return the friendlist
 * @para    none
 * @return  friendlist
 */
- (NSMutableArray*)GetFriendsList
{
    return m_friendlist;
}


/**
 * @desc    rigisit the tick
 * @para    sender
 * @para    callback
 * @return  none
 */
- (void)RegisitTick:(id)sender withCallback:(SEL)callback
{
    m_tickSender = sender;
    m_tickCallback = callback;
}


/**
 * @desc    attack someone
 * @para    index
 * @return  none
 */
- (BOOL)Attack:(int)index withSender:(id)sender andCallback:(SEL)callback
{
    if( m_point <= 0 )
    {
        return NO;
    }
    
    LeaderboardItem* item = [m_friendlist objectAtIndex:index];
    UserInfo* userInfo = [FacebookManager sharedInstance]._userInfo;
    
    if( [userInfo._uid isEqualToString:item._uid] )
    {
        return NO;
    }
    
    if( item._score <= 0.0f && SCORE_ATTACK < 0 )
    {
        return NO;
    }
    
    item._score += SCORE_ATTACK;
    
    PFQuery* query = [PFQuery queryWithClassName:TABLE_NAME];
    [query whereKey:@"uid" equalTo:item._uid];
    [query findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError* error)
     {
         if( error == nil )
         {
             PFObject* info = [objects objectAtIndex:0];
             float score = [[info objectForKey:@"score"] floatValue];
             score += SCORE_ATTACK;
             
             if( score < 0.0f )
             {
                 score = 0.0f;
             }
             
             [info setObject:[NSNumber numberWithFloat:score]  forKey:@"score"];
             [info save];
             
             m_point--;
             
             [sender performSelector:callback];
         }
     }];
    
    return YES;
}


/**
 * @desc    add self
 * @para    index
 * @return  none
 */
- (BOOL)AddSelf:(int)index withSender:(id)sender andCallback:(SEL)callback
{
    if( m_point <= 0 )
    {
        return NO;
    }
    
    LeaderboardItem* item = [m_friendlist objectAtIndex:index];
    UserInfo* userInfo = [FacebookManager sharedInstance]._userInfo;
    
    if( [userInfo._uid isEqualToString:item._uid] == NO )
    {
        return NO;
    }
    
    if( item._score <= 0.0f && SCORE_ADDSELF < 0 )
    {
        return NO;
    }
    
    item._score += SCORE_ADDSELF;
    
    PFQuery* query = [PFQuery queryWithClassName:TABLE_NAME];
    [query whereKey:@"uid" equalTo:item._uid];
    [query findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError* error)
     {
         if( error == nil )
         {
             PFObject* info = [objects objectAtIndex:0];
             float score = [[info objectForKey:@"score"] floatValue];
             score += SCORE_ADDSELF;
             
             if( score < 0.0f )
             {
                 score = 0.0f;
             }
             
             [info setObject:[NSNumber numberWithFloat:score]  forKey:@"score"];
             [info save];
             
             m_point--;
             
             [sender performSelector:callback];
         }
     }];
    
    return YES;
}


/**
 * @desc    help someone
 * @para    index
 * @return  none
 */
- (BOOL)Help:(int)index withSender:(id)sender andCallback:(SEL)callback
{
    if( m_point <= 0 )
    {
        return NO;
    }
    
    LeaderboardItem* item = [m_friendlist objectAtIndex:index];
    UserInfo* userInfo = [FacebookManager sharedInstance]._userInfo;
    
    if( [userInfo._uid isEqualToString:item._uid] )
    {
        return NO;
    }
    
    if( item._score <= 0.0f && SCORE_HELP < 0 )
    {
        return NO;
    }
    
    item._score += SCORE_HELP;
    
    PFQuery* query = [PFQuery queryWithClassName:TABLE_NAME];
    [query whereKey:@"uid" equalTo:item._uid];
    [query findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError* error)
     {
         if( error == nil )
         {
             PFObject* info = [objects objectAtIndex:0];
             float score = [[info objectForKey:@"score"] floatValue];
             score += SCORE_HELP;
             
             if( score < 0.0f )
             {
                 score = 0.0f;
             }
             
             [info setObject:[NSNumber numberWithFloat:score]  forKey:@"score"];
             [info save];
             
             m_point--;
             
             [sender performSelector:callback];
         }
     }];
    
    return YES;
}


/**
 * @desc    sort local list
 * @para    none
 * @return  none
 */
- (void)SortLocalList
{
    // sort the leaderboard
    [m_friendlist sortUsingComparator:^NSComparisonResult( id obj1, id obj2 )
     {
         LeaderboardItem* item1 = obj1;
         LeaderboardItem* item2 = obj2;
         
         if( item1._score < item2._score )
         {
             return NSOrderedAscending;
         }
         
         if( item1._score > item2._score )
         {
             return NSOrderedDescending;
         }
         
         return NSOrderedSame;
     }];
}


/**
 * @desc    close the game and save the info
 * @para    none
 * @return  none
 */
- (void)Close
{
    if( m_timer != nil )
    {
        [m_timer invalidate];
    }
    
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setInteger:m_point forKey:@"point"];
    [userDefault synchronize];
}


//------------------------ private function -------------------------


// clean the friendlist and release memory
- (void)cleanFriendlist
{
    int count = [m_friendlist count];
    
    for( int i = 0; i < count; i++ )
    {
        LeaderboardItem* item = [m_friendlist objectAtIndex:i];
        
        [item release];
    }
    
    [m_friendlist removeAllObjects];
}

// start the accumulate the point
- (void)startAccumlation
{
    m_count = 0;
    
    m_timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
}
     

//----------------------- callback function -------------------------- 

//timer
- (void)timerFireMethod:(NSTimer*)theTimer
{
    m_count++;
    
    if( m_count == POINT_TIME )
    {
        m_point++;
        
        m_count = 0;
    }
    
    if( m_tickCallback != nil && m_tickSender != nil )
    {
        [m_tickSender performSelector:m_tickCallback];
    }
}

@end
