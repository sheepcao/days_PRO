//
//  PieExplainTableViewCell.h
//  simpleFinance
//
//  Created by Eric Cao on 4/20/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PieExplainTableViewCell : UITableViewCell
{
    CGFloat fontSize;
}

@property (nonatomic,strong) UILabel *categoryName;
@property (nonatomic,strong) UILabel *MoneyRatio;
@property (nonatomic,strong) UILabel *money;
@property (nonatomic,strong) UIView *seperator;


- (void)maskCellFromTop:(CGFloat)margin;
@end
