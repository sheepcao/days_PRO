//
//  categoryItemsTableViewCell.h
//  simpleFinance
//
//  Created by Eric Cao on 4/26/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface categoryItemsTableViewCell : UITableViewCell

@property (nonatomic,strong) UILabel *category;
@property (nonatomic,strong) UILabel *money;

-(void)makeTextStyle:(UIColor *)myColor;
- (void)maskCellFromTop:(CGFloat)margin;

@end
