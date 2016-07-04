//
//  goalTableViewCell.h
//  DaysInLine
//
//  Created by Eric Cao on 6/3/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNChart.h"

@protocol showTimerDelegate <NSObject>

-(void)timerMove:(UIButton *)sender;
-(void)archiveGoal:(UIButton *)sender;
-(void)KeepingGoal:(UIButton *)sender;


@end

@interface goalTableViewCell : UITableViewCell
@property(nonatomic,weak) id<showTimerDelegate>timerDelegate;
@property (nonatomic, strong) PNPieChart *pieChart;
@property (nonatomic,strong) UIImageView *centerButton;
@property (nonatomic,strong) UILabel *doneLabel;
@property (nonatomic,strong) UILabel *totalLabel;
@property (nonatomic,strong) UILabel *themeLabel;

@property (nonatomic,strong) UIButton *timerButton;
@property (nonatomic,strong) UILabel *timerLabel;

@property (nonatomic,strong) UIView *reminderView;
@property (nonatomic,strong) UILabel *reminderTime;
//@property (nonatomic,strong) UILabel *reminderDays;


@property BOOL isTimerShown;
@property NSInteger timerCount;

@property (nonatomic,strong) UIButton *finishButton;
@property (nonatomic,strong) UIButton *goOnButton;


-(void)timerPlus;



-(void)returnTimer;
-(void)updatePieWith:(NSArray *)array andTotal:(CGFloat)total byTime:(BOOL)isByTime centerColor:(UIColor *)myColor;
-(void)showTimerFrom:(NSInteger )startTime;
-(void)showReminder;
-(void)hideReminder;
- (void)maskCellFromTop:(CGFloat)margin;

@end
