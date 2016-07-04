//
//  pickerLabel.m
//  simpleFinance
//
//  Created by Eric Cao on 5/6/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "pickerLabel.h"
#import "CommonUtility.h"

@implementation pickerLabel


-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        
        self.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = [UIColor clearColor];
        

    }
    return self;
}

-(void)makeText:(NSString *)text
{
    UIFontDescriptor *attributeFontDescriptorFirstPart = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                          @{UIFontDescriptorFamilyAttribute: @"HelveticaNeue",
                                                            UIFontDescriptorNameAttribute:@"HelveticaNeue",
                                                            UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: 18.0f]
                                                            }];
    
    
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                 @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                   UIFontDescriptorNameAttribute:@"HelveticaNeue-Light",
                                                   UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: 18.0]
                                                   }];
    
    NSString *srcText = text;
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:srcText];
    
    if([CommonUtility myContainsStringFrom:srcText forSubstring:@"     "])
    {
        NSRange range = [srcText rangeOfString:@"     "];
        NSRange rangeFirstPart,rangeSecondPart;
        rangeFirstPart.location = 0;
        rangeFirstPart.length = range.location;
        
        rangeSecondPart.location = range.location+range.length;
        rangeSecondPart.length = srcText.length -range.length - rangeFirstPart.length;
        
        [attributedText addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:attributeFontDescriptor size:0] range:rangeSecondPart];
        [attributedText addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:attributeFontDescriptorFirstPart size:0] range:rangeFirstPart];
        
        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:0.95f] range:NSMakeRange(0, attributedText.length)];
    } else
    {
        [attributedText addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:attributeFontDescriptorFirstPart size:0] range:NSMakeRange(0, attributedText.length)];
        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:0.95f] range:NSMakeRange(0, attributedText.length)];
    }
    self.attributedText = attributedText;
}
@end
