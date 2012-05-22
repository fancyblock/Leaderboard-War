//
//  FacebookManager.m
//  FFLT
//
//  Created by He jia bin on 5/2/12.
//  Copyright (c) 2012 Coconut Island Studio. All rights reserved.
//

#import "FacebookManager.h"


@interface FacebookManager(private)

- (void)addCallback:(id)sender withCallback:(SEL)callback forKey:(NSString*)key;
- (void)removeCallback:(NSString*)key;

@end


@implementation FacebookManager

static NSString* REQUEST_TYPE_USERINFO = @"user_info";
static NSString* REQUEST_TYPE_FRIENDLIST = @"friend_list";
static NSString* REQUEST_TYPE_PICTURE = @"user_picture";

static FacebookManager* m_singleton = nil;


@synthesize Facebook = m_facebook;
@synthesize _userInfo = m_userInfo;
@synthesize _friendList = m_friendList;



/**
 * @desc    return the singleton of FacebookManager
 * @para    none
 * @return  FacebookManager
 */
+ (FacebookManager*)sharedInstance
{
    if( m_singleton == nil )
    {
        m_singleton = [[FacebookManager alloc] init];
    }
    
    return m_singleton;
}


/**
 * @desc    init
 * @para    none
 * @return  instance
 */
- (id)init
{
    self = [super init];
    
    m_facebook = [[Facebook alloc] initWithAppId:FACEBOOK_APP_KEY andDelegate:self];
    
    // Check and retrieve authorization information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ( [defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"] ) 
    {
        m_facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        m_facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    m_callbacks = [[NSMutableDictionary alloc] init];
    
    return self;
}


/**
 * @desc    judge if already login the facebook
 * @para    none
 * @return  BOOL
 */
- (BOOL)IsAuthenticated
{
    BOOL isValid = [m_facebook isSessionValid];
    
    return isValid;
}


/**
 * @desc    authenticate the facebook account
 * @para    caller
 * @para    callback
 * @return  none
 */
- (void)Authenticate:(id)caller withCallback:(SEL)callback
{
    // clean the old data 
    [self removeCallback:@"auth"];
    
    // authenticating
    if( self.IsAuthenticated == NO )
    {
        // save the callback for invoke 
        CallbackInfo* callbackInfo = [[CallbackInfo alloc] init];
        callbackInfo._callbackSender = caller;
        callbackInfo._callback = callback;
        
        [m_callbacks setValue:callbackInfo forKey:@"auth"];
        
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"publish_stream",
                                nil];
        
        [m_facebook authorize:nil];
        
        [permissions release];
    }
}


/**
 * @desc    discard the current tokeyKey
 * @para    none
 * @return  none
 */
- (void)Logout
{
    [m_facebook logout];
}


/**
 * @desc    get the user info
 * @para    none
 * @return  none
 */
- (BOOL)GetProfile:(id)caller withCallback:(SEL)callback
{
    if( self.IsAuthenticated == NO )
    {
        return NO;
    }
    
    // set the callback
    [self addCallback:caller withCallback:callback forKey:REQUEST_TYPE_USERINFO];
    
    // request for user info 
    NSMutableDictionary* paraDic = [[NSMutableDictionary alloc] init];
    [paraDic setValue:REQUEST_TYPE_USERINFO forKey:@"Type"];
    
    [m_facebook requestWithGraphPath:@"me" andParams:paraDic andDelegate:self];
    
    return YES;
}


/**
 * @desc    load the user picture
 * @para    userInfo
 * @return  none
 */
- (void)LoadPicture:(UserInfo*)userInfo;
{
    NSString* graphPath = [NSString stringWithFormat:@"%@/picture", userInfo._uid];
    
    [m_facebook requestWithGraphPath:graphPath andDelegate:userInfo];
}


/**
 * @desc    load friend list
 * @para    caller
 * @para    callback
 * @return  none
 */
- (BOOL)GetFriendList:(id)caller withCallback:(SEL)callback
{
    if( self.IsAuthenticated == NO )
    {
        return NO;
    }
    
    // set the callback
    [self addCallback:caller withCallback:callback forKey:REQUEST_TYPE_FRIENDLIST];
    
    // request for friend list
    NSMutableDictionary* paraDic = [[NSMutableDictionary alloc] init];
    [paraDic setValue:REQUEST_TYPE_FRIENDLIST forKey:@"Type"];
    
    [m_facebook requestWithGraphPath:@"me/friends" andParams:paraDic andDelegate:self];
    
    return YES;
}


/**
 * @desc    post something to the wall
 * @para    info
 * @return  none
 */
- (void)PublishToWall:(NSString*)info
{
    NSMutableDictionary* paras = [[NSMutableDictionary alloc] init];
    
    //message, picture, link, name, caption, description, source, place, tags
    
    [paras setObject:info forKey:@"message"];
    [paras setObject:@"ttt" forKey:@"name"];
    //TODO 
    
    [m_facebook dialog:@"feed" andParams:paras andDelegate:nil];
}


//------------------------------ private function --------------------------------- 


/**
 * @desc    add a callback to the dict
 * @para    sender
 * @para    callback
 * @para    key
 * @return  none
 */
- (void)addCallback:(id)sender withCallback:(SEL)callback forKey:(NSString*)key
{
    CallbackInfo* callbackInfo = [[CallbackInfo alloc] init];
    callbackInfo._callbackSender = sender;
    callbackInfo._callback = callback;
    
    [m_callbacks setObject:callbackInfo forKey:key];
}


/**
 * @desc    remove the callback
 * @para    key
 * @return  none
 */
- (void)removeCallback:(NSString*)key
{
    CallbackInfo* oldCallbackInfo = [m_callbacks valueForKey:key];
    
    if( oldCallbackInfo != nil )
    {
        [m_callbacks removeObjectForKey:key];
        [oldCallbackInfo release];
    }
}


//----------------------------- callback function --------------------------------- 


/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin
{
    NSLog( @"Login Facebook success" );
    
    // save the tokeyKey
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[m_facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[m_facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    // invoke the callback
    CallbackInfo* callbackInfo = [m_callbacks objectForKey:@"auth"];
    if( callbackInfo != nil )
    {
        [callbackInfo._callbackSender performSelector:callbackInfo._callback];
    }
    
}


/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled
{
    //TODO 
}


/**
 * Called after the access token was extended. If your application has any
 * references to the previous access token (for example, if your application
 * stores the previous access token in persistent storage), your application
 * should overwrite the old access token with the new one in this method.
 * See extendAccessToken for more details.
 */
- (void)fbDidExtendToken:(NSString*)accessToken expiresAt:(NSDate*)expiresAt
{
    //TODO 
}


/**
 * Called when the user logged out.
 */
- (void)fbDidLogout
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}


/**
 * Called when the current session has expired. This might happen when:
 *  - the access token expired
 *  - the app has been disabled
 *  - the user revoked the app's permissions
 *  - the user changed his or her password
 */
- (void)fbSessionInvalidated
{
    NSLog( @"Session Invalidated" );
}


/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    //TODO 
}


/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array or a string, depending
 * on the format of the API response. If you need access to the raw response,
 * use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result
{
    NSString* requestType = [request.params objectForKey:@"Type"];
    
    if( [requestType isEqualToString:REQUEST_TYPE_USERINFO] )
    {
        if( m_userInfo == nil )
        {
            m_userInfo = [[UserInfo alloc] init];
        }
        
        m_userInfo._uid = [result objectForKey:@"id"];
        m_userInfo._name = [result objectForKey:@"name"];
    }
    
    if( [requestType isEqualToString:REQUEST_TYPE_FRIENDLIST] )
    {
        if( m_friendList == nil )
        {
            m_friendList = [[NSMutableArray alloc] init];
        }
        
        NSArray* friendData = [result objectForKey:@"data"];
        
        UserInfo* info = nil;
        
        int count = [friendData count];
        for( int i = 0 ; i < count; i++ )
        {
            info = [[UserInfo alloc] init];
            info._uid = [[friendData objectAtIndex:i] objectForKey:@"id"];
            info._name = [[friendData objectAtIndex:i] objectForKey:@"name"];
            
            [m_friendList addObject:info];
        }
    }
    
    // invoke the callback
    CallbackInfo* callbackInfo = [m_callbacks valueForKey:requestType];
    
    if( callbackInfo != nil )
    {
        if( callbackInfo._callback != nil && callbackInfo._callbackSender != nil )
        {
            [callbackInfo._callbackSender performSelector:callbackInfo._callback];
        }
        
        [self removeCallback:requestType];
    }
    
    [requestType release];
    
}


/**
 * Called when a request returns a response.
 *
 * The result object is the raw response from the server of type NSData
 */
- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data
{
    //TODO 
}


@end
