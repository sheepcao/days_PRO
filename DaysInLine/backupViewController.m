//
//  backupViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 5/10/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "backupViewController.h"
#import "loginViewController.h"
#import "topBarView.h"
#import "global.h"
#import "CommonUtility.h"
#import "MBProgressHUD.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFURLSessionManager.h"


@interface backupViewController ()
@property (nonatomic,strong)topBarView *topBar;
@property (nonatomic, strong) UIView *lastBackupView;
@property (nonatomic,strong) UIView *firstBackupView;
@property (nonatomic,strong) FMDatabase *db;

@end

@implementation backupViewController
@synthesize db;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self configTopbar];
    [self configFirstBackupView];
    [self configLastBackupView];
    
    if ( !self.backupDay || [self.backupDay isKindOfClass:[NSNull class]] ) {
        [self.lastBackupView setHidden:YES];
        [self.firstBackupView setHidden:NO];
    }else
    {
        [self updateBackupInfoWithDate:self.backupDay andDevice:self.backupDevice];
        [self.lastBackupView setHidden:NO];
        [self.firstBackupView setHidden:YES];

    }
    [self configOperaView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"backup"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"backup"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configTopbar
{
    self.topBar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topBarHeight)];
    self.topBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.topBar];
    
    UIButton * closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 32, 40, 40)];
    closeViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    closeViewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [closeViewButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    closeViewButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [closeViewButton setTitleColor:   normalColor forState:UIControlStateNormal];
    [closeViewButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    closeViewButton.backgroundColor = [UIColor clearColor];
    [self.topBar addSubview:closeViewButton];
    
    UILabel *titileLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 90, 28, 180, 50)];
    [titileLabel setText:NSLocalizedString(@"同 步 | 备 份",nil) ];
    titileLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:titleSize];
    titileLabel.textAlignment = NSTextAlignmentCenter;
    [titileLabel setTextColor:normalColor];
    [self.topBar addSubview:titileLabel];

    
    UIButton *changeButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-83, 33.5, 80, 40)];
    changeButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
    changeButton.titleLabel.textAlignment = NSTextAlignmentRight;
    changeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [changeButton setTitle:NSLocalizedString(@"切换账号",nil) forState:UIControlStateNormal];
    [changeButton setTitleColor:   normalColor forState:UIControlStateNormal];
    [changeButton addTarget:self action:@selector(changeAccount) forControlEvents:UIControlEventTouchUpInside];
    changeButton.backgroundColor = [UIColor clearColor];
    [self.topBar addSubview:changeButton];
    
}

-(void)changeAccount
{
    loginViewController *backupVC = [[loginViewController alloc] initWithNibName:@"loginViewController" bundle:nil];
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    [viewControllers removeObject:viewControllers.lastObject];
    [viewControllers addObject:backupVC];
    [self.navigationController setViewControllers:viewControllers animated:YES];

}

-(void)closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)configLastBackupView
{
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, self.topBar.frame.size.height + (SCREEN_HEIGHT - 480) /3, SCREEN_WIDTH, 200)];
    self.firstBackupView = content;
    
    UILabel *lastTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 150, 5, 300, 150)];
    lastTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:50.0f];
    lastTitleLabel.adjustsFontSizeToFitWidth = YES;
    lastTitleLabel.textAlignment = NSTextAlignmentCenter;
    [lastTitleLabel setText:NSLocalizedString(@"首次备份",nil)];
    [lastTitleLabel setTextColor: self.myTextColor];
    lastTitleLabel.backgroundColor = [UIColor clearColor];
    
    [content addSubview:lastTitleLabel];
    [self.view addSubview:content];
    
}

-(void)configFirstBackupView
{
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, self.topBar.frame.size.height + (SCREEN_HEIGHT - 480) /3, SCREEN_WIDTH, 200)];
    self.lastBackupView = content;
    
    UILabel *lastTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 120, 0, 240, 20)];
    lastTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
    lastTitleLabel.textAlignment = NSTextAlignmentCenter;
    [lastTitleLabel setText:NSLocalizedString(@"上次备份时间及设备",nil)];
    [lastTitleLabel setTextColor: self.myTextColor];
    lastTitleLabel.backgroundColor = [UIColor clearColor];
    [content addSubview:lastTitleLabel];
    

    
    UIView *midLine = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-0.5, lastTitleLabel.frame.origin.y+lastTitleLabel.frame.size.height +20, 0.5, 140)];
    midLine.backgroundColor = [UIColor whiteColor];
    [content addSubview:midLine];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(20, content.frame.size.height - 1, SCREEN_WIDTH-40 , 0.5)];
    bottomLine.backgroundColor = [UIColor whiteColor];
    [content addSubview:bottomLine];
    
    UILabel *yearAndMonth = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, SCREEN_WIDTH/2 - 40, 20)];
    yearAndMonth.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
    yearAndMonth.textAlignment = NSTextAlignmentCenter;
    [yearAndMonth setText:@"None-None"];
    
    [yearAndMonth setTextColor:  self.myTextColor];
    yearAndMonth.backgroundColor = [UIColor clearColor];
    yearAndMonth.tag = 1;
    [content addSubview:yearAndMonth];
    
    UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, yearAndMonth.frame.origin.y + yearAndMonth.frame.size.height, SCREEN_WIDTH/2 - 40, 50)];
    dayLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40.0f];
    dayLabel.textAlignment = NSTextAlignmentCenter;
    [dayLabel setText:@"None"];
    [dayLabel setTextColor:  self.myTextColor];
    dayLabel.backgroundColor = [UIColor clearColor];
    dayLabel.tag = 2;
    [content addSubview:dayLabel];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, dayLabel.frame.origin.y + dayLabel.frame.size.height, SCREEN_WIDTH/2 - 40, 30)];
    timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    [timeLabel setText:@"None"];
    [timeLabel setTextColor:  self.myTextColor];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.tag = 3;
    [content addSubview:timeLabel];
    
    
    
    UILabel *deviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(midLine.frame.origin.x +20, 70, SCREEN_WIDTH/2 - 40, 80)];
    deviceLabel.adjustsFontSizeToFitWidth = YES;
    deviceLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f];
    deviceLabel.textAlignment = NSTextAlignmentCenter;
    [deviceLabel setText:@"None"];
    [deviceLabel setTextColor:  self.myTextColor];
    deviceLabel.backgroundColor = [UIColor clearColor];
    deviceLabel.tag = 4;
    [content addSubview:deviceLabel];
    

    [self.view addSubview:content];
    
}

-(void)configOperaView
{
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, self.lastBackupView.frame.origin.y + self.lastBackupView.frame.size.height+5, SCREEN_WIDTH, SCREEN_HEIGHT/2)];
    
//    UIView *midLine = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-0.5, 30, 0.5, SCREEN_HEIGHT/2-60)];
//    midLine.backgroundColor = [UIColor whiteColor];
//    [content addSubview:midLine];
    
    UIButton *uploadButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH/6)/2,  content.frame.size.height/2 - (SCREEN_WIDTH/3)/0.83, SCREEN_WIDTH/3, (SCREEN_WIDTH/3)/0.83)];
    [uploadButton setImage:[UIImage imageNamed:@"backup"] forState:UIControlStateNormal];
    uploadButton.backgroundColor = [UIColor clearColor];
    [uploadButton addTarget:self action:@selector(uploadData) forControlEvents:UIControlEventTouchUpInside];
    [content addSubview:uploadButton];
    
    UILabel *uploadText = [[UILabel alloc] initWithFrame:CGRectMake(uploadButton.frame.origin.x, uploadButton.frame.origin.y+uploadButton.frame.size.height + 2, uploadButton.frame.size.width, 20)];
    uploadText.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    [uploadText setTextColor:self.myTextColor];
    [uploadText setText:NSLocalizedString(@"备份至云端",nil)];
    uploadText.textAlignment = NSTextAlignmentCenter;
    [content addSubview:uploadText];
    
    UIButton *downLoadButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 +(SCREEN_WIDTH/6)/2, content.frame.size.height/2 - (SCREEN_WIDTH/3)/0.83, SCREEN_WIDTH/3, (SCREEN_WIDTH/3)/0.83)];
    [downLoadButton setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
    downLoadButton.backgroundColor = [UIColor clearColor];

//    [downLoadButton setTitle:@"同步到本地" forState:UIControlStateNormal];
    [downLoadButton addTarget:self action:@selector(downloadData) forControlEvents:UIControlEventTouchUpInside];
    [content addSubview:downLoadButton];
    
    UILabel *downText = [[UILabel alloc] initWithFrame:CGRectMake(downLoadButton.frame.origin.x, downLoadButton.frame.origin.y+downLoadButton.frame.size.height + 2, downLoadButton.frame.size.width, 20)];
    downText.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    [downText setTextColor:self.myTextColor];
    [downText setText:NSLocalizedString(@"同步到本地",nil)];
    downText.textAlignment = NSTextAlignmentCenter;
    [content addSubview:downText];
    
    [self.view addSubview:content];
    
}
-(void)updateBackupInfoWithDate:(NSString *)date andDevice:(NSString *)deviceName
{
    UILabel *yearMonth = (UILabel *)[self.lastBackupView viewWithTag:1];
    UILabel *dayLabel = (UILabel *)[self.lastBackupView viewWithTag:2];
    UILabel *timeLabel = (UILabel *)[self.lastBackupView viewWithTag:3];
    UILabel *deviceLabel = (UILabel *)[self.lastBackupView viewWithTag:4];
    
    NSArray *timeArray = [date componentsSeparatedByString:@" "];
    if (timeArray.count>0)
    {
        NSArray *yearMonthDay = [timeArray[0] componentsSeparatedByString:@"-"];
        if (yearMonthDay.count>2) {
            [yearMonth setText:[NSString stringWithFormat:@"%@ - %@",yearMonthDay[0],yearMonthDay[1]]];
            [dayLabel setText:[NSString stringWithFormat:@"%@",yearMonthDay[2]]];
        }
        
        NSArray *times = [timeArray[1] componentsSeparatedByString:@":"];
        if (times.count>2) {
            [timeLabel setText:[NSString stringWithFormat:@"%@ : %@ : %@ ",times[0],times[1],times[2]]];
        }
    }
    [deviceLabel setText:deviceName];

}


-(void)uploadData
{
    if ( !self.backupDay || [self.backupDay isKindOfClass:[NSNull class]] ) {
        [self uploadDB];
    }else
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"即将以当前设备的数据替换上次备份的数据",nil)  preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确认",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self uploadDB];

        }];
        UIAlertAction* noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消",nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:yesAction];
        [alert addAction:noAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }

}

-(void)uploadDB
{
    [MobClick event:@"backup"];

    NSString *dbPath = [[CommonUtility sharedCommonUtility] dbPath];
    
    
    NSData *sqlData = [NSData dataWithContentsOfFile:dbPath];

    NSString * deviceName = [[UIDevice currentDevice] name];
    NSString * fileName = [NSString stringWithFormat:@"%@_infoNew.sqlite",self.username];
    
    NSString *backupTime = [[CommonUtility sharedCommonUtility] timeNowFull];

    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = NSLocalizedString(@"正在备份...",nil);
    hud.dimBackground = YES;
    hud.tag = 123;
    
    NSDictionary *parameters = @{@"tag": @"uploadSQLs",@"name":self.username,@"backup_device":deviceName,@"backupTime":backupTime};
    
    
    AFHTTPRequestOperationManager *manager2 = [AFHTTPRequestOperationManager manager];
    [manager2 setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [manager2.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager2.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager2.requestSerializer setTimeoutInterval:120];  //Time out after 120 seconds
    
    
    [manager2 POST:backupURL  parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        if (sqlData) {
            [formData appendPartWithFileData:sqlData name:@"file" fileName:fileName mimeType:@"text/plain"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
        NSString *backupDay = [responseObject objectForKey:@"backup_day"];
        NSString *backupDevice = [responseObject objectForKey:@"backup_device"];
        
        [self updateBackupInfoWithDate:backupDay andDevice:backupDevice];
        [self uploadRecords];

//        [self.lastBackupView setHidden:NO];
//        [self.firstBackupView setHidden:YES];
//        
//        hud.mode = MBProgressHUDModeText;
//        hud.labelText = NSLocalizedString(@"备份成功",nil);
//        [hud hide:YES afterDelay:1.5];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"Error";
        [hud hide:YES afterDelay:1.5];
        
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"备份失败，请重试",nil)  preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确认",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:yesAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

-(void)downloadData
{
    if ( !self.backupDay || [self.backupDay isKindOfClass:[NSNull class]] )
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"您还未进行过备份，无法同步到本地。",nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确认",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:yesAction];
        [self presentViewController:alert animated:YES completion:nil];

     
    }else
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"云端备份数据将覆盖本机当前数据，确认继续?",nil)  preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确认",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self downloadURLFromServer];
        }];
        UIAlertAction* noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消",nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:noAction];
        [alert addAction:yesAction];
        [self presentViewController:alert animated:YES completion:nil];

    }
}

-(void)downloadURLFromServer
{
    
    [MobClick event:@"download"];

    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = NSLocalizedString(@"正在同步到本地...",nil);
    hud.dimBackground = YES;
    hud.tag = 456;
    NSDictionary *parameters = @{@"tag": @"download",@"name":self.username};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager.requestSerializer setTimeoutInterval:120];  //Time out after 25 seconds
    
    
    [manager POST:backupURL parameters:parameters success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        
        NSMutableArray *fullURLArray = [[NSMutableArray alloc] init];
        NSArray * URLArray = [responseObject objectForKey:@"files"];
        for (int i = 0; i <URLArray.count; i++) {
            NSString *oneURL = [NSString stringWithFormat:@"%@%@",backupPath,[responseObject objectForKey:@"files"][i]];
            [fullURLArray addObject:oneURL];
        }
        
        NSLog(@"URL URLArray: %@", fullURLArray);
        
        [self downloadFromURLs:fullURLArray];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        NSLog(@"JSON ERROR: %@",  operation.responseString);
        
        hud.mode = MBProgressHUDModeText;
        
        hud.labelText = NSLocalizedString(@"同步失败，请稍后重试",nil);
        
        [hud hide:YES afterDelay:1.5];
        
        
    }];
}

-(void)downloadFromURLs:(NSMutableArray *)urlArray
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    [self downloadMulti:urlArray withManager:manager];
    
}
-(void)downloadMulti:(NSMutableArray *)urlArray withManager:(AFURLSessionManager *)manager
{
    
    if (urlArray.count == 0) {
        MBProgressHUD *hud = (MBProgressHUD *)[self.view viewWithTag:456];
        if(hud)
        {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = NSLocalizedString(@"成功同步到本机",nil);
            [hud hide:YES afterDelay:1.2];

            [self performSelector:@selector(closeVC ) withObject:nil afterDelay:1.5];
        }
        return;
    }else
    {
        NSError *error;
        NSString *dirString = [[CommonUtility sharedCommonUtility] docsPath];

        NSData *dbFile = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:urlArray[0]]];
        
        NSString *fileName = [urlArray[0] componentsSeparatedByString:@"_"].lastObject;
        
        NSString *destPath = [NSString stringWithFormat:@"%@/%@",dirString,fileName];
        
        NSFileManager *fileManager =[NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:destPath] == YES)
        {
            
            [[NSFileManager defaultManager] removeItemAtPath:destPath error:&error];
            NSLog(@"Error description-%@ \n", [error localizedDescription]);
            NSLog(@"Error reason-%@", [error localizedFailureReason]);
            
        }

        BOOL success = [dbFile writeToFile:destPath options:NSDataWritingAtomic error:&error];
        
        NSLog(@"destPath:%@ and success：%d for error:%@",destPath ,success,error);
        [urlArray removeObjectAtIndex:0];
        [self downloadMulti:urlArray withManager:manager];
    }
}


-(void)uploadRecords
{
    NSURL *storeURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.sheepcao.DaysInLine"];
    NSString *docsPath = [storeURL path];
    
    NSString *path;
    NSFileManager *fm;
    NSArray *dirArray;
    NSError *error;
    
    NSMutableArray *soundsArray = [[NSMutableArray alloc] init];
    NSMutableArray *soundsNameArray = [[NSMutableArray alloc] init];
    
    
    fm = [NSFileManager defaultManager];
    
    //获取当前的工作目录的路径
    path = [fm currentDirectoryPath];
    
    dirArray = [fm contentsOfDirectoryAtPath:docsPath error:&error];
    NSLog(@"path error:%@",error);
    
    for(path in dirArray)
    {
        if ([CommonUtility myContainsStringFrom:path forSubstring:@"message"]) {
            NSLog(@"path-------------%@",path);
            NSString *fullPath = [NSString stringWithFormat:@"%@/%@",docsPath,path];
            NSData *sqlData = [NSData dataWithContentsOfFile:fullPath];
        
            [soundsNameArray addObject:path];
            [soundsArray addObject:sqlData];
            
        }
        
    }
    
    
    NSDictionary *parameters = @{@"tag": @"uploadSounds",@"name":self.username,@"soundCount":[NSString stringWithFormat:@"%lu",(unsigned long)soundsArray.count]};

    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:backupURL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for(int i = 0;i<soundsNameArray.count;i++)
        {
            NSData *eachSound = soundsArray[i];
            NSString *soundName = soundsNameArray[i];
            NSString *soundOnServer = [NSString stringWithFormat:@"%@_%@",self.username,soundName];
            
            [formData appendPartWithFileData:eachSound name:[NSString stringWithFormat:@"file%d",i] fileName:soundOnServer mimeType:@"audio/x-caf"];
        }
    } error:&error];
    request.timeoutInterval = 120;
    
    NSLog(@"upload sounds error:%@",error);
    
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            MBProgressHUD *hud = (MBProgressHUD *)[self.view viewWithTag:123];
            if(hud)
            {
                hud.labelText = NSLocalizedString(@"备份失败",nil);
                [hud hide:YES afterDelay:1.2];
            }
        } else {
            NSLog(@"----===%@ %@", response, responseObject);
            [self uploadImages];
            
            
        }
        
    }];
    
    
    [uploadTask resume];
    
    
    
    
    
}

//
-(void)uploadImages
{
    NSURL *storeURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.sheepcao.DaysInLine"];
    NSString *docsPath = [storeURL path];
    
    NSString *path;
    NSFileManager *fm;
    //    NSArray *dirArray;
    NSError *error;
    
    NSMutableArray *imgArray = [[NSMutableArray alloc] init];
    NSMutableArray *imgNameArray = [[NSMutableArray alloc] init];
    
    
    fm = [NSFileManager defaultManager];
    
    //获取当前的工作目录的路径
    //    path = [fm currentDirectoryPath];
    
    //    dirArray = [fm contentsOfDirectoryAtPath:docsPath error:&error];
    NSLog(@"path error:%@",error);
    
    
    NSString *allPhoeoNames = [self selectPhotoNames];
    
    NSArray *photoNameArray = [allPhoeoNames componentsSeparatedByString:@";"];
    
    
    
    
    for(path in photoNameArray)
    {
        if ([CommonUtility myContainsStringFrom:path forSubstring:@".png"] && path.length>18) {
            NSLog(@"path-------------%@",path);
            
            NSString *fullPath = [NSString stringWithFormat:@"%@/%@",docsPath,path];
            NSData *sqlData = [NSData dataWithContentsOfFile:fullPath];
        
            [imgNameArray addObject:path];
            [imgArray addObject:sqlData];
            
        }
        
    }
    
    
    NSDictionary *parameters = @{@"tag": @"uploadImages",@"name":self.username,@"imageCount":[NSString stringWithFormat:@"%lu",(unsigned long)imgArray.count]};
    
    
    
    
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:backupURL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for(int i = 0;i<imgNameArray.count;i++)
        {
            NSData *eachImg = imgArray[i];
            NSString *imgName = imgNameArray[i];
            NSString *imgOnServer = [NSString stringWithFormat:@"%@_%@",self.username,imgName];
            
            [formData appendPartWithFileData:eachImg name:[NSString stringWithFormat:@"file%d",i] fileName:imgOnServer mimeType:@"image/png"];
        }
    } error:&error];
    request.timeoutInterval = 180;
    
    NSLog(@"upload images error:%@",error);
    
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {

    }completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            MBProgressHUD *hud = (MBProgressHUD *)[self.view viewWithTag:123];
            if(hud)
            {
                hud.mode = MBProgressHUDModeText;
                
                hud.labelText = @"备份失败";
                [hud hide:YES afterDelay:1.2];
            }

        } else {
            NSLog(@"----===%@ %@", response, responseObject);
                    [self.lastBackupView setHidden:NO];
                    [self.firstBackupView setHidden:YES];
                MBProgressHUD *hud = (MBProgressHUD *)[self.view viewWithTag:123];

                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = NSLocalizedString(@"备份成功",nil);
                    [hud hide:YES afterDelay:1.5];
        }
        
        
        
         }];
    
    
    [uploadTask resume];
    

}


-(NSString *)selectPhotoNames
{
    
    NSString *photo = @"";
    db = [[CommonUtility sharedCommonUtility] db];

    if (![db open]) {
        NSLog(@"mainVC/Could not open db.");
        return nil;
    }
    
    NSString *onePhoto;
    
    FMResultSet *rs = [db executeQuery:@"SELECT photoDir from EVENTS"];
    while ([rs next]) {
        onePhoto = [rs stringForColumn:@"photoDir"];
        if(![onePhoto isEqualToString:@""]&&![onePhoto isEqualToString:@" "])
        {
            photo = [NSString stringWithFormat:@"%@;%@",photo,onePhoto];
        }
    }
    
    return photo;
}



@end
