//
//  sideTableViewCell.h
//  DaysInLine
//
//  Created by Eric Cao on 6/29/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface sideTableViewCell : UITableViewCell
@property (nonatomic,strong) UILabel *menuTitle;
@property (nonatomic,strong) UIImageView *titleImage;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier Image:(UIImage *)image Title:(NSString *)title;

@end
