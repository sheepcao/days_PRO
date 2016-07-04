//
//  sideTableViewCell.m
//  DaysInLine
//
//  Created by Eric Cao on 6/29/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#define sideRowHeight SCREEN_HEIGHT/5
#define sideRowWidth SCREEN_WIDTH*2/5
#import "sideTableViewCell.h"
#import "global.h"


@implementation sideTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier Image:(UIImage *)image Title:(NSString *)title
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        CGFloat space = -3;
        if (IS_IPHONE_4_OR_LESS) {
            space = -8;
        }

        self.titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(sideRowWidth/4, (sideRowHeight  - sideRowWidth/2)/2, sideRowWidth/2, sideRowWidth/2)];
        [self.titleImage setImage:image];
        [self addSubview:self.titleImage];
        
        self.menuTitle = [[UILabel alloc] initWithFrame:CGRectMake(20 , self.titleImage.frame.size.height + self.titleImage.frame.origin.y + space, sideRowWidth - 40, 20)];
        self.menuTitle.numberOfLines = 1;
        self.menuTitle.adjustsFontSizeToFitWidth = YES;
        self.menuTitle.textAlignment = NSTextAlignmentCenter;
        self.menuTitle.backgroundColor = [UIColor clearColor];
        self.menuTitle.font  = [UIFont fontWithName:@"Avenir-Roman" size:13.5];
        [self.menuTitle setText:title];
        [self.menuTitle setTextColor:TextColor1];
        [self addSubview:self.menuTitle];
        
        
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
