//
//  FacebookManager.h
//  FFLT
//
//  Created by He jia bin on 5/2/12.
//  Copyright (c) 2012 Coconut Island Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"
#import "FacebookData.h"

#define FACEBOOK_APP_KEY @"306795302732820"


// Facebook Manager
@interface FacebookManager : NSObject <FBSessionDelegate, FBRequestDelegate, FBDialogDelegate>
{
    Facebook* m_facebook;
    
    NSMutableDictionary* m_callbacks;
    
    UserInfo* m_userInfo;
    NSMutableArray* m_friendList;
}

@property (nonatomic, readonly) BOOL IsAuthenticated;

@property (nonatomic, retain) Facebook* Facebook;

@property (nonatomic, readonly) UserInfo* _userInfo;
@property (nonatomic, readonly) NSArray* _friendList;


+ (FacebookManager*)sharedInstance;

- (void)Authenticate:(id)caller withCallback:(SEL)callback;

- (void)Logout;

- (BOOL)GetProfile:(id)caller withCallback:(SEL)callback;

- (void)LoadPicture:(UserInfo*)userInfo;

- (BOOL)GetFriendList:(id)caller withCallback:(SEL)callback;

- (void)PublishToWall:(NSString*)info;

@end
