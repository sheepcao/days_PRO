//
//  goalTableViewCell.m
//  DaysInLine
//
//  Created by Eric Cao on 6/3/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "goalTableViewCell.h"
#import "global.h"
#import "CommonUtility.h"

@implementation goalTableViewCell


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 4, SCREEN_WIDTH - 32, goalRowHeight - 8)];
        whiteView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:0.2f];
        whiteView.layer.cornerRadius = 7;
        [self addSubview:whiteView];
        
        self.isTimerShown = NO;
        
        // adding pie===============================================================
        NSArray *items = @[[PNPieChartDataItem dataItemWithValue:80 color:PNRed
                                                     description:@"吃喝"],
                           [PNPieChartDataItem dataItemWithValue:20 color:PNBlue description:@"阅读"]
                           ];
        
        self.pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake(20, 8.0, goalRowHeight-16, goalRowHeight - 16) items:items];

        self.pieChart.innerCircleRadius = self.pieChart.outerCircleRadius - 5;
        [self.pieChart strokeChart];
        self.pieChart.displayAnimated = NO;
        self.pieChart.shouldHighlightSectorOnTouch = NO;
        self.pieChart.userInteractionEnabled = NO;
        self.pieChart.labelPercentageCutoff = 1.1;
        self.pieChart.duration = 0.38f;
        [self addSubview:self.pieChart];
        
        self.centerButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, goalRowHeight-30, goalRowHeight-30)];
        [self.centerButton setCenter:CGPointMake(self.pieChart.center.x, self.pieChart.center.y)];    ;
//


        [self addSubview:self.centerButton];
        
        self.doneLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.centerButton.frame.size.width/8, 0, self.centerButton.frame.size.width*3/4, self.centerButton.frame.size.height *3/5)];
        self.doneLabel.numberOfLines = 1;
        self.doneLabel.adjustsFontSizeToFitWidth = YES;
        self.doneLabel.textAlignment = NSTextAlignmentCenter;
        self.doneLabel.backgroundColor = [UIColor clearColor];
        self.doneLabel.font  = [UIFont fontWithName:@"Avenir-Medium" size:15.0];
        [self.centerButton addSubview:self.doneLabel];
        
        UIView *midline = [[UIView alloc] initWithFrame:CGRectMake(13, self.centerButton.frame.size.height *.55 , self.centerButton.frame.size.width - 26, 0.6)];
        midline.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0f];
        [self.centerButton addSubview:midline];
        
        
        self.totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.centerButton.frame.size.width/4,self.doneLabel.frame.size.height + 1, self.centerButton.frame.size.width/2, self.centerButton.frame.size.height *2/5 - 1)];
        self.totalLabel.numberOfLines = 1;
        self.totalLabel.adjustsFontSizeToFitWidth = YES;
        self.totalLabel.textAlignment = NSTextAlignmentCenter;
        self.totalLabel.backgroundColor = [UIColor clearColor];
        self.totalLabel.font  = [UIFont fontWithName:@"Avenir-Medium" size:11.5];
        [self.centerButton addSubview:self.totalLabel];
        
        // adding  title =========================================================
        self.themeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.pieChart.frame.size.width + self.pieChart.frame.origin.x + 10, goalRowHeight/2 - 15, 120, 30)];
        self.themeLabel.numberOfLines = 1;
        self.themeLabel.adjustsFontSizeToFitWidth = YES;
        self.themeLabel.textAlignment = NSTextAlignmentLeft;
        self.themeLabel.backgroundColor = [UIColor clearColor];
        self.themeLabel.font  = [UIFont fontWithName:@"Avenir-Roman" size:15.0];
        [self addSubview:self.themeLabel];
        
        // adding reminder =========================================================
    
        self.reminderView = [[UIView alloc] initWithFrame:CGRectMake(self.themeLabel.frame.origin.x, goalRowHeight/2, self.themeLabel.frame.size.width, 40)];
        UIImageView *reminderIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 23, 23)];
        [reminderIcon setImage:[UIImage imageNamed:@"提醒"]];
        [self.reminderView addSubview:reminderIcon];
        
        self.reminderTime = [[UILabel alloc] initWithFrame:CGRectMake(28, 10,  self.reminderView .frame.size.width - reminderIcon.frame.size.width,25)];
        self.reminderTime.numberOfLines = 1;
        self.reminderTime.font = [UIFont fontWithName:@"HelveticaNeue" size:13.5f];
        self.reminderTime.textAlignment = NSTextAlignmentLeft;
        [self.reminderView addSubview:self.reminderTime];
//        
//        self.reminderDays = [[UILabel alloc] initWithFrame:CGRectMake(25, self.reminderTime.frame.size.height ,  self.reminderView .frame.size.width - reminderIcon.frame.size.width,12)];
//        self.reminderDays.numberOfLines = 1;
//        self.reminderDays.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10.5f];
//        self.reminderDays.textAlignment = NSTextAlignmentCenter;
//        self.reminderDays.adjustsFontSizeToFitWidth = YES;
//        [self.reminderView addSubview:self.reminderDays];
    
        
        [self.reminderView setHidden:YES];
        
        [self addSubview:self.reminderView];
        
        // adding Timer button
        self.timerButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 32 -16) -  (goalRowHeight-40), 20 , goalRowHeight-40, goalRowHeight - 40)];
        [self.timerButton setImage:[UIImage imageNamed:@"timer2"] forState:UIControlStateNormal];
        [self.timerButton setBackgroundColor:[UIColor darkGrayColor]];
        self.timerButton.layer.cornerRadius = self.timerButton.frame.size.width/2;
        self.timerButton.layer.shadowColor =  [UIColor blackColor].CGColor;
        self.timerButton.layer.shadowOffset = CGSizeMake(0.9f, 1.3f);
        self.timerButton.layer.shadowOpacity = 0.8;

        self.timerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.timerButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.timerButton.titleLabel.font  = [UIFont fontWithName:@"Avenir-Medium" size:12.5];
        [self.timerButton setTitleColor:TextColor1 forState:UIControlStateNormal];

        [self.timerButton addTarget:self.timerDelegate action:@selector(timerMove:) forControlEvents:UIControlEventTouchUpInside];
        
        self.timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.timerButton.frame.origin.x + 10, self.timerButton.center.y - 13, 20, 26)];
        self.timerLabel.numberOfLines = 1;
        self.timerLabel.adjustsFontSizeToFitWidth = YES;
        self.timerLabel.textAlignment = NSTextAlignmentCenter;
        self.timerLabel.font  = [UIFont fontWithName:@"Avenir-Medium" size:12.5];
        self.timerLabel.layer.cornerRadius = 6;
        self.timerLabel.layer.masksToBounds = YES;
        self.timerLabel.layer.shadowColor =  [UIColor blackColor].CGColor;
        self.timerLabel.layer.shadowOffset = CGSizeMake(0.3f, 0.5f);
        self.timerLabel.alpha = 0.0;
        
        [self addSubview:self.timerLabel];
        [self addSubview:self.timerButton];
        
        
        self.finishButton = [[UIButton alloc] initWithFrame:CGRectMake(self.timerButton.frame.origin.x-15, 10, self.timerButton.frame.size.width+20, 30)];
        [self.finishButton setTitle:NSLocalizedString(@"移至成就",nil) forState:UIControlStateNormal];
        self.finishButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0f];
        self.finishButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.finishButton.layer.cornerRadius = 6;
        self.finishButton.layer.masksToBounds = YES;
        self.finishButton.layer.shadowColor =  [UIColor darkGrayColor].CGColor;
        self.finishButton.layer.shadowOffset = CGSizeMake(0.3f, 0.5f);
        self.finishButton.layer.borderColor = [UIColor colorWithRed:243/255.0f green:209/255.0f blue:104/255.0f alpha:1.0f].CGColor;
        self.finishButton.layer.borderWidth = 1.2;
        [self.finishButton addTarget:self.timerDelegate action:@selector(archiveGoal:) forControlEvents:UIControlEventTouchUpInside];

        
        self.goOnButton = [[UIButton alloc] initWithFrame:CGRectMake(self.finishButton.frame.origin.x, self.finishButton.frame.origin.y+self.finishButton.frame.size.height + 6, self.finishButton.frame.size.width, 30)];
        [self.goOnButton setTitle:NSLocalizedString(@"目标进阶",nil) forState:UIControlStateNormal];
        self.goOnButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0f];
        self.goOnButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.goOnButton.layer.cornerRadius = 6;
        self.goOnButton.layer.masksToBounds = YES;
        self.goOnButton.layer.shadowColor =  [UIColor darkGrayColor].CGColor;
        self.goOnButton.layer.shadowOffset = CGSizeMake(0.3f, 0.5f);
        self.goOnButton.layer.borderColor = [UIColor colorWithRed:243/255.0f green:209/255.0f blue:104/255.0f alpha:1.0f].CGColor;
        self.goOnButton.layer.borderWidth = 1.2;
        [self.goOnButton addTarget:self.timerDelegate action:@selector(KeepingGoal:) forControlEvents:UIControlEventTouchUpInside];

        
        [self addSubview:self.finishButton];
        [self addSubview:self.goOnButton];

      }
    
    return  self;
}

-(void)showTimerFrom:(NSInteger )startTime
{
    [self.timerButton setEnabled:NO];
    [self.timerButton setImage:nil forState:UIControlStateNormal];
    [self.timerButton setTitle:@"STOP" forState:UIControlStateNormal];

    [self.timerLabel setText:@"0:00:00"];
    self.timerCount = startTime;
    [self.timerLabel setFrame:CGRectMake(self.timerButton.frame.origin.x - 40, self.timerLabel.frame.origin.y, 50, self.timerLabel.frame.size.height)];

    [UIView animateWithDuration:0.25f delay:0.01f options:UIViewAnimationOptionCurveEaseIn animations:^{
        if (self.timerLabel) {
            NSLog(@"animating...");
            self.timerLabel.alpha = 1.0f;
            self.timerLabel.layer.cornerRadius = 6;

            [self.timerLabel setFrame:CGRectMake(self.timerButton.frame.origin.x - 70, self.timerLabel.frame.origin.y, 80, self.timerLabel.frame.size.height)];
        }
    } completion:^(BOOL isfinished){
        NSLog(@"animating done");

        [self.timerButton setEnabled:YES];
        self.isTimerShown = YES;
    } ];
    
    
}
-(void)returnTimer
{
    [self.timerButton setEnabled:NO];

    [UIView animateWithDuration:0.28f delay:0.01f options:UIViewAnimationOptionLayoutSubviews animations:^{
        if (self.timerLabel) {
            self.timerLabel.alpha = 0.0f;
            self.timerLabel.layer.cornerRadius = 6;

            [self.timerLabel setFrame:CGRectMake(self.timerButton.frame.origin.x , self.timerButton.center.y - 13, 20, 26)];
        }
    } completion:^(BOOL isfinished){
        [self.timerButton setEnabled:YES];
        [self.timerButton setImage:[UIImage imageNamed:@"timer2"] forState:UIControlStateNormal];
        [self.timerButton setTitle:@"" forState:UIControlStateNormal];

        self.isTimerShown = NO;
    } ];
}

-(void)updatePieWith:(NSArray *)array andTotal:(CGFloat)total byTime:(BOOL)isByTime centerColor:(UIColor *)myColor
{
    [self.pieChart setItems:array];
    [self.pieChart recompute];
    [self.pieChart strokeChart];
    
    [self.doneLabel setTextColor:myColor];
    [self.totalLabel setTextColor:myColor];
    
    PNPieChartDataItem * itemDone = array[0];

    if (isByTime) {
        if ([CommonUtility myContainsStringFrom:[NSString stringWithFormat:@"%.2f",itemDone.value] forSubstring:@".00"])
        {
            [self.doneLabel setText:[NSString stringWithFormat:@"%d h",(int)itemDone.value]];
        }else
        {
            [self.doneLabel setText:[NSString stringWithFormat:@"%.2f h",itemDone.value]];
        }
        [self.totalLabel setText:[NSString stringWithFormat:@"%d h",(int)(total)]];

    }else
    {
        [self.doneLabel setText:[NSString stringWithFormat:@"%d",(int)itemDone.value]];
        [self.totalLabel setText:[NSString stringWithFormat:@"%d",(int)(total)]];
    }
    
    [self.centerButton setBackgroundColor:[UIColor clearColor]];
    self.themeLabel.textColor = myColor;
    self.reminderTime.textColor = [UIColor colorWithRed:254/255.0f green:189/255.0f blue:82/255.0f alpha:1.0f];
//    self.reminderDays.textColor = [UIColor colorWithRed:254/255.0f green:189/255.0f blue:82/255.0f alpha:1.0f];

    self.timerLabel.textColor = normalColor;
    [self.timerLabel setBackgroundColor:itemDone.color];
    [self.timerButton setBackgroundColor:itemDone.color];


}

-(void)timerPlus
{
    self.timerCount ++;
    int second = self.timerCount%60;
    NSInteger minute = self.timerCount/60;
    NSInteger hours = minute/60;
    minute %= 60;
    [self.timerLabel setText:[NSString stringWithFormat:@"%ld:%02ld:%02d",(long)hours,(long)minute,second]];
    
}

-(void)showReminder
{
    CGRect aframe = self.themeLabel.frame;
    aframe.origin.y = goalRowHeight/2 - aframe.size.height + 6;
    [self.themeLabel setFrame:aframe];
    [self.reminderView setHidden:NO];
}

-(void)hideReminder
{
    [self.themeLabel setFrame:CGRectMake(self.pieChart.frame.size.width + self.pieChart.frame.origin.x + 10, goalRowHeight/2 - 15, 120, 30)];
    [self.reminderView setHidden:YES];

}

- (void)maskCellFromTop:(CGFloat)margin {
    self.layer.mask = [self visibilityMaskWithLocation:margin/self.frame.size.height];
    self.layer.masksToBounds = YES;
}
- (CAGradientLayer *)visibilityMaskWithLocation:(CGFloat)location {
    CAGradientLayer *mask = [CAGradientLayer layer];
    mask.frame = self.bounds;
    mask.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:1 alpha:0] CGColor], (id)[[UIColor colorWithWhite:1 alpha:1] CGColor], nil];
    mask.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:location], [NSNumber numberWithFloat:location], nil];
    return mask;
}


@end
