//
//  itemDetailTableViewCell.h
//  simpleFinance
//
//  Created by Eric Cao on 4/23/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol showPadDelegate <NSObject>

-(void)showPad:(UIButton *)sender;

@end

@interface itemDetailTableViewCell : UITableViewCell
@property (nonatomic,strong) id <showPadDelegate> padDelegate;
@property (nonatomic,strong) UILabel *leftText;
@property (nonatomic,strong) UIButton *rightText;
-(void)addExpend;
-(void)redrawRightButton:(CGRect)rect;
-(void)removeExpend;

@end
