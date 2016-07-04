//
//  CommonUtility.h
//  ActiveWorld
//
//  Created by Eric Cao on 10/30/14.
//  Copyright (c) 2014 Eric Cao/Mady Kou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "global.h"
#import "LuckyLabel.h"

@interface CommonUtility : NSObject
{
    AVAudioPlayer *myAudioPlayer;
}

@property (nonatomic, strong) AVAudioPlayer *myAudioPlayer;
@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) NSDateFormatter *dateFormatter;
@property (nonatomic,strong) NSString *dbPath;
@property (nonatomic,strong) NSString *docsPath;
@property (nonatomic,strong) dispatch_source_t myTimer;
@property (nonatomic,strong) NSString *myGoingTimerTitle;
@property (nonatomic,strong) NSArray *weekDays;
@property (nonatomic,strong) NSMutableArray *bannerViews;


+ (CommonUtility *)sharedCommonUtility;
+ (BOOL)isSystemLangChinese;
+ (void)tapSound;
+ (void)tapSound:(NSString *)name withType:(NSString *)type;
+ (BOOL)isSystemVersionLessThan7;
+ (BOOL)myContainsStringFrom:(NSString*)str forSubstring:(NSString*)other;

-(NSString *)voicePathWithRecorderID:(int)recorderID;

-(NSDate *)timeNowDate;
-(NSString *)timeNow;
-(NSString *)timeNowFull;

-(NSString *)todayDate;
-(NSString *)tomorrowDate;
-(NSString *)yesterdayDate;
-(NSString *)firstMonthDate;
-(NSString *)lastMonthDate;
-(NSString *)firstNextMonthDate;
- (NSString *) dateByAddingDays: (NSString *)srcDate andDaysToAdd:(NSInteger) daysToAdd;
- (NSString *) timeByAddingMinutes: (NSString *)srcTime andMinsToAdd:(NSInteger) minsToAdd;
- (NSString *) dateByAddingDate: (NSDate *)srcDate andDaysToAdd:(NSInteger) daysToAdd;

- (NSInteger )timeIntervalFromLastTime:(NSDate *)lastTime ToCurrentTime:(NSDate *)currentTime;


-(UIColor *)categoryColor:(NSString *)categoryName;

-(NSDate *)dateFromString:(NSString *)pstrDate;
-(NSDate *)timeFromString:(NSString *)pstrTime;
-(NSDate *)fullTimeFromString:(NSString *)pstrTime;

- (NSString *)stringFromDate:(NSDate *)date;
- (NSString *)stringFromTime:(NSDate *)time;

-(NSString *)weekEndDayOf:(NSDate *)date;
-(NSString *)weekStartDayOf:(NSDate *)date;
-(NSInteger)weekSequence:(NSDate *)date;


- (void)httpGetUrlNoToken:(NSString *)url
                   params:(NSDictionary *)paramsDict
                  success:(void(^)(NSDictionary *))success
                  failure:(void(^)(NSError *))failure;

- (void)httpGetUrlTEXT:(NSString *)url
                params:(NSDictionary *)paramsDict
               success:(void (^)(id))success
               failure:(void (^)(NSError *))failure;

-(void)fetchConstellation:(NSString *)constellation ForView:(LuckyLabel *)textLabel;
-(void)shimmerRegisterButton:(UIView *)registerButtonView;
- (BOOL) validateEmail: (NSString *) candidate ;
- (BOOL) validatePassword: (NSString *) candidate ;

-(NSMutableArray *)prepareCategoryDataForWork:(BOOL)isWork;

-(CGFloat)timeToDouble:(NSString *)time;
-(NSString *)doubleToTime:(int)timeNumber;
-(NSString *)timeInLine:(int)timeNumber;
-(void)createTimer;

//-(BOOL)addADWithY:(CGFloat)SpaceBottom InView:(UIView *)view OfRootVC:(UIViewController *)rootVC;
//-(void)removeADs;

@end
