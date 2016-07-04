//
//  itemDetailTableViewCell.m
//  simpleFinance
//
//  Created by Eric Cao on 4/23/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "itemDetailTableViewCell.h"
#import "global.h"
#import "highLightButton.h"

@implementation itemDetailTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        CGFloat Height;

        if (IS_IPHONE_4_OR_LESS) {
            Height = 20;
        }else
        {
            Height = 28;
        }
        
        self.leftText = [[UILabel alloc] initWithFrame:CGRectMake(20, Height, SCREEN_WIDTH*2/5+10, 30)];
        
        self.rightText = [[highLightButton alloc] initWithFrame:CGRectMake(self.leftText.frame.origin.x + self.leftText.frame.size.width +10, Height, SCREEN_WIDTH*3/5 -10 - 20-20 -10, 30)];
        self.rightText.layer.borderWidth = 0.75f;
        self.rightText.layer.borderColor = normalColor.CGColor;
        self.rightText.layer.cornerRadius = 5;
        [self addSubview:self.leftText ];
        [self addSubview:self.rightText ];
        
        [self.rightText addTarget:self.padDelegate action:@selector(showPad:) forControlEvents:UIControlEventTouchUpInside];
        
        self.leftText.font = [UIFont fontWithName:@"HelveticaNeue" size:14.5f];
        self.leftText.textAlignment = NSTextAlignmentLeft;
        self.rightText.titleLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:14.0f];
        self.rightText.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.rightText.titleLabel.numberOfLines = 1;
        self.rightText.titleLabel.adjustsFontSizeToFitWidth = TRUE;
        self.rightText.titleLabel.minimumScaleFactor = 0.7;
        
    }
    return self;
}

-(void)addExpend
{
    UIImageView *expendImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.rightText.frame.size.width - 20, 6, 18, 18)];
    [expendImage setImage:[UIImage imageNamed:@"expend"]];
    
    expendImage.tag = 100;
    
    if (![self.rightText viewWithTag:100]) {
        [self.rightText addSubview:expendImage];
    }
    
}

-(void)removeExpend
{
    UIView *oneSub = [self.rightText viewWithTag:100];
    
    if (oneSub) {
        [oneSub removeFromSuperview];
    }
    
}


-(void)redrawRightButton:(CGRect)rect
{
    if (self.rightText) {
        [self.rightText removeFromSuperview];
        CGFloat Height;

        if (IS_IPHONE_4_OR_LESS) {
            Height = 20;
        }else
        {
            Height = 28;
        }
        self.rightText = [[highLightButton alloc] initWithFrame:rect];
        self.rightText.layer.borderWidth = 0.75f;
        self.rightText.layer.borderColor = normalColor.CGColor;
        self.rightText.layer.cornerRadius = 5;
        self.rightText.titleLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:14.0f];
        self.rightText.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.rightText.titleLabel.numberOfLines = 1;
        self.rightText.titleLabel.adjustsFontSizeToFitWidth = TRUE;
        self.rightText.titleLabel.minimumScaleFactor = 0.6;
        [self addSubview:self.rightText ];
        
        [self.rightText addTarget:self.padDelegate action:@selector(showPad:) forControlEvents:UIControlEventTouchUpInside];
        
    }
}



- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
