//
//  categoryTableViewCell.h
//  simpleFinance
//
//  Created by Eric Cao on 4/15/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "categoryButton.h"

@protocol categoryTapDelegate <NSObject>
@optional
-(void)categoryTap:(UIButton *)sender;
-(void)categoryDeleteTap:(UIButton *)sender;
@end

@interface categoryTableViewCell : UITableViewCell

@property (nonatomic,weak) id <categoryTapDelegate> categoryDelegate;
@property(nonatomic,strong) categoryButton *firstButton;
-(void)contentWithCategories:(NSArray *)cateArray;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andWidth:(CGFloat )width;

-(void)showDeleteButton;
-(void)removeDeleteButton;

@end
