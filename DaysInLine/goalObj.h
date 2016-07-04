//
//  GoalObj.h
//  AnyGoals
//
//  Created by Eric Cao on 3/16/15.
//  Copyright (c) 2015 Eric Cao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface goalObj : NSObject

@property (strong , nonatomic) NSNumber *goalID;
@property (strong , nonatomic) NSString *goalTheme;
@property (strong , nonatomic) NSString *themeOnly;

@property  int goalType;
@property (strong , nonatomic) NSString *startDate;
@property (strong , nonatomic) NSString *finishDate;
@property (strong , nonatomic) NSString *remindTime;
@property (strong , nonatomic) NSString *remindInterval;
@property  int byTime;  // 1 -- by time , 0 --by count
@property double targetTime;
@property int targetCount;

@property double doneTime;
@property int doneCount;




@end

