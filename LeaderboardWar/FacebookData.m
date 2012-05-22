//
//  FacebookData.m
//  FFLT
//
//  Created by He jia bin on 5/7/12.
//  Copyright (c) 2012 Coconut Island Studio. All rights reserved.
//

#import "FacebookData.h"

// userInfo struct
@implementation UserInfo

@synthesize _uid;
@synthesize _name;
@synthesize _pic;
@synthesize _imageHost;


/**
 * Called when a request returns a response.
 *
 * The result object is the raw response from the server of type NSData
 */
- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data
{
    _pic = [[UIImage alloc] initWithData:data];
    
    if( _imageHost != nil )
    {
        [_imageHost setImage:_pic];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"icon_load_complete" object:nil];
    }
}


@end


// callbackInfo struct
@implementation CallbackInfo

@synthesize _callbackSender;
@synthesize _callback;

@end
