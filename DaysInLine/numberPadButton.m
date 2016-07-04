//
//  numberPadButton.m
//  simpleFinance
//
//  Created by Eric Cao on 4/13/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "numberPadButton.h"
#import "global.h"

@interface numberPadButton ()
{
    CGRect selfFrame;
}


@end

@implementation numberPadButton

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        selfFrame = frame;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = numberColor;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 0.5f;

        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        [self setBackgroundImage:[self imageWithColor:symbolSelectedColor] forState:UIControlStateDisabled];

    }
    return self;
}

- (void) setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        if (self.tag == 13) {
            return;
        }
        if ((self.tag==4) || (self.tag==8)  || (self.tag==12)  || (self.tag==16) ) {
            self.backgroundColor=symbolSelectedColor;
        }else
        {
            self.backgroundColor = numberSelectedColor;
        }
    }
    else {
        if (self.tag == 13) {
            return;
        }
        if ((self.tag==4) || (self.tag==8)  || (self.tag==12)  || (self.tag==16) ) {
            self.backgroundColor = symbolColor;
        }else
        {
            self.backgroundColor = numberColor;
        }
    }
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)keySelectedStyle
{
    self.layer.borderWidth = 2.0f;
    [self setEnabled:NO];

}

-(void)keyNotSelectedStyle
{
    self.layer.borderWidth = 0.5f;
    [self setEnabled:YES];
}

-(void)setupNumbers
{
    switch (self.tag) {
        case 1:
            number = 7;
            break;
        case 2:
            number = 8;
            break;
        case 3:
            number = 9;
            break;
        case 5:
            number = 4;
            break;
        case 6:
            number = 5;
            break;
        case 7:
            number = 6;
            break;
        case 9:
            number = 1;
            break;
        case 10:
            number = 2;
            break;
        case 11:
            number = 3;
            break;
        case 14:
            number = 0;
            break;
        default:
            number = -1;

            break;
    }
}

-(void)setupSymbols
{
    fontSize = 36;
    fontType = @"HelveticaNeue-UltraLight";
    switch (self.tag) {
        case 1:
            self.symbolText = @"7";
            self.isNumber = YES;
            break;
        case 2:
            self.symbolText = @"8";
            self.isNumber = YES;
            break;
        case 3:
            self.symbolText = @"9";
            self.isNumber = YES;
            break;
        case 4:
            self.symbolText = @"delete";
            self.isNumber = NO;
            fontType = @"HelveticaNeue";
            fontSize = 22;
            self.backgroundColor = symbolColor;
            [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self setImage:[UIImage imageNamed:@"delete1.png"] forState:UIControlStateNormal];
            break;
        case 5:
            self.symbolText = @"4";
            self.isNumber = YES;
            break;
        case 6:
            self.symbolText = @"5";
            self.isNumber = YES;
            break;
        case 7:
            self.symbolText = @"6";
            self.isNumber = YES;
            break;
        case 8:
            self.symbolText = @"+";
            self.isNumber = NO;
            fontType = @"HelveticaNeue";
            fontSize = 22;
            self.backgroundColor = symbolColor;
            [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self setImage:[UIImage imageNamed:@"plus1.png"] forState:UIControlStateNormal];

            break;
        case 9:
            self.symbolText = @"1";
            self.isNumber = YES;
            break;
        case 10:
            self.symbolText = @"2";
            self.isNumber = YES;
            break;
        case 11:
            self.symbolText = @"3";
            self.isNumber = YES;
            break;
        case 12:
            self.symbolText = @"-";
            self.isNumber = NO;
            fontType = @"HelveticaNeue";
            fontSize = 22;
            self.backgroundColor = symbolColor;
            [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self setImage:[UIImage imageNamed:@"minus1.png"] forState:UIControlStateNormal];

            break;
        case 13:
    
            self.symbolText = NSLocalizedString(@" ",nil);
            self.isNumber = NO;
            fontType = @"HelveticaNeue-Light";
            fontSize = 16;
//            self.layer.borderWidth = 1.0f;
//            self.layer.borderColor = [UIColor blackColor].CGColor;
//            self.backgroundColor = [UIColor colorWithRed:152/255.0f green:154/255.0f blue:156/255.0f alpha:1.0f];
//            [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

            break;
        case 14:
            self.symbolText = @"0";
            self.isNumber = YES;
            break;
        case 15:
            self.symbolText = @".";
            self.isNumber = YES;
            fontType = @"HelveticaNeue";
            fontSize = 22;
            break;
        case 16:
            self.symbolText = @"OK";
            self.isNumber = NO;
            fontType = @"HelveticaNeue";
            fontSize = 22;
            self.backgroundColor = symbolColor;
            [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self setImage:[UIImage imageNamed:@"equal1.png"] forState:UIControlStateNormal];

            break;
            
        default:
            break;
    }
    

    
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                 @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                   UIFontDescriptorNameAttribute:fontType,
                                                   UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: fontSize]
                                                   }];
    
    [self.titleLabel setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0]];
    
}



@end
