//
//  checkEventViewController.m
//  DaysInLine
//
//  Created by Eric Cao on 6/2/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "checkEventViewController.h"
#import "global.h"
#import "topBarView.h"
#import "checkEventTableViewCell.h"
#import "CommonUtility.h"
#import "itemDetailViewController.h"
#import "RZTransitions.h"
#import "photoCell.h"

@interface checkEventViewController ()<UITableViewDataSource,UITableViewDelegate,reloadDataDelegate>
@property (nonatomic,strong) UITableView *itemInfoTable;
@property (nonatomic,strong) UITableView *photoTable;
@property (nonatomic,strong) NSMutableArray *photosArray;
@property (nonatomic,strong) topBarView *topBar;
@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) UILabel *itemMoneyLabel;
@property (nonatomic,strong)  AVAudioPlayer * player;

@end

@implementation checkEventViewController
@synthesize db;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.photosArray = [self preparePhotos:self.currentItem.photoNames];

    [self configTopbar];
    [self configDetailTable];
    [self configButton];
    
    
    [[RZTransitionsManager shared] setAnimationController:[[RZCirclePushAnimationController alloc] init]
                                       fromViewController:[self class]
                                                forAction:RZTransitionAction_PresentDismiss];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"checkEvent"];
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"checkEventViewController ->viewDidAppear");

}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"checkEvent"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshData
{
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"mainVC/Could not open db.");
        return;
    }
    
    
    
    FMResultSet *rs = [db executeQuery:@"select * from EVENTS where eventID = ?", self.currentItem.itemID];
    while ([rs next]) {
        itemObj *oneItem = [[itemObj alloc] init];
        oneItem.itemID = [NSNumber numberWithInt: [rs intForColumn:@"eventID"]];
        oneItem.itemCategory  = [rs stringForColumn:@"TITLE"];
        oneItem.itemDescription = [rs stringForColumn:@"mainText"];
        oneItem.itemType = [rs intForColumn:@"TYPE"];
        oneItem.targetTime = [rs stringForColumn:@"date"];
        oneItem.startTime = [rs doubleForColumn:@"startTime"];
        oneItem.endTime = [rs doubleForColumn:@"endTime"];
        
        self.currentItem = oneItem;
        
    }
    
    [self.itemInfoTable reloadData];
    
    [db close];
    
}

-(void)configTopbar
{
    self.topBar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH*3/7)];
    self.topBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.topBar];
    
    UIButton * closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 32, 40, 40)];
    closeViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    closeViewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [closeViewButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    closeViewButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    //    [closeViewButton setTitle:@"返回" forState:UIControlStateNormal];
    [closeViewButton setTitleColor:   normalColor forState:UIControlStateNormal];
    [closeViewButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    closeViewButton.backgroundColor = [UIColor clearColor];
    [self.topBar addSubview:closeViewButton];
    
    [self.topBar.titleLabel  setText:NSLocalizedString(@"事项明细",nil)];
    
    
    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, self.topBar.frame.size.height - 70,SCREEN_WIDTH - 80 ,70)];
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                 @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                   UIFontDescriptorNameAttribute:@"HelveticaNeue-Thin",
                                                   UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: 42.0f]
                                                   }];
    
    [moneyLabel setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0]];
    moneyLabel.textColor = self.myTextColor;
    moneyLabel.textAlignment = NSTextAlignmentCenter;
    moneyLabel.adjustsFontSizeToFitWidth = YES;
    NSString *typeString = ((self.currentItem.itemType == 0)?NSLocalizedString(@"工作",nil):NSLocalizedString(@"生活",nil));
    [moneyLabel setText:typeString];
    self.itemMoneyLabel  = moneyLabel;
    [self.topBar addSubview:moneyLabel];
    
}

-(void)configDetailTable
{
    self.itemInfoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH*3/7 + 10, SCREEN_WIDTH, (SCREEN_HEIGHT- SCREEN_WIDTH/2)*3/4)];
    self.itemInfoTable.showsVerticalScrollIndicator = NO;
    self.itemInfoTable.scrollEnabled = NO;
    self.itemInfoTable.backgroundColor = [UIColor clearColor];
    self.itemInfoTable.delegate = self;
    self.itemInfoTable.dataSource = self;
    self.itemInfoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.itemInfoTable.canCancelContentTouches = NO;
//    self.itemInfoTable.delaysContentTouches = NO;
    [self.view addSubview:self.itemInfoTable];
    
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.photoTable) {
        return tableView.frame.size.height;
    }else
    {
        if (indexPath.row == 4) {
            if (IS_IPHONE_4_OR_LESS) {
                return  80;
            }else
            {
                return  105;
            }
        }
        
        return ((int) SCREEN_WIDTH/8);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.photoTable) {
        return self.photosArray.count;
    }else if (self.currentItem.photoNames && ![self.currentItem.photoNames isEqualToString:@""]) {
        return 5;
    }else
        return 4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.photoTable) {
        NSString *CellIdentifier = @"CellPhoto";
        
        photoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[photoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.transform = CGAffineTransformMakeRotation(M_PI/2);
            
        }
        
        
        [cell configPhotoWitchRect:CGRectMake(5, 5, tableView.frame.size.height - 10, tableView.frame.size.height - 10) andPhoto:self.photosArray[indexPath.row]];
        
        return cell;
    }else
    {
        
        NSString *CellIdentifier = @"itemInfoCell";
        checkEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[checkEventTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            
        }
        [cell.leftText setTextColor:self.myTextColor];
        [cell.rightText setTextColor:self.myTextColor];
        
        NSString *startString = [[CommonUtility sharedCommonUtility] timeInLine:((int)self.currentItem.startTime)];
        NSString *endString = [[CommonUtility sharedCommonUtility] timeInLine:((int)self.currentItem.endTime)];
        
        NSString *strUrl = [[CommonUtility sharedCommonUtility] voicePathWithRecorderID:[self.currentItem.itemID intValue]];
        NSURL *url = [NSURL fileURLWithPath:strUrl];
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        
        NSString *theme = [NSString stringWithFormat:@"%@",self.currentItem.itemCategory];
        
        switch (indexPath.row) {
            case 0:
                [cell.leftText setText: NSLocalizedString(@"主题",nil)];
                [cell.rightText setText:theme];
                break;
            case 1:
                [cell.leftText  setText: NSLocalizedString(@"时段",nil)];
                
                [cell.rightText setText:[NSString stringWithFormat:@"%@ — %@",startString,endString]];
                
                break;
            case 2:
                [cell.leftText  setText:NSLocalizedString(@"事项备注",nil)] ;
                if (self.currentItem.itemDescription && ![self.currentItem.itemDescription isEqualToString:@""]) {
                    [cell.rightText setText:self.currentItem.itemDescription];
                }else
                {
                    [cell.rightText setText:NSLocalizedString(@"无",nil)];
                }
                break;
            case 3:
                [cell.leftText  setText:NSLocalizedString(@"语音备注",nil)] ;
                if (self.player) {
                    UIButton *audioButton = [[UIButton alloc] initWithFrame:CGRectMake(cell.rightText.frame.origin.x + cell.rightText.frame.size.width /6, cell.rightText.frame.size.height /12, cell.rightText.frame.size.width *5/6, cell.rightText.frame.size.height *5/6)];
                    audioButton.layer.borderWidth = 0.75f;
                    audioButton.layer.borderColor = normalColor.CGColor;
                    audioButton.layer.cornerRadius = 5;
                    [audioButton setTitle:NSLocalizedString(@"点击 播放",nil) forState:UIControlStateNormal];
                    [audioButton addTarget:self action:@selector(playVoice) forControlEvents:UIControlEventTouchUpInside];
                    [cell addSubview:audioButton];
                    
                }else
                {
                    [cell.rightText setText:NSLocalizedString(@"无",nil)];
                }
                break;
            case 4:
                
                [self configPhotoViewInView:cell];
                
                break;
                
            default:
                break;
        }
        return cell;
    }
}

-(void)playVoice
{
    if (self.player.playing) {
        [self.player stop];
        return;
    }
    [self.player play];
}

-(NSMutableArray *)preparePhotos:(NSString *)photoNames
{
    NSMutableArray *photosArray = [[NSMutableArray alloc] init];
    if (photoNames) {
        
        NSURL *storeURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.sheepcao.DaysInLine"];
        NSString *destPath = [storeURL path];
        NSArray *namesArray = [photoNames componentsSeparatedByString:@";"];
        for (int i = 0; i < namesArray.count; i++) {
            NSString *fullPath = [destPath stringByAppendingPathComponent:namesArray[i]];
            UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
            if (savedImage) {
                [photosArray addObject:savedImage];
            }
        }
    }
    
    return photosArray;
    
}

-(void)configPhotoViewInView:(UIView *)parentView
{
    CGFloat photoHeigh;
    if (IS_IPHONE_4_OR_LESS) {
        photoHeigh = 76 ;
    }else
    {
        photoHeigh = 100;
    }
    
    CGFloat f = (SCREEN_HEIGHT-SCREEN_WIDTH)*0.5-10;
    CGFloat offsite = 16;
    if (IS_IPHONE_4_OR_LESS) {
        offsite = -40;
    }
    self.photoTable = [[UITableView alloc]initWithFrame:CGRectMake(f-(offsite-16), -f + offsite, photoHeigh, SCREEN_WIDTH-20) style:UITableViewStylePlain];
//    [self.photoTable setCenter:CGPointMake((SCREEN_WIDTH-20)/2, self.itemInfoTable.frame.size.height + self.itemInfoTable.frame.origin.y + photoHeigh/2)];
    self.photoTable.dataSource = self;
    self.photoTable.delegate = self;
    self.photoTable.transform = CGAffineTransformMakeRotation(-M_PI/2);
    self.photoTable.backgroundColor = [UIColor clearColor];
    self.photoTable.pagingEnabled = YES;
    self.photoTable.showsVerticalScrollIndicator = NO;
    self.photoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *upline = [[UIView alloc] initWithFrame:CGRectMake(10,self.photoTable.frame.origin.y-1.5,self.photoTable.frame.size.width, 1.2)];
    upline.backgroundColor = normalColor;
    upline.layer.shadowOffset = CGSizeMake(0.5, 0.6);
    upline.layer.shadowColor = [UIColor blackColor].CGColor;
    upline.layer.shadowOpacity = 0.8;
    
    UIView *downline = [[UIView alloc] initWithFrame:CGRectMake(10,self.photoTable.frame.origin.y + self.photoTable.frame.size.height-1.5,self.photoTable.frame.size.width,1.2)];
    downline.backgroundColor = normalColor;
    downline.layer.shadowOffset = CGSizeMake(0.5, 0.6);
    downline.layer.shadowColor = [UIColor blackColor].CGColor;
    downline.layer.shadowOpacity = 0.8;
    [parentView addSubview:upline];
    [parentView addSubview:downline];
    
    [parentView addSubview:self.photoTable];
    
}



-(void)configButton
{
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/5, self.itemInfoTable.frame.origin.y + self.itemInfoTable.frame.size.height + 20, SCREEN_WIDTH/5,SCREEN_WIDTH/5 )];
    [deleteButton setImage:[UIImage imageNamed:@"trush"] forState:UIControlStateNormal];
    //    [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteTap) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-SCREEN_WIDTH/5-deleteButton.frame.size.width, deleteButton.frame.origin.y,deleteButton.frame.size.width,deleteButton.frame.size.height)];
    //    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [editButton setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
    
    [editButton addTarget:self action:@selector(editTap) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:deleteButton];
    [self.view addSubview:editButton];
    
}

-(void)deleteTap
{
    NSInteger itemID = [self.currentItem.itemID integerValue];
    if(itemID >=0)
    {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"永久删除该事项?",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"不",nil)  otherButtonTitles:NSLocalizedString(@"是的",nil), nil];
        alert.tag = 77;
        [alert show];
        
    }
}
-(void)editTap
{
    [self presentViewController:[self nextAddNewItemViewController] animated:YES completion:nil];
}

- (UIViewController *)nextAddNewItemViewController
{
    itemDetailViewController* addItemVC = [[itemDetailViewController alloc] init];
    addItemVC.isEditing =  YES;
    addItemVC.itemType = self.currentItem.itemType;
    addItemVC.currentItemID = self.currentItem.itemID;
    addItemVC.category = self.currentItem.itemCategory;
    addItemVC.itemDescription = self.currentItem.itemDescription;
    addItemVC.itemStartTime = [[CommonUtility sharedCommonUtility] doubleToTime:((int)self.currentItem.startTime)];
    addItemVC.itemEndTime = [[CommonUtility sharedCommonUtility] doubleToTime:((int)self.currentItem.endTime)];
    addItemVC.targetDate = self.currentItem.targetTime;
    addItemVC.photoNames =self.currentItem.photoNames;
    
    addItemVC.refreshDelegate = self;
    [addItemVC setTransitioningDelegate:[RZTransitionsManager shared]];
    
    return addItemVC;
}

-(void)closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==1) {
        [MobClick event:@"delete"];
        
        db = [[CommonUtility sharedCommonUtility] db];
        if (![db open]) {
            NSLog(@"mainVC/Could not open db.");
            return;
        }
        
        NSString *sqlCommand = [NSString stringWithFormat:@"delete from EVENTS where eventID=%ld",(long) [self.currentItem.itemID integerValue]];
        BOOL sql = [db executeUpdate:sqlCommand];
        if (!sql) {
            NSLog(@"ERROR: %d - %@", db.lastErrorCode, db.lastErrorMessage);
        }
        [db close];
        [self closeVC];

    }
}
@end
