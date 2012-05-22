//
//  BoardCellView.h
//  LeaderboardWar
//
//  Created by He jia bin on 5/11/12.
//  Copyright (c) 2012 FancyBlockGames. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BoardCellView : UITableViewCell
{
    //TODO 
}

@property (nonatomic, retain) IBOutlet UIImageView* iconProfile;
@property (nonatomic, retain) IBOutlet UILabel* txtSequence;
@property (nonatomic, retain) IBOutlet UILabel* txtName;
@property (nonatomic, retain) IBOutlet UILabel* txtMark;

@end
