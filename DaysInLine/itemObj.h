//
//  GoalObj.h
//  AnyGoals
//
//  Created by Eric Cao on 3/16/15.
//  Copyright (c) 2015 Eric Cao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface itemObj : NSObject

@property (strong , nonatomic) NSNumber *itemID;
@property (strong , nonatomic) NSString *itemCategory;
@property  int itemType;
@property (strong , nonatomic) NSString *itemDescription;
@property (strong , nonatomic) NSString *createdTime;
@property (strong , nonatomic) NSString *targetTime;
@property (strong , nonatomic) NSString *photoNames;

@property double startTime;
@property double endTime;


@end

