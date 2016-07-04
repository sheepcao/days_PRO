//
//  goalDetailViewController.h
//  DaysInLine
//
//  Created by Eric Cao on 6/7/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "baseViewController.h"

@interface goalDetailViewController : baseViewController
@property BOOL isEditing;
@property (nonatomic,strong) NSNumber *currentIGoalID;
@property int goalType;
@property (nonatomic,strong) NSString *category;
@property BOOL isByTime;
@property (nonatomic,strong)NSString *totalNum;
@property (nonatomic,strong)NSString *remindTime;
@property (nonatomic,strong)NSArray *remindDays;

@end
