//
//  checkEventViewController.h
//  DaysInLine
//
//  Created by Eric Cao on 6/2/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "baseViewController.h"
#import "itemObj.h"

@interface checkEventViewController : baseViewController

@property (nonatomic,strong) itemObj *currentItem;
@property (nonatomic,strong) NSString *itemStartTime;
@property (nonatomic,strong) NSString *itemEndTime;


@end
