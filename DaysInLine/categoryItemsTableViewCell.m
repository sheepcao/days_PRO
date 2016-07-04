//
//  categoryItemsTableViewCell.m
//  simpleFinance
//
//  Created by Eric Cao on 4/26/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "categoryItemsTableViewCell.h"
#import "global.h"
#import "CommonUtility.h"

@implementation categoryItemsTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.category = [[UILabel alloc] initWithFrame:CGRectMake(16, 3, (SCREEN_WIDTH-32)*2/3, SCREEN_WIDTH/8.5-3*2)];
        self.money = [[UILabel alloc] initWithFrame:CGRectMake(self.category.frame.origin.x+self.category.frame.size.width, 3, (SCREEN_WIDTH-32)/3, self.category.frame.size.height)];
        self.category.textAlignment = NSTextAlignmentLeft;
        self.money.textAlignment = NSTextAlignmentRight;

        //
        UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                     @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                       UIFontDescriptorNameAttribute:@"HelveticaNeue-Medium",
                                                       UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: SCREEN_WIDTH/21]
                                                       }];
        [self.money setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0]];

        self.category.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.48];
        self.category.shadowOffset =  CGSizeMake(0, 0.65);
        self.money.shadowColor = [normalColor colorWithAlphaComponent:0.35];
        self.money.shadowOffset =  CGSizeMake(0.16, 0.16);
        
        self.money.adjustsFontSizeToFitWidth = YES;
        self.category.adjustsFontSizeToFitWidth = YES;

        
        [self addSubview:self.category];
        [self addSubview:self.money];
    }
    return self;
}

-(void)makeTextStyle:(UIColor *)myColor
{
    
    self.category.textColor = myColor;
    self.money.textColor = myColor;
    
    UIFontDescriptor *attributeFontDescriptorFirstPart = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                          @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                            UIFontDescriptorNameAttribute:@"HelveticaNeue-Medium",
                                                            UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: SCREEN_WIDTH/22]
                                                            }];
    
    
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                 @{UIFontDescriptorFamilyAttribute: @"Avenir",
                                                   UIFontDescriptorNameAttribute:@"Avenir-Medium",
                                                   UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: SCREEN_WIDTH/22-3.0]
                                                   }];
    
    
    CGAffineTransform matrix =  CGAffineTransformMake(1, 0, tanf(8 * (CGFloat)M_PI / 180), 1, 0, 0);
    attributeFontDescriptor = [attributeFontDescriptor fontDescriptorWithMatrix:matrix];
    
    
    NSString *srcText = self.category.text;
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:srcText];

    if([CommonUtility myContainsStringFrom:srcText forSubstring:@" - "])
    {
        NSRange range = [srcText rangeOfString:@" - "];
        NSRange rangeFirstPart,rangeSecondPart;
        rangeFirstPart.location = 0;
        rangeFirstPart.length = range.location;
        
        rangeSecondPart.location = range.location+range.length;
        rangeSecondPart.length = srcText.length -range.length - rangeFirstPart.length;
        
        [attributedText addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:attributeFontDescriptor size:0] range:rangeSecondPart];
        [attributedText addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:attributeFontDescriptorFirstPart size:0] range:rangeFirstPart];
        
        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0f] range:rangeSecondPart];
    } else
    {
        [attributedText addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:attributeFontDescriptorFirstPart size:0] range:NSMakeRange(0, attributedText.length)];
        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0f] range:NSMakeRange(0, attributedText.length)];
    }
    self.category.attributedText = attributedText;
    
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
