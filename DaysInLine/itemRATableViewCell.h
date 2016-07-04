//
//  itemRATableViewCell.h
//  simpleFinance
//
//  Created by Eric Cao on 5/5/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface itemRATableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *point;

- (void)setupWithCategory:(NSString *)category andIncome:(NSString *)income andExpense:(NSString *)expense andColor:(UIColor *)myColor;
@end
