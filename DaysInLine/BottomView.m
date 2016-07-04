//
//  BottomView.m
//  simpleFinance
//
//  Created by Eric Cao on 4/12/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "BottomView.h"
#import "global.h"

@implementation BottomView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 0.85f);
    
    CGContextMoveToPoint(context, 0.0f, 0.0f); //start at this point
    
    CGContextAddLineToPoint(context, SCREEN_WIDTH, 0.0f); //draw to this point
    
    // and now draw the Path!
    CGContextStrokePath(context);
}


@end
