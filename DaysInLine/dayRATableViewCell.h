//
//  dayRATableViewCell.h
//  simpleFinance
//
//  Created by Eric Cao on 5/5/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface dayRATableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *expenseLabel;
@property (weak, nonatomic) IBOutlet UILabel *incomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *customTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *expandImage;
@property (weak, nonatomic) IBOutlet UILabel *incomeTitle;
@property (weak, nonatomic) IBOutlet UILabel *expenseTitle;


- (void)setupWithTitle:(NSString *)title childCount:(NSInteger)childCount level:(NSInteger)level isExpanded:(BOOL)isExpanded  andIncome:(NSString *)income andExpense:(NSString *)expense andColor:(UIColor *)myColor;
- (void)goExpendAnimated:(BOOL)animated;
- (void)goCollapseAnimated:(BOOL)animated;
@end
