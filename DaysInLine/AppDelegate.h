//
//  AppDelegate.h
//  DaysInLine
//
//  Created by Eric Cao on 5/27/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) BOOL isActive;

-(void)judgeTimeFrame;

@end

