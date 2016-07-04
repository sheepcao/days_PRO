//
//  dateSelectView.m
//  simpleFinance
//
//  Created by Eric Cao on 4/21/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "dateSelectView.h"
#import "global.h"

@interface dateSelectView()
@property (nonatomic, strong) UIView *pickerBack;
@property (nonatomic, strong) UIView *timeView;


@end
@implementation dateSelectView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.15f green:0.15f blue:0.15f alpha:0.65f];
        self.pickerBack = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT , SCREEN_WIDTH, kFlatDatePickerHeight)];
        self.pickerBack.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:0.95f];
        [self addSubview:self.pickerBack];
    
        self.flatDatePicker = [[FlatDatePicker alloc] initWithParentView:self.pickerBack];
        self.flatDatePicker.title = NSLocalizedString(@"开始时间:",nil);
        self.flatDatePicker.datePickerMode = FlatDatePickerModeDate;

    }
    return self;
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
