//
//  exportViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 5/23/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "exportViewController.h"
#import "CommonUtility.h"
#import "global.h"
#import "topBarView.h"
#import "MBProgressHUD.h"
#import <MessageUI/MessageUI.h>
#import "CHCSVParser.h"
#import "MLIAPManager.h"

static NSString * const productId = @"sheepcao.daysinline.exportData";

@interface exportViewController ()<MFMailComposeViewControllerDelegate,MLIAPManagerDelegate>
@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) topBarView *topBar;
@property (nonatomic, strong) UIView *tipView;
@property (nonatomic, strong) UIView *buyView;
@property (nonatomic, strong) UIView *operationView;
@property (nonatomic, strong) UIButton *myRestoreButton;

@property (nonatomic, strong) UIButton *myUploadButton;
@property (nonatomic, strong) UIButton *myDownloadButton;
@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation exportViewController
@synthesize db;
@synthesize hud;


-(NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:NSLocalizedString(@"数据导出-历历在目.csv",nil) ];
}

-(NSString *)xlsFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:NSLocalizedString(@"数据导出-历历在目.xls",nil) ];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    

    

    [self prepareData];
    [self configTopbar];
    
    [self configLastBackupView];
//    [self configBuyView];
    [self configOperaView];

    [self showBoughtView];

}


-(void)showBoughtView
{
    [self.tipView setHidden:NO];
    [self.buyView setHidden:YES];
    self.myUploadButton.enabled = YES;
    self.myDownloadButton.enabled = YES;
    self.operationView.alpha = 1.0f;
    [self.myRestoreButton setHidden:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareData
{
    self.flowData = [[NSMutableArray alloc] init];
    
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"mainVC/Could not open db.");
        return;
    }
    
    NSString *minDate = [[CommonUtility sharedCommonUtility] todayDate];
    NSString *maxDate = minDate;
    
    FMResultSet *rs = [db executeQuery:@"select date from EVENTS order by date LIMIT 1"];
    while ([rs next]) {
        minDate = [rs stringForColumn:@"date"];
        NSArray *minArray = [minDate componentsSeparatedByString:@" "];
        minDate = minArray[0];
    }
    FMResultSet *rs2 = [db executeQuery:@"select date from EVENTS order by date desc LIMIT 1"];
    while ([rs2 next]) {
        maxDate = [rs2 stringForColumn:@"date"];
        NSArray *maxArray = [maxDate componentsSeparatedByString:@" "];
        maxDate = maxArray[0];
    }
    

    FMResultSet *result = [db executeQuery:@"select * from EVENTS where strftime('%s', date) BETWEEN strftime('%s', ?) AND strftime('%s', ?)", minDate,maxDate];
    while ([result next]) {
        
        NSMutableDictionary *oneItemDict = [[NSMutableDictionary alloc] initWithCapacity:6];
        NSInteger type =[result intForColumn:@"TYPE"];
        double startTime =  [result doubleForColumn:@"startTime"];
        double endTime =  [result doubleForColumn:@"endTime"];

        NSString *startString = [[CommonUtility sharedCommonUtility] timeInLine:((int)startTime)];
        NSString *endString = [[CommonUtility sharedCommonUtility] timeInLine:((int)endTime)];
        
        [oneItemDict setObject:[result stringForColumn:@"TITLE"] forKey:@"item_category"];
        [oneItemDict setObject:[result stringForColumn:@"mainText"] forKey:@"item_description"];
        if (type == 0) {
            [oneItemDict setObject:NSLocalizedString(@"工作",nil) forKey:@"item_type"];
        }else if (type == 1)
        {
            [oneItemDict setObject:NSLocalizedString(@"生活",nil) forKey:@"item_type"];
        }
        [oneItemDict setObject:[result stringForColumn:@"date"] forKey:@"target_date"];
        [oneItemDict setObject:[NSString stringWithFormat:@"%@",startString] forKey:@"startTime"];
        [oneItemDict setObject:[NSString stringWithFormat:@"%@",endString] forKey:@"endTime"];

        [self.flowData addObject:oneItemDict];
    }
    
    [db close];

    
    CHCSVWriter *csvWriter=[[CHCSVWriter alloc]initForWritingToCSVFile:[self dataFilePath]];
    NSLog(@"%@",[self dataFilePath]);
    
    [csvWriter writeField:NSLocalizedString(@"日期",nil)];
    [csvWriter writeField:NSLocalizedString(@"工作/生活",nil)];
    [csvWriter writeField:NSLocalizedString(@"主题",nil)];
    [csvWriter writeField:NSLocalizedString(@"描述",nil)];
    [csvWriter writeField:NSLocalizedString(@"开始时间",nil)];
    [csvWriter writeField:NSLocalizedString(@"结束时间",nil)];


    [csvWriter finishLine];
    
    for(int i=0;i<[self.flowData count];i++)
    {
        [csvWriter writeField:[[self.flowData objectAtIndex:i] objectForKey:@"target_date"]];
        [csvWriter writeField:[[self.flowData objectAtIndex:i] objectForKey:@"item_type"]];
        [csvWriter writeField:[[self.flowData objectAtIndex:i] objectForKey:@"item_category"]];
        [csvWriter writeField:[[self.flowData objectAtIndex:i] objectForKey:@"item_description"]];
        [csvWriter writeField:[[self.flowData objectAtIndex:i] objectForKey:@"startTime"]];
        [csvWriter writeField:[[self.flowData objectAtIndex:i] objectForKey:@"endTime"]];

        [csvWriter finishLine];
    }
    
    [csvWriter closeStream];
    
    [self exportToExcel];

    
}

- (void)exportToExcel
{

    NSString *header = @"<?xml version=\"1.0\"?><Workbook xmlns=\"urn:schemas-microsoft-com:office:spreadsheet\" xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:x=\"urn:schemas-microsoft-com:office:excel\" xmlns:ss=\"urn:schemas-microsoft-com:office:spreadsheet\" xmlns:html=\"http://www.w3.org/TR/REC-html40\"><Styles> <Style ss:ID=\"s21\"><Font x:Family=\"Swiss\" ss:Bold=\"1\" /></Style></Styles><Worksheet ss:Name=\"Sheet1\">";

    
    NSString *rowStart = @"<Row>";
    NSString *rowEnde = @"</Row>";
    
    NSString *stringStart = @"<Cell><Data ss:Type=\"String\">";
    NSString *boldStringStart = @"<Cell ss:StyleID=\"s21\"><Data ss:Type=\"String\">";

    NSString *stringEnde = @"</Data></Cell>";
    

    NSString *footer = @"</Table></Worksheet></Workbook>";
    
    NSString *xlsstring = @"";
    
    NSInteger numberOfRows =1;
    NSInteger numberOfCols = 6;
    numberOfRows = numberOfRows + self.flowData.count;
    
    NSString *colomnFormat = [NSString stringWithFormat:@"<Table ss:ExpandedColumnCount=\"%ld\" ss:ExpandedRowCount=\"%ld\" x:FullColumns=\"1\" x:FullRows=\"1\">",(long)numberOfCols,(long)numberOfRows];
    
    xlsstring = [NSString stringWithFormat:@"%@%@", header,colomnFormat];
    
     xlsstring = [xlsstring stringByAppendingFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", rowStart, boldStringStart,NSLocalizedString(@"日期",nil), stringEnde, boldStringStart,NSLocalizedString(@"工作/生活",nil), stringEnde, boldStringStart, NSLocalizedString(@"主题",nil), stringEnde, boldStringStart, NSLocalizedString(@"描述",nil), stringEnde, boldStringStart, NSLocalizedString(@"开始时间",nil), stringEnde,boldStringStart, NSLocalizedString(@"结束时间",nil), stringEnde,rowEnde];
    
    for (NSDictionary *form in self.flowData) {
        xlsstring = [xlsstring stringByAppendingFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", rowStart, stringStart, [form objectForKey:@"target_date"], stringEnde, stringStart, [form objectForKey:@"item_type"], stringEnde, stringStart, [form objectForKey:@"item_category"], stringEnde, stringStart, [form objectForKey:@"item_description"], stringEnde, stringStart, [form objectForKey:@"startTime"], stringEnde,stringStart, [form objectForKey:@"endTime"], stringEnde,rowEnde];
    }
    xlsstring = [xlsstring stringByAppendingFormat:@"%@", footer];
    
    [xlsstring writeToFile:[self xlsFilePath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}


-(void)closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)configTopbar
{
    self.topBar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topRowHeight + 5)];
    self.topBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.topBar];
    [self.topBar.titleLabel  setText:NSLocalizedString(@"导出数据",nil)];
    
    
    UIButton * closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 32, 40, 40)];
    closeViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    closeViewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [closeViewButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    closeViewButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [closeViewButton setTitleColor:   normalColor forState:UIControlStateNormal];
    [closeViewButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    closeViewButton.backgroundColor = [UIColor clearColor];
    [self.topBar addSubview:closeViewButton];
    
//    
//    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-70, 30, 60, 40)];
//    saveButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
//    saveButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//    [saveButton setTitle:NSLocalizedString(@"恢复购买",nil) forState:UIControlStateNormal];
//    
////    [saveButton setImage:[UIImage imageNamed:@"done"] forState:UIControlStateNormal];
////    saveButton.imageEdgeInsets = UIEdgeInsetsMake(3.9, 3.9,3.9, 3.9);
//    [saveButton setTitleColor:   normalColor forState:UIControlStateNormal];
//    [saveButton addTarget:self action:@selector(restoreBuy:) forControlEvents:UIControlEventTouchUpInside];
//    saveButton.backgroundColor = [UIColor clearColor];
//    self.myRestoreButton = saveButton;
//    [self.topBar addSubview:saveButton];
}



-(void)configLastBackupView
{
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, self.topBar.frame.size.height + (SCREEN_HEIGHT - 480) /3, SCREEN_WIDTH, 200)];
    self.tipView = content;
    
    UILabel *lastTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 150, 5, 300, 150)];
    lastTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:43.0f];
    lastTitleLabel.numberOfLines = 2;
    lastTitleLabel.adjustsFontSizeToFitWidth = YES;
    lastTitleLabel.textAlignment = NSTextAlignmentCenter;
    [lastTitleLabel setText:NSLocalizedString(@"请选择以下任意格式将数据发送到您的邮箱",nil)];

    [lastTitleLabel setTextColor: self.myTextColor];
    lastTitleLabel.backgroundColor = [UIColor clearColor];
    [content addSubview:lastTitleLabel];
    
    [self.view addSubview:content];
    
}

//-(void)configBuyView
//{
//    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, self.topBar.frame.size.height + (SCREEN_HEIGHT - 480) /3, SCREEN_WIDTH, 200)];
//    self.buyView = content;
//    
//    UILabel * lastTitleLabel= [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 150, 5, 300, 100)];
//    lastTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:50.0f];
//    lastTitleLabel.adjustsFontSizeToFitWidth = YES;
//    lastTitleLabel.textAlignment = NSTextAlignmentCenter;
//    [lastTitleLabel setText:NSLocalizedString(@"6元购买永久使用数据导出功能",nil)];
//    [lastTitleLabel setTextColor: self.myTextColor];
//    lastTitleLabel.backgroundColor = [UIColor clearColor];
//    [content addSubview:lastTitleLabel];
//    
//    UIButton *buyButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 40, lastTitleLabel.frame.origin.y + lastTitleLabel.frame.size.height + 10, 80, 40)];
//    buyButton.layer.cornerRadius = 8;
//    buyButton.layer.masksToBounds = NO;
//    buyButton.layer.shadowColor = [UIColor blackColor].CGColor;
//    buyButton.layer.shadowOpacity = 0.8;
//    buyButton.layer.shadowRadius = 2;
//    buyButton.layer.shadowOffset = CGSizeMake(1.2f, 2.2f);
//    buyButton.layer.borderWidth = 0.75;
//    buyButton.layer.borderColor = normalColor.CGColor;
//    [buyButton setTitle:NSLocalizedString(@"购 买",nil) forState:UIControlStateNormal];
//    [buyButton addTarget:self action:@selector(buyExport) forControlEvents:UIControlEventTouchUpInside];
//    [content addSubview:buyButton];
//
//    
//    [self.view addSubview:content];
//    
//
//    
//}

-(void)configOperaView
{
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, self.tipView.frame.origin.y + self.tipView.frame.size.height+5, SCREEN_WIDTH, SCREEN_HEIGHT/2)];
    self.operationView = content;
    
    UIButton *uploadButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH/6)/2,  content.frame.size.height/2 - (SCREEN_WIDTH/3)/0.83, SCREEN_WIDTH/3, (SCREEN_WIDTH/3)/0.83)];
    [uploadButton setImage:[UIImage imageNamed:@"csv"] forState:UIControlStateNormal];
    uploadButton.backgroundColor = [UIColor clearColor];
    [uploadButton addTarget:self action:@selector(csvExport) forControlEvents:UIControlEventTouchUpInside];
    [content addSubview:uploadButton];
    
    self.myUploadButton = uploadButton;
    
    UILabel *uploadText = [[UILabel alloc] initWithFrame:CGRectMake(uploadButton.frame.origin.x, uploadButton.frame.origin.y+uploadButton.frame.size.height + 2, uploadButton.frame.size.width, 20)];
    uploadText.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    [uploadText setTextColor:self.myTextColor];
    [uploadText setText:NSLocalizedString(@"导出CSV文件",nil)];
    uploadText.textAlignment = NSTextAlignmentCenter;
    [content addSubview:uploadText];
    
    UIButton *downLoadButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 +(SCREEN_WIDTH/6)/2, content.frame.size.height/2 - (SCREEN_WIDTH/3)/0.83, SCREEN_WIDTH/3, (SCREEN_WIDTH/3)/0.83)];
    [downLoadButton setImage:[UIImage imageNamed:@"xls"] forState:UIControlStateNormal];
    downLoadButton.backgroundColor = [UIColor clearColor];
    [downLoadButton addTarget:self action:@selector(xlsExport) forControlEvents:UIControlEventTouchUpInside];
    [content addSubview:downLoadButton];
    self.myDownloadButton = downLoadButton;
    
    UILabel *downText = [[UILabel alloc] initWithFrame:CGRectMake(downLoadButton.frame.origin.x, downLoadButton.frame.origin.y+downLoadButton.frame.size.height + 2, downLoadButton.frame.size.width, 20)];
    downText.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    [downText setTextColor:self.myTextColor];
    [downText setText:NSLocalizedString(@"导出XLS文件",nil)];
    downText.textAlignment = NSTextAlignmentCenter;
    [content addSubview:downText];
    
    [self.view addSubview:content];
    
}

//-(void)buyExport
//{
//    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.mode = MBProgressHUDModeIndeterminate;
//    hud.dimBackground = YES;
//
//    [MLIAPManager sharedManager].delegate = self;
//
//    [[MLIAPManager sharedManager] requestProductWithId:productId];
//}

-(void)csvExport
{
    
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    [picker.view setFrame:CGRectMake(0,20 , 320, self.view.frame.size.height-20)];
    picker.mailComposeDelegate = self;
    

    NSMutableString *emailBody = [NSMutableString string];
    [picker setSubject:NSLocalizedString(@"数据导出-历历在目",nil) ];
    [emailBody appendString: NSLocalizedString(@"请查收附件中的数据文件",nil)];
    [picker setMessageBody:emailBody isHTML:NO];
    

    if (![[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath]]) {
        [[NSFileManager defaultManager] createFileAtPath:[self dataFilePath] contents:nil attributes:nil];
    }
    [picker addAttachmentData:[NSData dataWithContentsOfFile:[self dataFilePath]]
                     mimeType:@"text/csv"
                     fileName:NSLocalizedString(@"数据导出-历历在目.csv",nil) ];

    [self presentViewController:picker animated:YES completion:nil];
}

-(void)xlsExport
{
    
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    if (!picker) {
        return;
    }
    [picker.view setFrame:CGRectMake(0,20 , 320, self.view.frame.size.height-20)];
    picker.mailComposeDelegate = self;
    
    
    NSMutableString *emailBody = [NSMutableString string];
    [picker setSubject:NSLocalizedString(@"数据导出-历历在目",nil) ];
    [emailBody appendString: NSLocalizedString(@"请查收附件中的数据文件",nil)];
    [picker setMessageBody:emailBody isHTML:NO];
    
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self xlsFilePath]]) {
        [[NSFileManager defaultManager] createFileAtPath:[self xlsFilePath] contents:nil attributes:nil];
    }
    [picker addAttachmentData:[NSData dataWithContentsOfFile:[self xlsFilePath]]
                     mimeType:@"text/csv"
                     fileName:NSLocalizedString(@"数据导出-历历在目.xls",nil) ];
    
    [self presentViewController:picker animated:YES completion:nil];
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error

{
    NSLog(@"error:%@",error);
       [self  dismissViewControllerAnimated:YES completion:nil];
    
}




@end
