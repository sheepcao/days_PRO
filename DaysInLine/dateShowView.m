//
//  dateShowView.m
//  simpleFinance
//
//  Created by Eric Cao on 4/25/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "dateShowView.h"
#import "global.h"

@implementation dateShowView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configButtonInView:frame];
    }
    return self;
}


-(void)configButtonInView:(CGRect)frame
{
    //add date selection ======================================================
    self.selectionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.selectionButton.backgroundColor = [UIColor clearColor];
    [self addSubview:self.selectionButton];
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                 @{UIFontDescriptorFamilyAttribute: @"HelveticaNeue",
                                                   UIFontDescriptorNameAttribute:@"HelveticaNeue",
                                                   UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat:  14.0f]
                                                   }];
    UILabel * midLine = [[UILabel alloc] initWithFrame:CGRectMake(self.selectionButton.frame.size.width/2-15, 0, 30, self.selectionButton.frame.size.height)];
    [midLine setText:NSLocalizedString(@"至",nil)];
    midLine.textAlignment = NSTextAlignmentCenter;
    [midLine setTextColor:normalColor];
    [midLine setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0f]];
    [midLine setBackgroundColor:[UIColor clearColor]];
    [self.selectionButton addSubview:midLine];
    
    self.startLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (self.selectionButton.frame.size.width - midLine.frame.size.width)/2, self.selectionButton.frame.size.height)];
    self.startLabel.textAlignment = NSTextAlignmentRight;
    [self.startLabel setTextColor:[UIColor colorWithRed:253/255.0f green:197/255.0f blue:65/255.0f alpha:1.0f]];
    [self.startLabel setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0f]];
    
    self.endLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.startLabel.frame.size.width + midLine.frame.size.width, 0, self.startLabel.frame.size.width, self.startLabel.frame.size.height)];
    self.endLabel.textAlignment = NSTextAlignmentLeft;
    [self.endLabel setTextColor:[UIColor colorWithRed:253/255.0f green:197/255.0f blue:65/255.0f alpha:1.0f]];
    [self.endLabel setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0f]];
    

    [self.selectionButton addSubview:self.startLabel];
    [self.selectionButton addSubview:self.endLabel];
    
}
@end
