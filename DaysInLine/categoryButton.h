//
//  categoryButton.h
//  simpleFinance
//
//  Created by Eric Cao on 4/15/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface categoryButton : UIButton
@property (nonatomic,strong) UIColor *categoryColor;

-(void)categorySelectedColor:(UIColor *)color;
-(void)categoryNormalColor;
@end
