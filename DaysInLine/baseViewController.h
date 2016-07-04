//
//  baseViewController.h
//  simpleFinance
//
//  Created by Eric Cao on 5/4/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface baseViewController : UIViewController
@property (nonatomic,strong) UIColor *myTextColor;
@property(nonatomic,strong) UIImageView *myBackImage;
- (void)configUIAppearance;
@end
