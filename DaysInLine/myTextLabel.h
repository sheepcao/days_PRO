//
//  myTextLabel.h
//  DaysInLine
//
//  Created by Eric Cao on 5/29/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface myTextLabel : UILabel

-(id)initWithFrame:(CGRect)frame andFontName:(NSString *)name andSize:(CGFloat)fontSize;
-(id)initWithFrame:(CGRect)frame andSize:(CGFloat)fontSize;
-(id)initWithFrame:(CGRect)frame andColor:(UIColor *)textColor;
@end
