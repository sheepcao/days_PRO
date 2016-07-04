//
//  dayRATableViewCell.m
//  simpleFinance
//
//  Created by Eric Cao on 5/5/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "dayRATableViewCell.h"

@implementation dayRATableViewCell


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.selectedBackgroundView = [UIView new];
    self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:1.0 alpha:0.041].CGColor, (id)[UIColor colorWithWhite:1.0 alpha:0.008].CGColor, nil];
    
    gradientLayer.startPoint = CGPointMake(0.0f, 1.0f);
    gradientLayer.endPoint = CGPointMake(0.0f, 0.0f);
    self.layer.mask = gradientLayer;
    [self.layer insertSublayer:gradientLayer atIndex:0];
    
    [self.incomeTitle setText:NSLocalizedString(@"工作:",nil)];
    [self.expenseTitle setText:NSLocalizedString(@"生活:",nil)];
    
    self.incomeTitle.adjustsFontSizeToFitWidth = YES;
    self.expenseTitle.adjustsFontSizeToFitWidth = YES;
}


- (void)setupWithTitle:(NSString *)title childCount:(NSInteger)childCount level:(NSInteger)level isExpanded:(BOOL)isExpanded  andIncome:(NSString *)income andExpense:(NSString *)expense andColor:(UIColor *)myColor
{
    
    
    [self.customTitleLabel setTextColor:myColor];
    [self.incomeLabel setTextColor:myColor];
    [self.expenseLabel setTextColor:myColor];
    [self.incomeTitle setTextColor:myColor];
    [self.expenseTitle setTextColor:myColor];

    
    self.customTitleLabel.text = [title stringByAppendingString:NSLocalizedString(@"日",nil)];
    self.expenseLabel.text = [NSString stringWithFormat:@"%@",expense];
    self.incomeLabel.text =  [NSString stringWithFormat:@"%@",income];;

    self.backgroundColor = [UIColor clearColor];
    
    if (isExpanded) {
        [self.expandImage setImage:[UIImage imageNamed:@"return"]];
    }else
    {
        [self.expandImage setImage:[UIImage imageNamed:@"expend"]];
    }
    

    if (childCount == 0) {
        [self.expandImage setImage:nil];
    }
    
}
- (void)goExpendAnimated:(BOOL)animated
{
    [UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
        [self.expandImage setImage:[UIImage imageNamed:@"return"]];
    }];
}
- (void)goCollapseAnimated:(BOOL)animated
{
    [UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
        [self.expandImage setImage:[UIImage imageNamed:@"expend"]];
    }];
}

@end
