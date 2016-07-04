//
//  categoryTableViewCell.m
//  simpleFinance
//
//  Created by Eric Cao on 4/15/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "categoryTableViewCell.h"
#import "global.h"
#import "categoryObject.h"
#define  symbolColor   [UIColor colorWithRed:196/255.0f green:178/255.0f blue:124/255.0f alpha:1.0f]


@implementation categoryTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andWidth:(CGFloat )width
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
//        CGFloat width = SCREEN_WIDTH -20;
        
        for (int i = 0; i< 4; i++) {
            categoryButton *categoryLabel = [[categoryButton alloc] initWithFrame:CGRectMake(16+i * ((width-20)/4), self.contentView.frame.size.height/2-15, (width-16)/4-16, (int)(width/12))];
            
            UIFontDescriptor *categoryFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                        @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                          UIFontDescriptorNameAttribute:@"HelveticaNeue",
                                                          UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: (int)(SCREEN_WIDTH/28)]
                                                          }];
            
            [categoryLabel.titleLabel setFont:[UIFont fontWithDescriptor:categoryFontDescriptor size:0.0]];
            [categoryLabel setTintColor:normalColor];
            categoryLabel.titleLabel.textAlignment = NSTextAlignmentCenter;
            categoryLabel.titleLabel.adjustsFontSizeToFitWidth = YES;
            categoryLabel.layer.borderWidth = 0.0f;
            categoryLabel.layer.borderColor = normalColor.CGColor;
            categoryLabel.layer.cornerRadius =(int)(SCREEN_WIDTH/65);
            categoryLabel.tag = i+1;
            
            [self.contentView addSubview:categoryLabel];
            
            if (i==0) {
                self.firstButton = categoryLabel;
            }
        }
    }
    
    return  self;
}

-(void)contentWithCategories:(NSArray *)cateArray 
{
    for (int i = 0; i<4; i++) {
        categoryButton *categoryLabel = (categoryButton *)[self viewWithTag:(i+1)];
        [categoryLabel removeTarget:self.categoryDelegate action:@selector(categoryTap:) forControlEvents:UIControlEventTouchUpInside];
        
        categoryLabel.categoryColor = normalColor;
        categoryLabel.layer.borderWidth = 0.0f;
        [categoryLabel setTitle:@"" forState:UIControlStateNormal];
        
        UIButton *categoryDelete = (UIButton *)[self viewWithTag:(i+1 + 10)];
        [categoryDelete removeFromSuperview];
        
    }
    
    for (int i = 0; i<cateArray.count; i++) {
        categoryButton *categoryLabel = (categoryButton *)[self viewWithTag:(i+1)];
        [categoryLabel addTarget:self.categoryDelegate action:@selector(categoryTap:) forControlEvents:UIControlEventTouchUpInside];
        
        categoryObject *oneCategory =(categoryObject *)cateArray[i];
        categoryLabel.categoryColor = [UIColor colorWithRed:oneCategory.color_R/255.0f green:oneCategory.color_G/255.0f blue:oneCategory.color_B/255.0f alpha:1.0f];
        categoryLabel.layer.borderWidth = 0.8f;
        [categoryLabel setTitle:oneCategory.categoryName forState:UIControlStateNormal];
        
        if ([oneCategory.categoryName isEqualToString:NSLocalizedString(@"+ 新主题",nil)]) {
            UIFontDescriptor *categoryFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                        @{UIFontDescriptorFamilyAttribute: @"Avenir Next",
                                                          UIFontDescriptorNameAttribute:@"AvenirNext-DemiBold",
                                                          UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: (int)(SCREEN_WIDTH/27)]
                                                          }];
            
            [categoryLabel.titleLabel setFont:[UIFont fontWithDescriptor:categoryFontDescriptor size:0.0]];
            categoryLabel.layer.borderWidth = 1.2f;

        }
        //clear color when reload data
//        [categoryLabel categoryNormalColor];
        
        //for delete button
        UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(categoryLabel.frame.origin.x-5, categoryLabel.frame.origin.y-5, 13, 13)];
        [deleteBtn setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
        deleteBtn.tag = 10 + 1 + i;
        [deleteBtn addTarget:self.categoryDelegate action:@selector(categoryDeleteTap:) forControlEvents:UIControlEventTouchUpInside];

        
        [deleteBtn setHidden:YES];
        [deleteBtn setImageEdgeInsets:UIEdgeInsetsMake(-2, -2, -2, -2)];
        deleteBtn.layer.borderWidth = 2.0f;
        deleteBtn.layer.borderColor = [UIColor colorWithRed:218/255.0f green:218/255.0f blue:218/255.0f alpha:1.0f].CGColor;
        deleteBtn.layer.cornerRadius = deleteBtn.frame.size.width/2;
        deleteBtn.layer.masksToBounds = YES;
        deleteBtn.layer.shadowColor = [UIColor colorWithRed:.23 green:.23 blue:.23 alpha:1.0f].CGColor;
        deleteBtn.layer.shadowOpacity = 1.0;
        deleteBtn.layer.shadowRadius = 1.5f;
        deleteBtn.layer.shadowOffset = CGSizeMake(.5f, 1.2f);

        [self.contentView addSubview:deleteBtn];
        [self.contentView bringSubviewToFront:deleteBtn];
        
    }

}

-(void)showDeleteButton
{
    for (int i = 0; i<4; i++) {
        UIButton *deleteBtn = [(UIButton *)self viewWithTag:(10 + 1 + i)];

        if (deleteBtn) {
            [deleteBtn setHidden:NO];
        }
    }

}

-(void)removeDeleteButton
{
    for (int i = 0; i<4; i++) {
        UIButton *deleteBtn = [(UIButton *)self viewWithTag:(10 + 1 + i)];
        
        if (deleteBtn) {
            [deleteBtn setHidden:YES];
        }
    }
}



@end
