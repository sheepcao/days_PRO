//
//  finishedTableViewCell.m
//  DaysInLine
//
//  Created by Eric Cao on 6/13/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "finishedTableViewCell.h"
#import "global.h"

@implementation finishedTableViewCell


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 4, SCREEN_WIDTH - 32, rowHeight - 8)];
        whiteView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:0.2f];
        whiteView.layer.cornerRadius = 7;
        [self addSubview:whiteView];
        
          // adding  title =========================================================
        CGFloat space = 180;
        if (IS_IPHONE_5_OR_LESS) {
            space = 130;
        }
        self.themeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20 , rowHeight/2 - 15, space, 30)];
        self.themeLabel.numberOfLines = 1;
        self.themeLabel.adjustsFontSizeToFitWidth = YES;
        self.themeLabel.textAlignment = NSTextAlignmentLeft;
        self.themeLabel.backgroundColor = [UIColor clearColor];
        self.themeLabel.font  = [UIFont fontWithName:@"Avenir-Roman" size:15.0];
        [self.themeLabel setTextColor:TextColor1];

        [self addSubview:self.themeLabel];
        

        self.finishedDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.themeLabel.frame.origin.x  + self.themeLabel.frame.size.width + 10, 10, SCREEN_WIDTH - 32 - (self.themeLabel.frame.origin.x  + self.themeLabel.frame.size.width + 10), 30)];
        self.finishedDateLabel.numberOfLines = 1;
        self.finishedDateLabel.adjustsFontSizeToFitWidth = YES;
        self.finishedDateLabel.textAlignment = NSTextAlignmentCenter;
        self.finishedDateLabel.font  = [UIFont fontWithName:@"HelveticaNeue" size:13.5];
        self.finishedDateLabel.layer.cornerRadius = 6;
        self.finishedDateLabel.layer.masksToBounds = YES;
        self.finishedDateLabel.layer.shadowColor =  [UIColor blackColor].CGColor;
        self.finishedDateLabel.layer.shadowOffset = CGSizeMake(0.3f, 0.5f);
        [self.finishedDateLabel setTextColor:[UIColor colorWithRed:254/255.0f green:189/255.0f blue:82/255.0f alpha:1.0f]];
        [self addSubview:self.finishedDateLabel];
        
        
        self.totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.finishedDateLabel.frame.origin.x, self.finishedDateLabel.frame.size.height + self.finishedDateLabel.frame.origin.y, self.finishedDateLabel.frame.size.width, 20)];
        self.totalLabel.numberOfLines = 1;
        self.totalLabel.adjustsFontSizeToFitWidth = YES;
        self.totalLabel.textAlignment = NSTextAlignmentCenter;
        self.totalLabel.font  = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11.5];
        [self.totalLabel setTextColor:TextColor2];
        [self addSubview:self.totalLabel];

        
    }
    
    return  self;
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
