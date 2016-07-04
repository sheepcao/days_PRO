//
//  dateSelectView.h
//  simpleFinance
//
//  Created by Eric Cao on 4/21/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlatDatePicker.h"

@interface dateSelectView : UIView
@property (nonatomic,strong) UIDatePicker *myDatePicker;
@property (nonatomic,strong) UIButton *startDateButton;
@property (nonatomic,strong) UIButton *endtDateButton;
@property (nonatomic, strong) FlatDatePicker *flatDatePicker;

@end
