//
//  ViewController.h
//  DaysInLine
//
//  Created by Eric Cao on 5/27/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "baseViewController.h"
#import "LuckyLabel.h"

@interface homeViewController :baseViewController
{
    CGFloat moneyLuckSpace;
    CGFloat bottomHeight;
    CGFloat fontSize;

    NSArray *constellationList;
    NSString *constellationSelected;
}

@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *TimelineText;

@property (weak, nonatomic) IBOutlet UIView *luckView;
@property (weak, nonatomic) IBOutlet LuckyLabel *luckyText;
@property (weak, nonatomic) IBOutlet UIButton *constellationButton;

@property (strong, nonatomic)  UITableView *maintableView;

- (IBAction)configConstellation:(id)sender;

@end

