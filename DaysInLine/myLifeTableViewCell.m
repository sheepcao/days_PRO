//
//  myMaskTableViewCell.m
//  simpleFinance
//
//  Created by Eric Cao on 4/8/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "myLifeTableViewCell.h"
#import "global.h"
#import "CommonUtility.h"
#import "roundFrameLabel.h"

#define  pointRadius 8

@implementation myLifeTableViewCell


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
//        self.midLine = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 0.5, -2, 1, rowHeight+4)];
        
        self.seperator = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - pointRadius, rowHeight/2-pointRadius, pointRadius*2, pointRadius*2)];
        self.seperator.layer.cornerRadius = pointRadius;
        self.seperator.layer.masksToBounds = YES;
        
        self.line = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2,  self.seperator.frame.origin.y + pointRadius - 0.7, SCREEN_WIDTH * 5/66, 1.4)];
        
        self.note = [[roundFrameLabel alloc] initWithFrame:CGRectMake(self.line.frame.origin.x+self.line.frame.size.width,15, SCREEN_WIDTH * 25/66, rowHeight-15*2)];
        self.note.numberOfLines = 3;
        self.note.textAlignment = NSTextAlignmentRight;
        self.note.layer.cornerRadius = 5;
        self.note.layer.masksToBounds = YES;
    
        
        self.category = [[UILabel alloc] initWithFrame:CGRectMake(self.line.frame.size.width+self.line.frame.origin.x, 7, rowHeight-5*2, rowHeight-7*2)];
        self.category.numberOfLines = 1;
        self.category.adjustsFontSizeToFitWidth = YES;
        self.category.minimumScaleFactor = 0.5f;
        self.category.textAlignment = NSTextAlignmentCenter;
        self.category.layer.cornerRadius = 3;
        self.category.layer.masksToBounds = NO;
        self.category.layer.shadowColor = [UIColor blackColor].CGColor;
        self.category.layer.shadowOpacity = 0.8;
        self.category.layer.shadowRadius = 2;
        self.category.layer.shadowOffset = CGSizeMake(1.2f, 0.6f);
        
        
        if (IS_IPHONE_5_OR_LESS) {
            fontSize = 16.5f;
        }else if(IS_IPHONE_6)
        {
            fontSize = 17.0f;
        }else
        {
            fontSize = 18.0f;
        }
        UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                             @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                               UIFontDescriptorNameAttribute:@"HelveticaNeue-Medium",
                                                               UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: fontSize]
                                                               }];
        
        [self.note setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0]];

    
        self.itemTimeLabel = [[myTextLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/16, rowHeight/2 - 20, SCREEN_WIDTH*3/8, 40) andSize:fontSize-2.0];
        self.itemTimeLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:14.0f];

        [self addSubview:self.midLine];
        [self.contentView addSubview:self.line];
        [self addSubview:self.seperator];
        [self.contentView addSubview:self.note];
        [self.contentView addSubview:self.category];
        [self.contentView addSubview:self.itemTimeLabel];
        self.contentView.layer.masksToBounds = YES;


    }
    return self;
}

-(void)makeTextStyle
{
//    [self makeMidLine:myColor withHeight:rowHeight];
    
    [self.category setTextColor:TextColor0];
    [self.note setTextColor:TextColor1];
    
    UIFontDescriptor *attributeFontDescriptorFirstPart = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                          @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                            UIFontDescriptorNameAttribute:@"HelveticaNeue-Light",
                                                   UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: fontSize]
                                                   }];

    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                 @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                   UIFontDescriptorNameAttribute:@"Helvetica Neue-Medium",
                                                   UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: 10.0f]
                                                   }];
    
    
    CGAffineTransform matrix =  CGAffineTransformMake(1, 0, tanf(8 * (CGFloat)M_PI / 180), 1, 0, 0);
    attributeFontDescriptor = [attributeFontDescriptor fontDescriptorWithMatrix:matrix];
    
    
    
    NSString *srcCategory = self.category.text;
    NSMutableAttributedString *attributedCategory = [[NSMutableAttributedString alloc] initWithString:srcCategory];
    NSString *srcNote = self.note.text;
    NSMutableAttributedString *attributedNote = [[NSMutableAttributedString alloc] initWithString:srcNote];

    [attributedCategory addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:attributeFontDescriptorFirstPart size:0] range:NSMakeRange(0, srcCategory.length)];
    [attributedNote addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:attributeFontDescriptor size:0] range:NSMakeRange(0, srcNote.length)];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:attributeFontDescriptor.pointSize *0.41];
    [style setAlignment:NSTextAlignmentRight];
    [attributedNote addAttribute:NSParagraphStyleAttributeName
                       value:style
                       range:NSMakeRange(0, srcNote.length)];


    

    self.category.attributedText = attributedCategory;
    self.note.attributedText = attributedNote;

    if ([self.note.text isEqualToString:@""]) {
        [self.category setFrame:CGRectMake(self.line.frame.origin.x  + self.line.frame.size.width, 7, SCREEN_WIDTH * 22/66, rowHeight-7*2)];
    }else
    {
        [self.category setFrame:CGRectMake(self.line.frame.size.width+self.line.frame.origin.x, 7, rowHeight-5*2, rowHeight-7*2)];
    }
}

-(void)makeColor:(NSString *)category
{
    UIColor *seperatorColor = [[CommonUtility sharedCommonUtility] categoryColor:category];
    [self.seperator setBackgroundColor:seperatorColor];
    [self.note setBackgroundColor:[seperatorColor colorWithAlphaComponent:0.85]];
    [self.category setBackgroundColor:seperatorColor];
    [self.line setBackgroundColor:seperatorColor];

    [self.itemTimeLabel setTextColor:seperatorColor];

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
