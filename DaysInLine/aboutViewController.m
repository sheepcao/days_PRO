//
//  aboutViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 5/12/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "aboutViewController.h"
#import "global.h"
#import "CommonUtility.h"
#import "topBarView.h"
#import "shareViewController.h"
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD.h"
#import "TermUseViewController.h"
#import "UIDevice-Hardware.h"
#import "exportViewController.h"
#import "MLIAPManager.h"

static NSString * const removeADId = @"sheepcao.daysinline.removeAD";


@interface aboutViewController ()<UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate,MLIAPManagerDelegate,UIActionSheetDelegate>
@property (nonatomic,strong) UITableView *settingTable;
@property (nonatomic,strong) topBarView *topBar;
@property (nonatomic,strong) NSArray *rowList;
@property (nonatomic, strong) MBProgressHUD *iapHud;

@end

@implementation aboutViewController
@synthesize iapHud;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.rowList = @[NSLocalizedString(@"导出日程",nil) ,NSLocalizedString(@"邀请好友",nil) ,NSLocalizedString(@"邮件反馈",nil) ,NSLocalizedString(@"前往评分",nil) ,NSLocalizedString(@"联系方式",nil) ];
    [self configTopbar];
    [self configTable];
    
//    if (IS_IPHONE_4_OR_LESS) {
//        
//    }else
//    {
//        [[CommonUtility sharedCommonUtility] addADWithY:0 InView:self.view OfRootVC:self];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"aboutPage"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"aboutPage"];
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
    //    [closeViewButton setTitle:@"返回" forState:UIControlStateNormal];
    [closeViewButton setTitleColor:normalColor forState:UIControlStateNormal];
    [closeViewButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    closeViewButton.backgroundColor = [UIColor clearColor];
    [self.topBar addSubview:closeViewButton];
    
    [self.topBar.titleLabel  setText:NSLocalizedString(@"设置",nil)];
    
}
-(void)closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}



-(void)configTable
{
//    UIImageView *logoView =[[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*3/8, self.topBar.frame.size.height + 20, SCREEN_WIDTH/4, SCREEN_WIDTH/4)];
//    [logoView setImage:[UIImage imageNamed: @"logo.png"]];
//    logoView.layer.cornerRadius = logoView.frame.size.width/6.4;
//    logoView.layer.masksToBounds = YES;
//    [self.view addSubview:logoView];
    
//    UILabel *logoView =[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/6, self.topBar.frame.size.height + 20, SCREEN_WIDTH*2/3, SCREEN_WIDTH/7.6)];
//    [logoView setText:NSLocalizedString(@"简 簿",nil)];
//    logoView.font =  [UIFont fontWithName:@"HelveticaNeue-Light" size:43.5f];
//    NSLog(@"length:%d",logoView.text.length);
//    if (logoView.text.length>6) {
//        logoView.font =  [UIFont fontWithName:@"HelveticaNeue" size:32.5f];
//    }
//    [logoView setTextColor:normalColor];
//    logoView.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
//    logoView.shadowOffset =  CGSizeMake(0.66, 1.66);
//    
//    logoView.textAlignment = NSTextAlignmentCenter;
//    
//    logoView.layer.cornerRadius = logoView.frame.size.width/6.4;
    
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/3, self.topBar.frame.size.height + 10, SCREEN_WIDTH/3, SCREEN_WIDTH/3)];
    [logoView setImage:[UIImage imageNamed:@"logo.png"]];
    [self.view addSubview:logoView];

    
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - logoView.frame.size.width/2, logoView.frame.size.height + logoView.frame.origin.y + 5, logoView.frame.size.width, 20)];
    [versionLabel setText:[NSString stringWithFormat:@"Version:%@",VERSIONNUMBER]];
    versionLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
    versionLabel.adjustsFontSizeToFitWidth = YES;
    versionLabel.textAlignment = NSTextAlignmentCenter;
    [versionLabel setTextColor:self.myTextColor];
    [self.view addSubview:versionLabel];
    
    CGFloat space = 25;
    if (IS_IPHONE_4_OR_LESS) {
        space =8;
    }
    
    self.settingTable = [[UITableView alloc] initWithFrame:CGRectMake(16, versionLabel.frame.origin.y + versionLabel.frame.size.height+space, SCREEN_WIDTH-32, SCREEN_HEIGHT- (versionLabel.frame.origin.y + versionLabel.frame.size.height)) style:UITableViewStylePlain];
    self.settingTable.showsVerticalScrollIndicator = NO;
    self.settingTable.scrollEnabled = NO;
    self.settingTable.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.settingTable.backgroundColor = [UIColor clearColor];
    self.settingTable.delegate = self;
    self.settingTable.dataSource = self;
    self.settingTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.settingTable];
}


#pragma mark table delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ((int)(SCREEN_WIDTH/8));
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    if (indexPath.row < 4) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell.detailTextLabel setBackgroundColor:[UIColor clearColor]];
        cell.detailTextLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Light" size:14.5f];
        [cell.detailTextLabel setTextColor:self.myTextColor];
        [cell.detailTextLabel setText:@"QQ : 82107815"];
    }
    
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    cell.textLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
    [cell.textLabel setTextColor:self.myTextColor];
    [cell.textLabel setText:self.rowList[indexPath.row]];
    
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            exportViewController *exportVC = [[exportViewController alloc] initWithNibName:@"exportViewController" bundle:nil];
            [self.navigationController pushViewController:exportVC animated:YES];
        });
    }
//    else if(indexPath.row == 1)
//    {
//        
//        UIActionSheet *myActionSheet;
//        myActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles: NSLocalizedString(@"购买（¥18 去除广告）",nil), NSLocalizedString(@"恢复购买",nil), nil];
//        [myActionSheet showInView:self.view];
//
//    }
    else if (indexPath.row == 1)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            shareViewController *shareVC = [[shareViewController alloc] initWithNibName:@"shareViewController" bundle:nil];
            [self presentViewController:shareVC animated:YES completion:nil];
        });
    }else if(indexPath.row == 2)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self emailTapped];
        });
    }else if(indexPath.row == 3)
    {
        [MobClick event:@"reviewAPP"];
        
        if ([CommonUtility isSystemLangChinese]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:REVIEW_URL_CN]];
        }else
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:REVIEW_URL_EN]];
        }
        
    }
}

-(void)emailTapped
{
    
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    [picker.view setFrame:CGRectMake(0,20 , 320, self.view.frame.size.height-20)];
    picker.mailComposeDelegate = self;
    
    
    
    // Set up recipients
    NSArray *toRecipients = [NSArray arrayWithObject:@"sheepcao1986@163.com"];
    
    
    [picker setToRecipients:toRecipients];
    
    UIDevice *device = [UIDevice currentDevice];
    
    NSMutableString *emailBody = [NSMutableString string];
    [picker setSubject:NSLocalizedString(@"意见反馈-历历在目",nil) ];
    [emailBody appendString: NSLocalizedString(@"感谢您使用历历在目，请留下您的宝贵意见，我们将与您取得联系!",nil)];
    [emailBody appendFormat:@"\n\n\n\n\n\nApp Ver: %@\n", VERSIONNUMBER];
    [emailBody appendFormat:@"Platform: %@\n", [device platform]];
    [emailBody appendFormat:@"Platform String: %@\n", [device platformString]];
    [emailBody appendFormat:@"iOS version: %@\n", [device systemVersion]];
    [picker setMessageBody:emailBody isHTML:NO];
    [self presentViewController:picker animated:YES completion:nil];
}
- (void)alertWithTitle: (NSString *)_title_ msg: (NSString *)msg

{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = msg;
    [hud hide:YES afterDelay:1.25];
    
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error

{
    
    NSString *title = NSLocalizedString(@"发送状态",nil);
    
    NSString *msg;
    
    switch (result)
    
    {
            
        case MFMailComposeResultCancelled:
            
            msg = NSLocalizedString(@"Mail canceled",nil);//@"邮件发送取消";
            
            break;
            
        case MFMailComposeResultSaved:
            
            msg = NSLocalizedString(@"邮件保存成功",nil);//@"邮件保存成功";
            
            [self alertWithTitle:title msg:msg];
            
            break;
            
        case MFMailComposeResultSent:
            
            msg = NSLocalizedString(@"邮件发送成功",nil);//@"邮件发送成功";
            
            [self alertWithTitle:title msg:msg];
            
            break;
            
        case MFMailComposeResultFailed:
            
            msg = NSLocalizedString(@"邮件发送失败",nil);//@"邮件发送失败";
            
            [self alertWithTitle:title msg:msg];
            
            break;
            
        default:
            
            msg = NSLocalizedString(@"邮件尚未发送",nil);
            
            [self alertWithTitle:title msg:msg];
            
            break;
            
    }
    
    [self  dismissViewControllerAnimated:YES completion:nil];
    
}

@end
