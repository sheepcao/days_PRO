//
//  photoCell.m
//  DaysInLine
//
//  Created by Eric Cao on 6/1/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "photoCell.h"
#import "global.h"

@implementation photoCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.photoView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 20, 20)];
        self.photoView.layer.borderColor = normalColor.CGColor;
        self.photoView.layer.borderWidth = 0.85;
        self.photoView.layer.masksToBounds = YES;
        [self addSubview:self.photoView];
    }
    return  self;
}

-(void)configPhotoWitchRect:(CGRect)rect andPhoto:(UIImage *)image
{
    [self.photoView setFrame:rect];
    self.photoView.layer.cornerRadius = rect.size.height *0.17;

    [self.photoView setImage:image];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
