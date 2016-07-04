//
//  gradientButton.m
//  simpleFinance
//
//  Created by Eric Cao on 5/10/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "gradientButton.h"

@implementation gradientButton


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:62/255.0f green:229/255.0f blue:165/255.0f alpha:1.0f].CGColor, (id)[UIColor colorWithRed:37/255.0f green:170/255.0f blue:234/255.0f alpha:1.0].CGColor, nil];
    
    gradientLayer.startPoint = CGPointMake(0.0f, 0.5f);
    gradientLayer.endPoint = CGPointMake(1.0f, 0.5f);
    gradientLayer.cornerRadius = gradientLayer.frame.size.height/2;
    self.layer.mask = gradientLayer;
    
    [self.layer insertSublayer:gradientLayer atIndex:0];
    
}


@end
