//
//  photoCell.h
//  DaysInLine
//
//  Created by Eric Cao on 6/1/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface photoCell : UITableViewCell
@property (nonatomic,strong) UIImageView *photoView;
-(void)configPhotoWitchRect:(CGRect)rect andPhoto:(UIImage *)image;
@end
