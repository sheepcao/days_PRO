//
//  itemDetailViewController.h
//  simpleFinance
//
//  Created by Eric Cao on 4/23/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "baseViewController.h"
@protocol reloadDataDelegate <NSObject>

-(void)refreshData;
@end


@interface itemDetailViewController : baseViewController
@property (nonatomic,weak)  id <reloadDataDelegate> refreshDelegate;

@property (nonatomic,strong) NSNumber *currentItemID;
@property int itemType;
@property (nonatomic,strong) NSString *category;
@property (nonatomic,strong) NSString *itemDescription;
@property (nonatomic,strong) NSString *itemStartTime;
@property (nonatomic,strong) NSString *itemEndTime;
@property (nonatomic,strong) NSString *targetDate;
@property (nonatomic,strong) NSString *soundName;
@property (nonatomic,strong) NSString *photoNames;


@property BOOL isEditing;
@property NSInteger relatedGoalID;
@property BOOL isRelatedGoalByTime;

@end
