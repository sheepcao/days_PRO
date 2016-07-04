//
//  itemRATableViewCell.m
//  simpleFinance
//
//  Created by Eric Cao on 5/5/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "itemRATableViewCell.h"
#import "CommonUtility.h"

@implementation itemRATableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithCategory:(NSString *)category andIncome:(NSString *)income andExpense:(NSString *)expense andColor:(UIColor *)myColor
{
    self.point.layer.cornerRadius = self.point.frame.size.width/2;
    self.point.layer.masksToBounds = YES;
    
    self.categoryLabel.text = category;
    
    NSString *timeSpace = [NSString stringWithFormat:@"%@ — %@",income,expense];

    [self.moneyLabel setText:timeSpace];

    self.backgroundColor = [UIColor clearColor];
}

@end
