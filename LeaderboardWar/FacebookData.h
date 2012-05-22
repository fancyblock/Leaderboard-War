//
//  FacebookData.h
//  FFLT
//
//  Created by He jia bin on 5/7/12.
//  Copyright (c) 2012 Coconut Island Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"


// user info struct
@interface UserInfo : NSObject <FBRequestDelegate>

@property (nonatomic, retain) NSString* _uid;
@property (nonatomic, retain) NSString* _name;
@property (nonatomic, retain) UIImage* _pic;
@property (nonatomic, retain) UIImageView* _imageHost;

@end


// callback info
@interface CallbackInfo : NSObject

@property (nonatomic, retain) id _callbackSender;
@property (nonatomic) SEL _callback;

@end
