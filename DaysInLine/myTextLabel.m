//
//  myTextLabel.m
//  DaysInLine
//
//  Created by Eric Cao on 5/29/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "myTextLabel.h"

@implementation myTextLabel

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        self.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = [UIColor clearColor];
        self.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
        self.textColor = [UIColor colorWithWhite:0.9f alpha:0.8];
        self.adjustsFontSizeToFitWidth = YES;

        
    }
    return self;
}


-(id)initWithFrame:(CGRect)frame andFontName:(NSString *)name andSize:(CGFloat)fontSize
{
    self = [super initWithFrame:frame];
    if (self) {
    
        self.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = [UIColor clearColor];
        self.font = [UIFont fontWithName:name size:fontSize];
        self.textColor = [UIColor colorWithWhite:0.9f alpha:0.8];
        self.adjustsFontSizeToFitWidth = YES;

        
    }
    return self;

}

-(id)initWithFrame:(CGRect)frame andSize:(CGFloat)fontSize
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = [UIColor clearColor];
        self.font = [UIFont fontWithName:@"HelveticaNeue" size:fontSize];
        self.textColor = [UIColor colorWithWhite:0.9f alpha:0.8];
        self.adjustsFontSizeToFitWidth = YES;

    }
    return self;
    
}

-(id)initWithFrame:(CGRect)frame andColor:(UIColor *)textColor
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = [UIColor clearColor];
        self.textColor = textColor ;
        self.adjustsFontSizeToFitWidth = YES;
        
        
    }
    return self;
    
}


@end
