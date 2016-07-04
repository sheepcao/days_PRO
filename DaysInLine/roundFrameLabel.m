//
//  roundFrameLabel.m
//  simpleFinance
//
//  Created by Eric Cao on 4/19/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "roundFrameLabel.h"

@implementation roundFrameLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0, 10, 0, 10};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}
@end
