//
//  PieExplainTableViewCell.m
//  simpleFinance
//
//  Created by Eric Cao on 4/20/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "PieExplainTableViewCell.h"
#import "global.h"
#define  pointRadius 8

@implementation PieExplainTableViewCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        if (IS_IPHONE_5_OR_LESS) {
            fontSize = 13.0f;
        }else if(IS_IPHONE_6)
        {
            fontSize = 15.0f;
        }else
        {
            fontSize = 15.5f;
        }
        
        CGFloat thisRowHeight = self.frame.size.height;
        self.seperator = [[UILabel alloc] initWithFrame:CGRectMake(16, thisRowHeight/2-pointRadius, pointRadius*2, pointRadius*2)];
        self.seperator.backgroundColor = [UIColor clearColor];
        self.seperator.layer.cornerRadius = pointRadius;
        self.seperator.layer.masksToBounds = YES;
        
        self.categoryName = [[UILabel alloc] initWithFrame:CGRectMake(self.seperator.frame.size.width+self.seperator.frame.origin.x+10, 6, SCREEN_WIDTH-(self.seperator.frame.size.width+self.seperator.frame.origin.x+15)-160, thisRowHeight-6*2)];
        
        self.MoneyRatio = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 80 , 7, 80, thisRowHeight-6*2)];
        self.MoneyRatio.textAlignment = NSTextAlignmentLeft;
        self.MoneyRatio.adjustsFontSizeToFitWidth = YES;

        UIView *midline = [[UIView alloc] initWithFrame:CGRectMake(self.MoneyRatio.frame.origin.x - 9, self.MoneyRatio.frame.size.height - fontSize - 5, 1, fontSize + 5)];
        [midline setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:midline];
        
        self.money = [[UILabel alloc] initWithFrame:CGRectMake(midline.frame.origin.x-88, 7, 80, thisRowHeight-6*2)];
        self.categoryName.textAlignment = NSTextAlignmentLeft;
        self.categoryName.adjustsFontSizeToFitWidth = YES;
        self.categoryName.minimumScaleFactor = 0.6f;
        self.money.textAlignment = NSTextAlignmentRight;
        self.money.adjustsFontSizeToFitWidth = YES;
        

        
        

        //
        UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                     @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                       UIFontDescriptorNameAttribute:@"HelveticaNeue-Medium",
                                                       UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: fontSize]
                                                       }];
        
        [self.money setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0]];
        [self.MoneyRatio setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0]];

        self.categoryName.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.48];
        self.categoryName.shadowOffset =  CGSizeMake(0, 0.65);
        self.categoryName.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:fontSize + 1];
        self.money.shadowColor = [normalColor colorWithAlphaComponent:0.35];
        self.money.shadowOffset =  CGSizeMake(0.16, 0.16);
        self.MoneyRatio.shadowColor = [normalColor colorWithAlphaComponent:0.35];
        self.MoneyRatio.shadowOffset =  CGSizeMake(0.16, 0.16);
        


        
        [self addSubview:self.categoryName];
        [self addSubview:self.seperator];
        [self addSubview:self.money];
        [self addSubview:self.MoneyRatio];

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

- (void)maskCellFromTop:(CGFloat)margin {
    self.layer.mask = [self visibilityMaskWithLocation:margin/self.frame.size.height];
    self.layer.masksToBounds = YES;
}

- (CAGradientLayer *)visibilityMaskWithLocation:(CGFloat)location {
    CAGradientLayer *mask = [CAGradientLayer layer];
    mask.frame = self.bounds;
    mask.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:1 alpha:0] CGColor], (id)[[UIColor colorWithWhite:1 alpha:1] CGColor], nil];
    mask.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:location], [NSNumber numberWithFloat:location], nil];
    return mask;
}
@end
