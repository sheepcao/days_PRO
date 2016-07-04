//
//  LuckyLabel.m
//  simpleFinance
//
//  Created by Eric Cao on 5/6/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "LuckyLabel.h"
#import "global.h"
@interface LuckyLabel ()
{
    CGFloat fontSize;
    CGFloat lineSpace;

}
@end
@implementation LuckyLabel

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
     
        self.numberOfLines = 5;
        self.alpha = 1.0f;
        self.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.45];
        self.shadowOffset =  CGSizeMake(0, 0.5);
        
        
    }
    return self;
}

-(void)makeText:(NSString *)text
{
    
    if (IS_IPHONE_5_OR_LESS) {
        fontSize = 12.5f;
        lineSpace = 0.33f;
    }else if(IS_IPHONE_6)
    {
        fontSize = 13.0f;
        lineSpace = 0.4;
    }else
    {
        fontSize = 13.5f;
        lineSpace = 0.41;
    }
    
    if (text.length > 130) {
        fontSize -= 2.0f;
    }
    
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                 @{UIFontDescriptorFamilyAttribute: @"Source Han Sans CN",
                                                   UIFontDescriptorNameAttribute:@"SourceHanSansCN-Normal",
                                                   UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: fontSize]
                                                   }];
    
    CGAffineTransform matrix =  CGAffineTransformMake(1, 0, tanf(5.2 * (CGFloat)M_PI / 180), 1, 0, 0);
    attributeFontDescriptor = [attributeFontDescriptor fontDescriptorWithMatrix:matrix];
    self.font = [UIFont fontWithDescriptor:attributeFontDescriptor size:0.0];
    
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:attributeFontDescriptor.pointSize *lineSpace];
    [attrString addAttribute:NSParagraphStyleAttributeName
                       value:style
                       range:NSMakeRange(0, attrString.length)];
    self.attributedText = attrString;
}

@end
