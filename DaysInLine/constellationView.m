//
//  constellationView.m
//  simpleFinance
//
//  Created by Eric Cao on 5/6/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "constellationView.h"
#import "global.h"

@interface constellationView ()
@property (nonatomic,strong) UIView*gestureView;
@end
@implementation constellationView
@synthesize gestureView;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor =  [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:0.78];
        gestureView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 230)];
        gestureView.backgroundColor = [UIColor clearColor];
        [self addSubview:gestureView];
        

        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 230)];
        contentView.tag = 100;
        contentView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.9 alpha:0.9f];
        [self addSubview:contentView];
        
        [UIView animateWithDuration:0.22f delay:0.0f options:UIViewAnimationOptionLayoutSubviews animations:^{
            if (contentView) {
                [contentView setFrame:CGRectMake(contentView.frame.origin.x, SCREEN_HEIGHT - 230, contentView.frame.size.width, contentView.frame.size.height)];
            }
        } completion:nil ];

        
        self.constellPicker = [[UIPickerView alloc]initWithFrame:CGRectMake(20, 40,SCREEN_WIDTH-40 , contentView.frame.size.height -45)];
        self.constellPicker.showsSelectionIndicator=YES;

        [contentView addSubview:self.constellPicker];
        
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(8, 5, 40, 35)];
//        [cancelBtn setTitleEdgeInsets:UIEdgeInsetsMake(15, 0, 15, 0)];
        [cancelBtn setTitle:NSLocalizedString(@"取消",nil) forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.95] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue" size:15.0];
        [contentView addSubview:cancelBtn];
        
        UIButton *selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-48, 5, 40, 35)];
        [selectBtn setTitle:NSLocalizedString(@"确定",nil) forState:UIControlStateNormal];
        [selectBtn setTitleColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.95] forState:UIControlStateNormal];
        selectBtn.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        [contentView addSubview:selectBtn];
        
        [cancelBtn addTarget:self.constellDelegate action:@selector(cancelConstellation) forControlEvents:UIControlEventTouchUpInside];
        [selectBtn addTarget:self.constellDelegate action:@selector(constellationChoose) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *pickerTitle = [[UILabel alloc] initWithFrame:CGRectMake(contentView.frame.size.width/2 - 80, 5, 160, 32)];
        [pickerTitle setText:NSLocalizedString(@"请选择您的星座",nil)];
        pickerTitle.textAlignment = NSTextAlignmentCenter;
        pickerTitle.font =  [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0f];
        
        [contentView addSubview:pickerTitle];
        

    }
    return self;
}

-(void)addGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self.constellDelegate
                                   action:@selector(cancelConstellation)];
    
    [gestureView addGestureRecognizer:tap];
}

-(void)removeDimView
{
    UIView *contentView = [self viewWithTag:100];
    [UIView animateWithDuration:0.2f animations:^{
        if (contentView) {
            [contentView setFrame:CGRectMake(contentView.frame.origin.x, SCREEN_HEIGHT, contentView.frame.size.width, contentView.frame.size.height)];
        }
    } completion:^(BOOL isfinished){
        [self removeFromSuperview];
    }];
}

@end
