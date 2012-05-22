//
//  BoardCellView.m
//  LeaderboardWar
//
//  Created by He jia bin on 5/11/12.
//  Copyright (c) 2012 FancyBlockGames. All rights reserved.
//

#import "BoardCellView.h"

@implementation BoardCellView

@synthesize iconProfile;
@synthesize txtSequence;
@synthesize txtName;
@synthesize txtMark;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
