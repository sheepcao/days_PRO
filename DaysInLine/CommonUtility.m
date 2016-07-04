//
//  CommonUtility.m
//  ActiveWorld
//
//  Created by Eric Cao on 10/30/14.
//  Copyright (c) 2014 Eric Cao/Mady Kou. All rights reserved.
//



#import "CommonUtility.h"
#import "itemObj.h"
#import "UIImageView+AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import "MBProgressHUD.h"
#import "categoryObject.h"



@implementation CommonUtility

@synthesize myAudioPlayer;
@synthesize db;
@synthesize myTimer;

+(CommonUtility *)sharedCommonUtility
{
    static CommonUtility *singleton;
    static dispatch_once_t token;
    dispatch_once(&token,^{
        singleton = [[CommonUtility alloc] init];
    });
    return singleton;
}

-(id)init
{
    self = [super init];
    if (self) {
        //        NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *dbPath = [self dbPath];
        NSLog(@"dbPath:%@",dbPath);
        db = [FMDatabase databaseWithPath:dbPath];
    }
    return self;
}

-(NSString *)dbPath
{
    NSString *docsPath = [self docsPath];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"infoNew.sqlite"];
    return dbPath;
}
-(NSString *)docsPath
{
    NSURL *storeURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.sheepcao.DaysInLine"];
    NSString *docsPath = [storeURL path];
    
    return docsPath;
}
-(NSString *)voicePathWithRecorderID:(int)recorderID
{
    NSURL *storeURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.sheepcao.DaysInLine"];
    NSString *voicePath = [[storeURL path] stringByAppendingPathComponent:[NSString stringWithFormat:@"message%d.caf",recorderID]];
    
    return voicePath;
}



-(NSDateFormatter *)dateFormatter
{
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    _dateFormatter.calendar = cal;
    return _dateFormatter;
}

-(NSString *)firstMonthDate
{
    //    NSCalendar *cal = [NSCalendar currentCalendar];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate *date = [NSDate date];
    
    NSDateComponents * currentDateComponents = [cal components: kCFCalendarUnitYear | NSCalendarUnitMonth fromDate: date];
    NSDate * startOfMonth = [cal dateFromComponents: currentDateComponents];
    //    NSDate * endOfLastMonth = [startOfMonth dateByAddingTimeInterval: -1]; // One second before the start of this month
    
    return    [self stringFromDate:startOfMonth];
}

-(NSString *)lastMonthDate
{
    //    NSCalendar *cal = [NSCalendar currentCalendar];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate * plusOneMonthDate = [self dateByAddingMonths: 1];
    NSDateComponents * plusOneMonthDateComponents = [cal components: kCFCalendarUnitYear | NSCalendarUnitMonth fromDate: plusOneMonthDate];
    NSDate * endOfMonth = [[cal dateFromComponents: plusOneMonthDateComponents] dateByAddingTimeInterval: -1]; // next month
    
    return [self stringFromDate:endOfMonth];
}
-(NSString *)firstNextMonthDate
{
    //    NSCalendar *cal = [NSCalendar currentCalendar];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate * plusOneMonthDate = [self dateByAddingMonths: 1];
    NSDateComponents * plusOneMonthDateComponents = [cal components: kCFCalendarUnitYear | NSCalendarUnitMonth fromDate: plusOneMonthDate];
    NSDate * endOfMonth = [cal dateFromComponents: plusOneMonthDateComponents]; // next month
    
    return [self stringFromDate:endOfMonth];
}
//-(NSString *)oneDayBeforeDate:(NSString *)date
//{
//    NSDate *srcDate = [self dateFromString:date];
//    NSDate * oneDayBefor = [srcDate dateByAddingTimeInterval: -1]; // One second before the start of this month
//    return [self stringFromDate:oneDayBefor];
//
//}
//-(NSString *)oneDayAfterDate:(NSString *)date
//{
//    NSDate *srcDate = [self dateFromString:date];
//    NSDate * oneDayBefor = [srcDate dateByAddingTimeInterval: -1]; // One second before the start of this month
//    return [self stringFromDate:oneDayBefor];
//
//}
- (NSDate *) dateByAddingMonths: (NSInteger) monthsToAdd
{
    //    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSCalendar *calendar = [[NSCalendar alloc]
                            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [NSDate date];
    
    NSDateComponents * months = [[NSDateComponents alloc] init];
    [months setMonth: monthsToAdd];
    
    return [calendar dateByAddingComponents: months toDate: date options: 0];
}
- (NSString *) dateByAddingDays: (NSString *)srcDate andDaysToAdd:(NSInteger) daysToAdd
{
    //    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSCalendar *calendar = [[NSCalendar alloc]
                            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *day = [self dateFromString:srcDate];
    
    NSDateComponents * days = [[NSDateComponents alloc] init];
    [days setDay: daysToAdd];
    NSDate *dstDate = [calendar dateByAddingComponents: days toDate: day options: 0];
    return [self stringFromDate:dstDate];
}

- (NSString *) dateByAddingDate: (NSDate *)srcDate andDaysToAdd:(NSInteger) daysToAdd
{
    //    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSCalendar *calendar = [[NSCalendar alloc]
                            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents * days = [[NSDateComponents alloc] init];
    [days setDay: daysToAdd];
    NSDate *dstDate = [calendar dateByAddingComponents: days toDate: srcDate options: 0];
    return [self stringFromDate:dstDate];
}

- (NSString *) timeByAddingMinutes: (NSString *)srcTime andMinsToAdd:(NSInteger) minsToAdd
{
    
    NSDate *day = [self timeFromString:srcTime];
    
    NSDate *plusHour = [day dateByAddingTimeInterval:minsToAdd * 60.0f];
    return [self stringFromTime:plusHour];
    
}
-(NSString *)todayDate
{
    //    NSCalendar *cal = [NSCalendar currentCalendar];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [cal components:(kCFCalendarUnitYear | NSCalendarUnitMonth | kCFCalendarUnitDay)
                                     fromDate:date];
    
    NSDate *today = [cal dateFromComponents:comps];
    return [self stringFromDate:today];
}

-(NSString *)timeNow
{
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitMinute | NSCalendarUnitHour |NSCalendarUnitSecond)
                                     fromDate:date];
    
    NSDate *now = [cal dateFromComponents:comps];
    return [self stringFromTime:now];
}

-(NSString *)timeNowFull
{
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitMinute | NSCalendarUnitHour |NSCalendarUnitSecond)
                                     fromDate:date];
    
    NSDate *now = [cal dateFromComponents:comps];
    return [self fullStringFromTime:now];
}

- (NSString *)fullStringFromTime:(NSDate *)time{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    dateFormatter.calendar = cal;
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *destDateString = [dateFormatter stringFromDate:time];
    return destDateString;
}

-(NSDate *)timeNowDate
{
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitMinute | NSCalendarUnitHour |NSCalendarUnitSecond)
                                     fromDate:date];
    
    NSDate *now = [cal dateFromComponents:comps];
    return now;
}

-(NSString *)tomorrowDate
{
    //    NSCalendar *cal = [NSCalendar currentCalendar];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [cal components:(kCFCalendarUnitYear | NSCalendarUnitMonth | kCFCalendarUnitDay)
                                     fromDate:date];
    
    NSDate *today = [cal dateFromComponents:comps];
    NSDate *tomorrow = [today dateByAddingTimeInterval:(24*60*60)];
    
    return [self stringFromDate:tomorrow];
}
-(NSString *)yesterdayDate
{
    //    NSCalendar *cal = [NSCalendar currentCalendar];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [cal components:(kCFCalendarUnitYear | NSCalendarUnitMonth | kCFCalendarUnitDay)
                                     fromDate:date];
    
    NSDate *today = [cal dateFromComponents:comps];
    NSDate *yesterday = [today dateByAddingTimeInterval:(-24*60*60)];
    
    return [self stringFromDate:yesterday];
}

-(NSDate *)dateFromString:(NSString *)pstrDate
{
    NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    df1.calendar = cal;
    [df1 setDateFormat:@"yyyy-MM-dd"];
    NSDate *dtPostDate = [df1 dateFromString:pstrDate];
    return dtPostDate;
}

-(NSDate *)timeFromString:(NSString *)pstrTime
{
    NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    df1.calendar = cal;
    [df1 setDateFormat:@"HH:mm"];
    NSDate *dtPostDate = [df1 dateFromString:pstrTime];
    return dtPostDate;
}

-(NSDate *)fullTimeFromString:(NSString *)pstrTime
{
    NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    df1.calendar = cal;
    [df1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dtPostDate = [df1 dateFromString:pstrTime];
    return dtPostDate;
}

- (NSString *)stringFromDate:(NSDate *)date{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    dateFormatter.calendar = cal;
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}

- (NSString *)stringFromTime:(NSDate *)time{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    dateFormatter.calendar = cal;
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *destDateString = [dateFormatter stringFromDate:time];
    return destDateString;
}

-(NSString *)weekStartDayOf:(NSDate *)date;
{
    NSCalendar *gregorian = [[NSCalendar alloc]  initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *components = [gregorian components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    
    NSInteger dayofweek = [[gregorian components:NSCalendarUnitWeekday fromDate:date] weekday];// this will give you current day of week
    
    [components setDay:([components day] - ((dayofweek) - 1))];// for beginning of the week.
    
    NSDate *beginningOfWeek = [gregorian dateFromComponents:components];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.calendar = gregorian;
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString= [dateFormat stringFromDate:beginningOfWeek];
    NSLog(@"StartDate:%@",dateString);
    
    return dateString;
    
}
-(NSString *)weekEndDayOf:(NSDate *)date;
{
    NSCalendar *gregorianEnd = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *componentsEnd = [gregorianEnd components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    
    NSInteger Enddayofweek = [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:date] weekday];// this will give you current day of week
    
    [componentsEnd setDay:([componentsEnd day]+(7-Enddayofweek))];// for end day of the week
    
    NSDate *EndOfWeek = [gregorianEnd dateFromComponents:componentsEnd];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.calendar = gregorianEnd;
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *dateEndPrev = [dateFormat stringFromDate:EndOfWeek];
    NSLog(@"EndDate:%@",dateEndPrev);
    
    return dateEndPrev;
}

-(NSInteger)weekSequence:(NSDate *)date
{
    NSCalendar *gregorian = [[NSCalendar alloc]  initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //每周的第一天从星期一开始
    [gregorian setFirstWeekday:2];
    NSDateComponents *comps = [gregorian components: NSCalendarUnitWeekOfYear fromDate:date];
    return comps.weekOfYear ;
}




- (NSInteger )timeIntervalFromLastTime:(NSDate *)lastTime ToCurrentTime:(NSDate *)currentTime
{
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    //上次时间
    NSDate *lastDate = [lastTime dateByAddingTimeInterval:[timeZone secondsFromGMTForDate:lastTime]];
    //当前时间
    NSDate *currentDate = [currentTime dateByAddingTimeInterval:[timeZone secondsFromGMTForDate:currentTime]];
    //时间间隔
    NSInteger intevalTime = [currentDate timeIntervalSinceReferenceDate] - [lastDate timeIntervalSinceReferenceDate];
    
    return intevalTime;
}

-(NSDate *)dateFromChinese:(NSString *)dateCN
{
    NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    df1.calendar = cal;
    [df1 setDateFormat:@"yyyy年MM月dd日"];
    NSDate *dtPostDate = [df1 dateFromString:dateCN];
    NSLog(@"date:``````````````````%@",dtPostDate);
    return dtPostDate;
}

-(NSString *)chineseForNow
{
    NSDate *date = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    dateFormatter.calendar = cal;
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    NSLog(@"dateString-----------------%@",destDateString);
    return destDateString;
}

+ (BOOL)isSystemLangChinese
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLang = [languages objectAtIndex:0];
    if([self myContainsStringFrom:currentLang forSubstring:@"zh-"])
    {
        return YES;
    }else
    {
        return NO;
    }
    
    //    if([currentLang compare:@"zh-Hans" options:NSCaseInsensitiveSearch]==NSOrderedSame || [currentLang compare:@"zh-Hant" options:NSCaseInsensitiveSearch]==NSOrderedSame)
    //    {
    //        return YES;
    //    }else
    //    {
    //        return NO;
    //    }
}

+(void)tapSound
{
    SystemSoundID soundTap;
    
    CFBundleRef CNbundle=CFBundleGetMainBundle();
    
    CFURLRef soundfileurl=CFBundleCopyResourceURL(CNbundle,(__bridge CFStringRef)@"tapSound",CFSTR("wav"),NULL);
    //创建system sound 对象
    AudioServicesCreateSystemSoundID(soundfileurl, &soundTap);
    AudioServicesPlaySystemSound(soundTap);
}

+(BOOL)isSystemVersionLessThan7{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        return YES;
    } else {
        return NO;
    }
}

+(void)tapSound:(NSString *)name withType:(NSString *)type
{
    if ( [[[NSUserDefaults standardUserDefaults] objectForKey:@"SoundSwitch"] isEqualToString:@"off"]) {
        return;
    }
    
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:name ofType:type];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath ];
    [CommonUtility sharedCommonUtility].myAudioPlayer= [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    [CommonUtility sharedCommonUtility].myAudioPlayer.volume = 1.0f;
    [[CommonUtility sharedCommonUtility].myAudioPlayer play];
    
}

+ (BOOL)myContainsStringFrom:(NSString*)str forSubstring:(NSString*)other{
    NSRange range = [str rangeOfString:other];
    return range.length != 0;
}


-(UIColor *)categoryColor:(NSString *)categoryName
{
    UIColor *color = [UIColor colorWithRed:112/255.0f green:190/255.0f blue:169/255.0f alpha:1.0f];
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"addNewItem/Could not open db.");
        return color;
    }
    
    FMResultSet *rs = [db executeQuery:@"select * from CATEGORYINFO where category_name = ?",categoryName];
    while ([rs next]) {
        
        double color_R  = [rs doubleForColumn:@"color_R"];
        double color_G = [rs doubleForColumn:@"color_G"];
        double color_B = [rs doubleForColumn:@"color_B"];
        
        color = [UIColor colorWithRed:color_R/255.0f green:color_G/255.0f blue:color_B/255.0f alpha:1.0f ];
    }
    [db close];
    
    return color;
}

- (void)httpGetUrlNoToken:(NSString *)url
                   params:(NSDictionary *)paramsDict
                  success:(void (^)(NSDictionary *))success
                  failure:(void (^)(NSError *))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 12.0f;
    manager.responseSerializer.acceptableContentTypes =[NSSet setWithObject:@"application/json"];
    [manager.requestSerializer  setValue: @"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    
    [manager POST:url parameters:paramsDict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)httpGetUrlTEXT:(NSString *)url
                params:(NSDictionary *)paramsDict
               success:(void (^)(id))success
               failure:(void (^)(NSError *))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 12.0f;
    manager.responseSerializer.acceptableContentTypes =[NSSet setWithObject:@"application/json"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //    [manager.requestSerializer  setValue: @"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    
    [manager POST:url parameters:paramsDict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}


#pragma mark constellation info

-(void)fetchConstellation:(NSString *)constellation ForView:(LuckyLabel *)textLabel
{
    
    
    NSDate *dateNow = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc]  initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:dateNow];
    NSInteger dayofweek = [[gregorian components:NSCalendarUnitWeekday fromDate:dateNow] weekday];
    
    [components setDay:([components day] - ((dayofweek) - 1))];// for beginning of the week.
    
    NSDate *beginningOfWeek = [gregorian dateFromComponents:components];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.calendar = gregorian;
    [dateFormat setDateFormat:@"yyyy年MM月dd日"];
    NSString *dateString= [dateFormat stringFromDate:beginningOfWeek];
    
    if (![db open]) {
        NSLog(@"Could not open db.");
        [textLabel makeText:@"设置星座，随时掌握财运 >"];
        return ;
    }
    
    NSString *selectLuckExist = [NSString stringWithFormat:@"select * from MONEYLUCK where constellation = '%@' order by start_date desc LIMIT 1",constellation];
    
    
    FMResultSet *rs = [db executeQuery:selectLuckExist];
    if ([rs next]) {
        NSString *luckWork = [rs stringForColumn:@"work"];
        NSString *luckLife = [rs stringForColumn:@"life"];
        
        [db close];
        [textLabel makeText:[NSString stringWithFormat:@"工作:\t%@\n\n生活:\t%@",luckWork,luckLife]];
    }else
    {
        [db close];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:textLabel animated:YES];
        
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.dimBackground = YES;
        
        NSDictionary *parameters = @{@"tag": @"fetch_luckinfo",@"start_date":dateString};
        
        [self httpGetUrlNoToken:constellationService params:parameters success:^(NSDictionary *success){
            
            if ([success objectForKey:@"success"] == 0) {
                [textLabel makeText:@"设置星座，随时掌握财运 >"];
            }
            
            NSArray *nameArray = [success objectForKey:@"name"];
            NSArray *lifeArray = [success objectForKey:@"life"];
            NSArray *workArray = [success objectForKey:@"work"];
            NSString *startDate = [success objectForKey:@"start_date"][0];
            NSString *week = [success objectForKey:@"week"][0];
            
            NSLog(@"%@",startDate);
            NSLog(@"%@",nameArray[0]);
            NSLog(@"%@",lifeArray[0]);
            NSLog(@"%@",week);
            if (![db open]) {
                NSLog(@"Could not open db.");
                [textLabel makeText:@"设置星座，随时掌握财运 >"];
                return ;
            }
            for (int i = 0; i<nameArray.count; i++) {
                BOOL sql = [db executeUpdate:@"insert into MONEYLUCK (constellation,life,work,start_date,week_sequence) values (?,?,?,?,?)",nameArray[i],lifeArray[i],workArray[i],startDate,week];
                if (!sql) {
                    NSLog(@"ERROR: %d - %@", db.lastErrorCode, db.lastErrorMessage);
                }
            }
            
            NSString *selectLuckExist = [NSString stringWithFormat:@"select * from MONEYLUCK where start_date = '%@' and constellation = '%@'",dateString,constellation];
            FMResultSet *rs = [db executeQuery:selectLuckExist];
            if ([rs next]) {
                NSString *luckWork = [rs stringForColumn:@"work"];
                NSString *luckLife = [rs stringForColumn:@"life"];
                
                [db close];
                [textLabel makeText:[NSString stringWithFormat:@"工作:\t%@\n\n生活:\t%@",luckWork,luckLife]];
            }
            
            [hud hide:YES];
            
        } failure:^(NSError * failure){
            NSLog(@"%@",failure);
            
            NSString *selectLuckLast = [NSString stringWithFormat:@"select * from MONEYLUCK where constellation = '%@' order by start_date desc LIMIT 1",constellation];
            FMResultSet *rs = [db executeQuery:selectLuckLast];
            if ([rs next]) {
                NSString *luckWork = [rs stringForColumn:@"work"];
                NSString *luckLife = [rs stringForColumn:@"life"];
                [textLabel makeText:[NSString stringWithFormat:@"工作:\t%@\n\n生活:\t%@",luckWork,luckLife]];
            }else
            {
                [textLabel makeText:[NSString stringWithFormat:@"%@:\n \t网络似乎不太给力 =.=!",constellation]];
            }
            
            [db close];
            [hud hide:YES];
            
        }];
        
    }
    
}


-(void)shimmerRegisterButton:(UIView *)registerButtonView{
    registerButtonView.userInteractionEnabled=YES;
    UIImageView *sheenImageView = (UIImageView *)[registerButtonView viewWithTag:11];
    if (!sheenImageView) {
        sheenImageView= [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 86, registerButtonView.frame.size.height)];
        [sheenImageView setImage:[UIImage imageNamed:@"glow.png"]];
        sheenImageView.layer.masksToBounds = YES;
        sheenImageView.tag = 11;
        [sheenImageView setAlpha:0.0];
        [registerButtonView addSubview:sheenImageView];
        [registerButtonView setNeedsDisplay];
    }else
    {
        [sheenImageView setFrame:CGRectMake(0, 0, 86, registerButtonView.frame.size.height)];
    }
    
    [UIView animateKeyframesWithDuration:3.5 delay:1.5 options:UIViewKeyframeAnimationOptionCalculationModeLinear  | UIViewKeyframeAnimationOptionRepeat animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.01 animations:^{
            sheenImageView.layer.cornerRadius = 0;
            [sheenImageView setAlpha:1.0];
        }];
        [UIView addKeyframeWithRelativeStartTime:0.01 relativeDuration:0.15 animations:^{
            sheenImageView.layer.cornerRadius = 0;
            [sheenImageView setFrame:CGRectMake(registerButtonView.frame.size.width-86, 0, 86,registerButtonView.frame.size.height)];
        }];
        [UIView addKeyframeWithRelativeStartTime:0.15 relativeDuration:0.16 animations:^{
            sheenImageView.layer.cornerRadius = sheenImageView.frame.size.height/2;
            [sheenImageView setAlpha:0.0];
            [sheenImageView setFrame:CGRectMake(registerButtonView.frame.size.width-86, 0, 86,registerButtonView.frame.size.height)];
        }];
    } completion:^(BOOL finished) {
        
    }];
}

- (BOOL) validateEmail: (NSString *) candidate {
    if ([[candidate stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""])
    {
        return NO;
    }
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

- (BOOL) validatePassword: (NSString *) candidate {
    if ([candidate isEqualToString:@""])
    {
        return NO;
    }
    NSString *emailRegex = @"^[0-9A-Za-z]{6,20}$";
    NSPredicate *passwordTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [passwordTest evaluateWithObject:candidate];
}


-(NSMutableArray *)prepareCategoryDataForWork:(BOOL)isWork
{
    NSMutableArray *categoryArray = [[NSMutableArray alloc] init];
    
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"addNewItem/Could not open db.");
        return nil;
    }
    NSString *sqlCommand;
    
    sqlCommand = [NSString stringWithFormat:@"select * from CATEGORYINFO where is_deleted = 0 order by category_id"];
    
    
    FMResultSet *rs = [db executeQuery:sqlCommand];
    while ([rs next]) {
        categoryObject *oneCategory = [[categoryObject alloc] init];
        
        oneCategory.categoryName = [rs stringForColumn:@"category_name"];
        oneCategory.color_R  = [rs doubleForColumn:@"color_R"];
        oneCategory.color_G = [rs doubleForColumn:@"color_G"];
        oneCategory.color_B = [rs doubleForColumn:@"color_B"];
        
        if (isWork) {
            if ([rs intForColumn:@"category_type"] == 0) {
                [categoryArray addObject:oneCategory];
            }
        }else
        {
            if ([rs intForColumn:@"category_type"] == 1) {
                [categoryArray addObject:oneCategory];
            }
        }
    }
    
    [db close];
    
    
    categoryObject *oneCategory = [[categoryObject alloc] init];
    
    oneCategory.categoryName = NSLocalizedString(@"+ 新主题",nil);
    oneCategory.color_R  =245;
    oneCategory.color_G =245;
    oneCategory.color_B = 245;
    
    [categoryArray addObject:oneCategory];
    
    return categoryArray;
    
}

-(CGFloat)timeToDouble:(NSString *)time
{
    CGFloat destTime= 0.0f;
    
    NSArray *timeParts = [time componentsSeparatedByString:@"  "];
    if (timeParts.count>1) {
        destTime +=24 * 60;
        NSArray *timePart = [timeParts[1] componentsSeparatedByString:@":"];
        double hour_0 = [timePart[0] doubleValue];
        double minite_0 = [timePart[1] doubleValue];
        double timeTemp = hour_0*60 + minite_0;
        destTime += timeTemp;
    }else
    {
        NSArray *timePart = [time componentsSeparatedByString:@":"];
        double hour_0 = [timePart[0] doubleValue];
        double minite_0 = [timePart[1] doubleValue];
        double timeTemp = hour_0*60 + minite_0;
        destTime += timeTemp;
        
    }
    
    return destTime;
}

-(NSString *)doubleToTime:(int)timeNumber
{
    NSString *destTimeString;
    
    int hour = timeNumber/60;
    int minute = timeNumber%60;
    int  dayOffsite = hour/24;
    if (hour >23) {
        hour %= 24;
    }
    
    if (dayOffsite == 0) {
        destTimeString = [NSString stringWithFormat:@"%02d:%02d",hour,minute];
    }else
    {
        destTimeString = [NSString stringWithFormat:@"+%d  %02d:%02d",dayOffsite,hour,minute];
    }
    
    return destTimeString;
    
}

-(NSString *)timeInLine:(int)timeNumber
{
    NSString *destTimeString;
    
    int hour = timeNumber/60;
    int minute = timeNumber%60;
    int  dayOffsite = hour/24;
    if (hour >23) {
        hour %= 24;
    }
    
    if (dayOffsite == 0) {
        destTimeString = [NSString stringWithFormat:@"%02d:%02d",hour,minute];
    }else
    {
        destTimeString = [NSString stringWithFormat:@"%02d:%02d +%d天",hour,minute,dayOffsite];
    }
    
    return destTimeString;
    
}

-(void)createTimer
{
    dispatch_queue_t  queue = dispatch_queue_create("com.sheepcao.app.timer", 0);
    myTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(myTimer, dispatch_walltime(DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC), 1ull * NSEC_PER_SEC, 1ull * NSEC_PER_SEC);
}

-(NSArray *)weekDays
{
    return  @[NSLocalizedString(@"周日",nil),NSLocalizedString(@"周一",nil),NSLocalizedString(@"周二",nil),NSLocalizedString(@"周三",nil),NSLocalizedString(@"周四",nil),NSLocalizedString(@"周五",nil),NSLocalizedString(@"周六",nil)];
}

//
//-(BOOL)addADWithY:(CGFloat)SpaceBottom InView:(UIView *)view OfRootVC:(UIViewController *)rootVC
//{
//    GADBannerView *bannerView = [[GADBannerView alloc] init];
//    GADRequest *request = [GADRequest request];
//    bannerView.frame = CGRectMake(0, SCREEN_HEIGHT -SCREEN_WIDTH *50/320 - SpaceBottom, SCREEN_WIDTH, SCREEN_WIDTH *50/320);
//    NSString *removeADBought = [[NSUserDefaults standardUserDefaults] objectForKey:REMOVEAD];
//    if (![removeADBought isEqualToString:@"yes"]) {
//        [view addSubview:bannerView];
//        
//        if (!self.bannerViews) {
//            self.bannerViews = [[NSMutableArray alloc] initWithCapacity:8];
//        }
//        
//        [self.bannerViews addObject:bannerView];
//        
//        
//        bannerView.adUnitID = ADMOB_ID;
//        bannerView.rootViewController = rootVC;
//        [bannerView loadRequest:request];
//        return YES;
//    }
//    return NO;
//}
//
//-(void)removeADs
//{
//    for (GADBannerView *bannerView in self.bannerViews) {
//        [bannerView removeFromSuperview];
//    }
//}
//
@end
