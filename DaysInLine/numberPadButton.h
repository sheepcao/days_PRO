//
//  numberPadButton.h
//  simpleFinance
//
//  Created by Eric Cao on 4/13/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface numberPadButton : UIButton
{
    int number;
    CGFloat fontSize;
    NSString *fontType;
}
@property (nonatomic,strong)NSString *symbolText;
@property (nonatomic,strong)UIView *selectedBack;
@property BOOL isNumber;


-(void)setupSymbols;
-(void)setupNumbers;
-(void)keySelectedStyle;
-(void)keyNotSelectedStyle;

@end
