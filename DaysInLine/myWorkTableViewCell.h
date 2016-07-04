//
//  myMaskTableViewCell.h
//  simpleFinance
//
//  Created by Eric Cao on 4/8/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "myTextLabel.h"

@interface myWorkTableViewCell : UITableViewCell
{
    CGFloat fontSize;

}

@property (nonatomic,strong) UILabel *category;
@property (nonatomic,strong) UILabel *note;
@property (nonatomic,strong) UIView *seperator;
@property (nonatomic,strong) UIView *line;
@property (nonatomic,strong) UIView *midLine;
@property (nonatomic,strong) myTextLabel *itemTimeLabel;


- (void)maskCellFromTop:(CGFloat)margin;
-(void)makeTextStyle;
-(void)makeColor:(NSString *)category;
//-(void)makeMidLine:(UIColor *)myColor withHeight:(CGFloat)heigh;
@end
