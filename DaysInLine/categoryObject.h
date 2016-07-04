//
//  categoryObject.h
//  simpleFinance
//
//  Created by Eric Cao on 4/19/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface categoryObject : NSObject
@property (nonatomic) double color_R;
@property double color_G;
@property double color_B;
@property (strong , nonatomic) NSString *categoryName;
@end
