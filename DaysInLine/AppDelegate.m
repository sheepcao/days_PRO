//
//  AppDelegate.m
//  DaysInLine
//
//  Created by Eric Cao on 5/27/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "AppDelegate.h"
#import "homeViewController.h"
#import "SideMenuViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "CommonUtility.h"
#import "OpenShareHeader.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
@interface AppDelegate ()

@property (nonatomic,strong) FMDatabase *db;

@end

@implementation AppDelegate
@synthesize db;


- (homeViewController *)demoController {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    homeViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"homeViewController"];
    
    return vc;
}

- (UINavigationController *)navigationController {
    return [[UINavigationController alloc]
            initWithRootViewController:[self demoController]];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    application.applicationIconBadgeNumber = 0;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
    
    NSString *autoSwitchString = [[NSUserDefaults standardUserDefaults] objectForKey:AUTOSWITCH];
    if (!autoSwitchString) {
        [[NSUserDefaults standardUserDefaults] setObject:@"on" forKey:AUTOSWITCH];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    SideMenuViewController *rightMenuViewController = [[SideMenuViewController alloc] init];
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController:[self navigationController]
                                                    leftMenuViewController:nil
                                                    rightMenuViewController:rightMenuViewController];
    container.menuWidth = SCREEN_WIDTH*2/5;
    self.window.rootViewController = container;
    
    [self initDB];
    [self judgeTimeFrame];
    [self configShare];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    if ([CommonUtility isSystemLangChinese]) {
        [self loadLuckInfoFromServer];
    }else
    {
        NSLog(@"不是中文");
    }
    
    [self.window makeKeyAndVisible];
    
    [[CommonUtility sharedCommonUtility] createTimer];
    
    
    return YES;
}


-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    //第二步：添加回调
    if ([OpenShare handleOpenURL:url]) {
        return YES;
    }else if ([CommonUtility myContainsStringFrom:[NSString stringWithFormat:@"%@",url]  forSubstring:@"fb"] )
    {
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:sourceApplication
                                                           annotation:annotation];
    }
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"applicationWillResignActive");
    self.isActive = NO;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self judgeTimeFrame];
    application.applicationIconBadgeNumber = 0;
    
    NSLog(@"applicationWillEnterForeground");
    self.isActive = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
    if ([CommonUtility isSystemLangChinese]) {
        [self loadLuckInfoFromServer];
    }else
    {
        NSLog(@"不是中文");
    }
    
    
}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*)notification{
    
    // 图标上的数字减1
    
    application.applicationIconBadgeNumber = 0;
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(void)initDB
{
    
    
    db = [[CommonUtility sharedCommonUtility] db];
    
    if (![db open]) {
        NSLog(@"Could not open db.");
        return;
    }
    NSString *createCategoryTable = @"CREATE TABLE IF NOT EXISTS CATEGORYINFO (category_id INTEGER PRIMARY KEY AUTOINCREMENT,category_name TEXT,category_type INTEGER,color_R Double,color_G Double,color_B Double, is_deleted INTEGER DEFAULT 0)";
    NSString *createLuckTable = @"CREATE TABLE IF NOT EXISTS MONEYLUCK (luck_id INTEGER PRIMARY KEY AUTOINCREMENT,week_sequence INTEGER,luck_Cn TEXT,luck_En TEXT,start_date TEXT,life TEXT,work TEXT,  constellation TEXT)";
    NSString *createColorTable = @"CREATE TABLE IF NOT EXISTS COLORINFO (color_id INTEGER PRIMARY KEY AUTOINCREMENT,color_R Double,color_G Double,color_B Double, used_count INTEGER)";
    
    NSString *createEvent = @"CREATE TABLE IF NOT EXISTS EVENTS (eventID INTEGER PRIMARY KEY AUTOINCREMENT,TYPE INTEGER,TITLE TEXT,mainText TEXT,income REAL,expend REAL,date Date,startTime REAL,endTime REAL,distance TEXT,label TEXT,remind TEXT,startArea INTEGER,photoDir TEXT)";
    
    NSString *createCollect = @"CREATE TABLE IF NOT EXISTS collection (collectionID INTEGER PRIMARY KEY AUTOINCREMENT,eventID INTEGER)";
    NSString *createPassword = @"CREATE TABLE IF NOT EXISTS passwordVar (varName TEXT PRIMARY KEY,value TEXT)";
    NSString *goalTable = @"CREATE TABLE IF NOT EXISTS GOALS (goal_id INTEGER PRIMARY KEY AUTOINCREMENT,TYPE INTEGER,theme TEXT,byTime INTEGER,target_time REAL,done_time REAL,target_count INTEGER,done_count INTEGER,start_date TEXT,finish_date TEXT,remind_time TEXT,remind_days TEXT,is_completed INTEGER)";
    
    
    [db executeUpdate:createCategoryTable];
    [db executeUpdate:createLuckTable];
    [db executeUpdate:createColorTable];
    [db executeUpdate:createEvent];
    [db executeUpdate:createCollect];
    [db executeUpdate:createPassword];
    [db executeUpdate:goalTable];
    
    
    NSString *selectEVENTSCount = @"select * from EVENTS";
    FMResultSet *rs1 = [db executeQuery:selectEVENTSCount];
    if ([rs1 next]) {
    }else
    {
        FMResultSet *rs2 = [db executeQuery:@"select * from EVENT"];
        while ([rs2 next]) {
            BOOL sql =  [db executeUpdate:@"insert into EVENTS (eventID,TYPE,TITLE,mainText,income,expend,date,startTime,endTime,distance,label,remind,startArea,photoDir) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?)",[NSNumber numberWithInt:[rs2 intForColumnIndex:0]],[NSNumber numberWithInt:[rs2 intForColumnIndex:1]],[rs2 stringForColumnIndex:2],[rs2 stringForColumnIndex:3],[NSNumber numberWithDouble:[rs2 doubleForColumnIndex:4]],[NSNumber numberWithDouble:[rs2 doubleForColumnIndex:5]],[rs2 stringForColumnIndex:6],[NSNumber numberWithDouble:[rs2 doubleForColumnIndex:7]],[NSNumber numberWithDouble:[rs2 doubleForColumnIndex:8]],[rs2 stringForColumnIndex:9],[rs2 stringForColumnIndex:10],[rs2 stringForColumnIndex:11],[NSNumber numberWithInt:[rs2 intForColumnIndex:12]],[rs2 stringForColumnIndex:13]];
            if (!sql) {
                NSLog(@"CATEGORY ERROR: %d - %@", db.lastErrorCode, db.lastErrorMessage);
            }
        }
        
        BOOL sql2 =  [db executeUpdate:@"DROP TABLE EVENT"];
        if (!sql2) {
            NSLog(@"DROP ERROR: %d - %@", db.lastErrorCode, db.lastErrorMessage);
        }
        
    }
    
    
    
    
    //第一次启动，加载默认类别和颜色
    int categoryCount;
    NSString *selectCategoryCount = @"select count (*) from CATEGORYINFO";
    FMResultSet *rs = [db executeQuery:selectCategoryCount];
    if ([rs next]) {
        categoryCount = [rs intForColumnIndex:0];
    }
    if (categoryCount == 0) {
        [self insertDefaultCategoryToDB:db];
    }
    
    int colorCount;
    NSString *selectColorCount = @"select count (*) from COLORINFO";
    FMResultSet *rsColor = [db executeQuery:selectColorCount];
    if ([rsColor next]) {
        colorCount = [rsColor intForColumnIndex:0];
    }
    if (colorCount == 0) {
        [self insertDefaultColorToDB:db];
    }
    
    int goalCount;
    NSString *selectGoalCount = @"select count (*) from GOALS";
    FMResultSet *rsGoal = [db executeQuery:selectGoalCount];
    if ([rsColor next]) {
        goalCount = [rsGoal intForColumnIndex:0];
    }
    if (colorCount == 0) {
        [self insertDefaultGOALSToDB:db];
    }
    
    
    [db close];
}


-(void)judgeTimeFrame
{
    //    NSLog(@"judgeTimeFrame");
    
    NSString *autoSwitchString = [[NSUserDefaults standardUserDefaults] objectForKey:AUTOSWITCH];
    if (![autoSwitchString isEqualToString:@"on"])
    {
        return;
    }
    
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [NSDate date];
    NSInteger hour;
    if (SYSTEM_VERSION_LESS_THAN(iOS8_0)) {
        NSDateComponents *components = [cal components:NSCalendarUnitHour fromDate:date];
        hour = components.hour;
    }else
    {
        hour = [cal component:NSCalendarUnitHour fromDate:date];
    }
    
    if (hour>6 &&hour<18) {
        [[NSUserDefaults standardUserDefaults] setObject:@"白天" forKey:SHOWMODEL];
    }else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"夜间" forKey:SHOWMODEL];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ThemeChanged  object:nil];
    
    
}

-(void)loadLuckInfoFromServer
{
    
    //    NSLog(@"loadLuckInfoFromServer");
    
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
        return;
    }
    
    NSString *selectLuckExist = [NSString stringWithFormat:@"select * from MONEYLUCK where start_date = '%@'",dateString];
    
    FMResultSet *rs = [db executeQuery:selectLuckExist];
    if ([rs next]) {
        //        NSString *luckString = [rs stringForColumn:@"content"];
        //        [[NSUserDefaults standardUserDefaults] setObject:luckString forKey:@"luckString"];
        [db close];
    }else
    {
        [db close];
        
        NSDictionary *parameters = @{@"tag": @"fetch_luckinfo",@"start_date":dateString};
        
        [[CommonUtility sharedCommonUtility] httpGetUrlNoToken:constellationService params:parameters success:^(NSDictionary *success){
            
            if ([success objectForKey:@"success"] == 0) {
                return ;
            }
            
            NSArray *nameArray = [success objectForKey:@"name"];
            NSArray *lifeArray = [success objectForKey:@"life"];
            NSArray *workArray = [success objectForKey:@"work"];
            NSString *startDate = [success objectForKey:@"start_date"][0];
            NSString *week = [success objectForKey:@"week"][0];
            
            
            NSLog(@"%@",startDate);
            
            NSString *selectLuckExist = [NSString stringWithFormat:@"select * from MONEYLUCK where start_date = '%@'",startDate];
            if (![db open]) {
                NSLog(@"Could not open db.");
                return;
            }
            FMResultSet *rs = [db executeQuery:selectLuckExist];
            if ([rs next]) {
                [db close];
                return ;
            }
            
            for (int i = 0; i<nameArray.count; i++) {
                BOOL sql = [db executeUpdate:@"insert into MONEYLUCK (constellation,life,work,start_date,week_sequence) values (?,?,?,?,?)",nameArray[i],lifeArray[i],workArray[i], startDate,week];
                if (!sql) {
                    NSLog(@"ERROR: %d - %@", db.lastErrorCode, db.lastErrorMessage);
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:LuckChanged  object:nil];
            
            [db close];
            
        } failure:^(NSError * failure){
            NSLog(@"%@",failure);
        }];
    }
}

-(void)insertDefaultCategoryToDB:(FMDatabase *)database
{
    if ([CommonUtility isSystemLangChinese]) {
        
        
        BOOL sql =
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('就餐',1,252,88,61)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('阅读',1,136,182,77)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('游戏',1,44,105,163)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('购物',1,193,53,60)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('医疗',1,202,93,172)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('健身',1,54,73,127)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('宠物',1,103,99,102)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('访友',1,71,66,36)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('陪孩子',1,246,154,10)"];
        ///////////////////////////////////////////
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('培训',0,129,79,40)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('开会',0,136,21,203)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('求职',0,224,104,1)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('自学',0,116,84,106)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('沟通',0,162,168,148)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('设计',0,117,176,144)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('施工',0,68,111,121)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('编码',0,45,78,81)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('文案',0,40,56,71)"];
        
        if (!sql) {
            NSLog(@"CATEGORY ERROR: %d - %@", database.lastErrorCode, database.lastErrorMessage);
        }
    }else
    {
        BOOL sql =
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Dining',1,252,88,61)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Reading',1,136,182,77)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Game',1,44,105,163)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Shopping',1,193,53,60)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Healthcare',1,202,93,172)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Sports',1,54,73,127)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Pets',1,103,99,102)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Visiting',1,71,66,36)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Kids',1,246,154,10)"];
        ///////////////////////////////////////////
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Training',0,129,79,40)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Meeting',0,136,21,203)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Get Job',0,224,104,1)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Self study',0,116,84,106)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Communicate',0,162,168,148)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Design',0,117,176,144)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Implement',0,68,111,121)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Coding',0,45,78,81)"];
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Writing',0,40,56,71)"];
        if (!sql) {
            NSLog(@"CATEGORY EN ERROR: %d - %@", database.lastErrorCode, database.lastErrorMessage);
        }
    }
    
}

-(void)insertDefaultColorToDB:(FMDatabase *)database
{
    BOOL sql =      [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (252,88,61,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (136,182,77,2)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (44,105,163,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (193,53,60,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (202,93,172,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (54,73,127,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (103,99,102,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (71,66,36,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (246,154,10,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (129,79,40,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (136,21,203,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (224,104,1,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (116,84,106,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (162,168,148,1)"];
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (117,176,144,1)"];
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (68,111,121,1)"];
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (45,78,81,1)"];
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (40,56,71,1)"];
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (50,147,111,0)"];
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (183,29,99,0)"];
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (116,78,19,0)"];
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (90,73,109,0)"];
    
    
    
    if (!sql) {
        NSLog(@"COLOR ERROR: %d - %@", database.lastErrorCode, database.lastErrorMessage);
    }
    
}


-(void)insertDefaultGOALSToDB:(FMDatabase *)database
{
    if ([CommonUtility isSystemLangChinese]) {
        
        BOOL sql =  [database executeUpdate:@"INSERT INTO GOALS(TYPE,theme,byTime,target_time,target_count,done_time,done_count,is_completed) VALUES(0,'沟通',0,0,10,0,0,0)"];
        
        [database executeUpdate:@"INSERT INTO GOALS(TYPE,theme,byTime,target_time,target_count,done_time,done_count,is_completed) VALUES(0,'培训',0,0,5,0,0,0)"];
        
        [database executeUpdate:@"INSERT INTO GOALS(TYPE,theme,byTime,target_time,target_count,done_time,done_count,is_completed) VALUES(1,'阅读',1,20,0,0,0,0)"];
        
        [database executeUpdate:@"INSERT INTO GOALS(TYPE,theme,byTime,target_time,target_count,done_time,done_count,is_completed) VALUES(1,'健身',1,50,0,0,0,0)"];
        
        if (!sql) {
            NSLog(@"COLOR ERROR: %d - %@", database.lastErrorCode, database.lastErrorMessage);
        }
    }else
    {
        BOOL sql =  [database executeUpdate:@"INSERT INTO GOALS(TYPE,theme,byTime,target_time,target_count,done_time,done_count,is_completed) VALUES(0,'Communicate',0,0,10,0,0,0)"];
        
        [database executeUpdate:@"INSERT INTO GOALS(TYPE,theme,byTime,target_time,target_count,done_time,done_count,is_completed) VALUES(0,'Training',0,0,5,0,0,0)"];
        
        [database executeUpdate:@"INSERT INTO GOALS(TYPE,theme,byTime,target_time,target_count,done_time,done_count,is_completed) VALUES(1,'Reading',1,20,0,0,0,0)"];
        
        [database executeUpdate:@"INSERT INTO GOALS(TYPE,theme,byTime,target_time,target_count,done_time,done_count,is_completed) VALUES(1,'Sports',1,50,0,0,0,0)"];
        
        if (!sql) {
            NSLog(@"COLOR ERROR: %d - %@", database.lastErrorCode, database.lastErrorMessage);
        }
    }
    
}

-(void)configShare
{
    NSLog(@"configShare");
    
    
    [MobClick startWithAppkey:@"5466fe56fd98c505fb003d3c" reportPolicy:REALTIME   channelId:nil];
    [MobClick setAppVersion:VERSIONNUMBER];
    [OpenShare connectWeixinWithAppId:@"wx4e1ffebe5397b9ef"];
}



@end
