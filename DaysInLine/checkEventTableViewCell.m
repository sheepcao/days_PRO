//
//  checkEventTableViewCell.m
//  DaysInLine
//
//  Created by Eric Cao on 6/2/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "checkEventTableViewCell.h"
#import "global.h"

@implementation checkEventTableViewCell


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        CGFloat thisRowHeight = self.frame.size.height;
        
        self.leftText = [[UILabel alloc] initWithFrame:CGRectMake(20, 2, SCREEN_WIDTH/5+10, thisRowHeight - 4)];
        
        self.rightText = [[UILabel alloc] initWithFrame:CGRectMake(self.leftText.frame.origin.x + self.leftText.frame.size.width +30, 2, SCREEN_WIDTH*4/5 -10 - 20-20 -30, thisRowHeight - 4)];
        [self addSubview:self.leftText ];
        [self addSubview:self.rightText ];
        
        self.leftText.font = [UIFont fontWithName:@"Avenir-Medium" size:14.5f];
        self.leftText.textAlignment = NSTextAlignmentLeft;
        self.rightText.font = [UIFont fontWithName:@"Avenir-Medium" size:14.0f];
        self.rightText.textAlignment = NSTextAlignmentRight;
        self.rightText.numberOfLines = 2;
        self.rightText.minimumScaleFactor = 0.8;
        
        
        
    }
    return self;
}



- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
