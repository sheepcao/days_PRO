//
//  global.h
//  simpleFinance
//
//  Created by Eric Cao on 4/7/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#ifndef global_h
#define global_h

#import "FMDatabase.h"
#import "MobClick.h"
#import "myTextLabel.h"
#import "MBProgressHUD.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#define iOS7_0 @"7.0"
#define iOS8_0 @"8.0"


#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 667.0)

#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)


#define PieHeight 270
#define summaryViewHeight 50
#define wordsHeight 67

#define bottomBar 50
#define rowHeight 70
#define topBarHeight 75
#define goalRowHeight 86


#define categoryRowHeight 38

#define topRowHeight 65
#define categoryLabelWith 90
#define titleSize 19


#define  symbolColor   [UIColor colorWithRed:196/255.0f green:178/255.0f blue:124/255.0f alpha:1.0f]
#define  symbolSelectedColor   [UIColor colorWithRed:120/255.0f green:101/255.0f blue:76/255.0f alpha:1.0f]

#define  numberColor   [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]
#define  numberSelectedColor   [UIColor colorWithRed:124/255.0f green:167/255.0f blue:197/255.0f alpha:1.0f]

#define normalColor [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0]

#define TextColor0 [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.0]
//#define TextColor0 [UIColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1.0]
#define TextColor1 [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.0]
#define TextColor2 [UIColor colorWithRed:0.87 green:0.87 blue:0.87 alpha:1.0]
#define TextColor3 [UIColor colorWithRed:0.78 green:0.78 blue:0.78 alpha:1.0]

#define REVIEW_URL_CN @"https://itunes.apple.com/cn/app/daysinline-pro./id998813044?ls=1&mt=8"

#define REVIEW_URL_EN @"https://itunes.apple.com/us/app/daysinline-pro./id998813044?ls=1&mt=8"

#define proAPP_URL @"https://itunes.apple.com/cn/app/daysinline-pro./id998813044?ls=1&mt=8"


#define ALLAPP_URL @"itms://itunes.apple.com/us/artist/cao-guangxu/id844914783"

#define constellationService @"http://cgx.nwpu.info/daysinline/constellation.php"

#define emailService @"http://cgx.nwpu.info/daysinline/sendEmail.php"
#define backupURL @"http://cgx.nwpu.info/daysinline/uploads.php"
#define backupPath @"http://cgx.nwpu.info/daysinline/upload/"


#define SHOWMODEL @"showModel"
#define AUTOSWITCH @"autoSwitch"
#define DEFAULT_USER @"defaultUser"
#define EXPORTBUY @"ExportBuy"
#define Timer @"timerDict"
#define REMOVEAD @"removeAdBuy"
#define ThemeChanged  @"modelNotification"
#define LuckChanged  @"luckNotification"

#define ADMOB_ID @"ca-app-pub-3074684817942615/1126186689"

#define VERSIONNUMBER   [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]


#endif /* global_h */
