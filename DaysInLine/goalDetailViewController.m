//
//  goalDetailViewController.m
//  DaysInLine
//
//  Created by Eric Cao on 6/7/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "goalDetailViewController.h"
#import "topBarView.h"
#import "global.h"
#import "itemDetailTableViewCell.h"
#import "numberPadButton.h"
#import "categoryTableViewCell.h"
#import "categoryManagementViewController.h"
#import "CommonUtility.h"

@interface goalDetailViewController ()<UITableViewDataSource,UITableViewDelegate,showPadDelegate,categoryTapDelegate>
@property (nonatomic,strong) UITableView *goalInfoTable;
@property (nonatomic ,strong) UITableView *categoryTableView;
@property (nonatomic ,strong) UITableView *remindTable;

@property (nonatomic ,strong) UIButton *myDeleteButton;
@property (nonatomic ,strong) UIButton *myRemoveReminderButton;


@property (nonatomic ,strong) UIDatePicker *myRemindPicker;

@property (nonatomic,strong) NSArray *weekDays;
@property (nonatomic,strong) UIView *myDimView;
@property (nonatomic,strong) NSMutableArray *workCategoryArray;
@property (nonatomic,strong) NSMutableArray *lifeCategoryArray;
@property (nonatomic ,strong) UISegmentedControl *moneyTypeSeg;
@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic ,strong) UILabel *InputLabel;
@property (nonatomic ,strong) UILabel *categoryLabel;

@property (nonatomic ,strong) UISegmentedControl *goalByTimeSeg;
@property (nonatomic ,strong) NSString *InputNumberString;
@property (nonatomic ,strong) NSString *NumberToOperate;
@property (nonatomic ,strong) numberPadButton *plusBtn;
@property (nonatomic ,strong) numberPadButton *minusBtn;
@property BOOL doingPlus;
@property BOOL doingMinus;
@end

@implementation goalDetailViewController
@synthesize db;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.weekDays = [[CommonUtility sharedCommonUtility] weekDays];
    [self configTopbar];
    [self configDetailTable];
    if (self.isEditing) {
        [self configButton];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.workCategoryArray = [[CommonUtility sharedCommonUtility] prepareCategoryDataForWork:YES];
    self.lifeCategoryArray = [[CommonUtility sharedCommonUtility] prepareCategoryDataForWork:NO];
    [MobClick beginLogPageView:@"goalDetail"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"goalDetail"];
}

-(void)configTopbar
{
    topBarView *topbar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topBarHeight)];
    topbar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topbar];
    
    if (self.isEditing) {
        [topbar.titleLabel  setText:NSLocalizedString(@"目标编辑",nil)];
    }else
    {
        [topbar.titleLabel  setText:NSLocalizedString(@"新增目标",nil)];
    }
    
    UIButton * closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 30, 40, 40)];
    closeViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    closeViewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [closeViewButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    closeViewButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    [closeViewButton setTitleColor:   normalColor forState:UIControlStateNormal];
    [closeViewButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    closeViewButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:closeViewButton];
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-52, 30, 40, 40)];
    saveButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    saveButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [saveButton setImage:[UIImage imageNamed:@"done"] forState:UIControlStateNormal];
    saveButton.imageEdgeInsets = UIEdgeInsetsMake(3.9, 3.9,3.9, 3.9);
    [saveButton setTitleColor:   normalColor forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveGoal) forControlEvents:UIControlEventTouchUpInside];
    saveButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:saveButton];
    
}


-(void)configButton
{
    if (!self.myDeleteButton) {
        UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/5, SCREEN_HEIGHT - SCREEN_WIDTH/3, SCREEN_WIDTH/5,SCREEN_WIDTH/5+15 )];
        [deleteButton setImage:[UIImage imageNamed:@"trush"] forState:UIControlStateNormal];
        deleteButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 15, 0);
        [deleteButton addTarget:self action:@selector(deleteTap) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *explainDelete = [[UILabel alloc] initWithFrame:CGRectMake(0, deleteButton.frame.size.height - 15, deleteButton.frame.size.width, 15)];
        explainDelete.textAlignment = NSTextAlignmentCenter;
        explainDelete.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
        [explainDelete setText:NSLocalizedString(@"删除",nil)];
        [explainDelete setTextColor:normalColor];
        [deleteButton addSubview:explainDelete];
        [self.view addSubview:deleteButton];

        self.myDeleteButton = deleteButton;

    }
    
    if (!self.myRemoveReminderButton) {
        UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-SCREEN_WIDTH/5-SCREEN_WIDTH/5, SCREEN_HEIGHT - SCREEN_WIDTH/3,SCREEN_WIDTH/5,SCREEN_WIDTH/5 + 15)];
        [editButton setImage:[UIImage imageNamed:@"noReminder"] forState:UIControlStateNormal];
        editButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 15, 0);
        [editButton addTarget:self action:@selector(removeRemind) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *explainEdit = [[UILabel alloc] initWithFrame:CGRectMake(0, editButton.frame.size.height - 15, editButton.frame.size.width, 15)];
        explainEdit.textAlignment = NSTextAlignmentCenter;
        explainEdit.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
        [explainEdit setText:NSLocalizedString(@"不再提醒",nil)];
        [explainEdit setTextColor:normalColor];
        [editButton addSubview:explainEdit];
        
        [self.view addSubview:editButton];
        self.myRemoveReminderButton = editButton;

    }
    
    [self modifyButtons];
}

-(void)modifyButtons
{
    if (!self.remindTime || [self.remindTime isEqualToString:@""]) {
        [self.myRemoveReminderButton setHidden:YES];
        [self.myDeleteButton setFrame:CGRectMake(SCREEN_WIDTH/2 - SCREEN_WIDTH/10, SCREEN_HEIGHT - SCREEN_WIDTH/3, SCREEN_WIDTH/5,SCREEN_WIDTH/5+15 )];
    }else
    {
        [self.myDeleteButton setFrame:CGRectMake(SCREEN_WIDTH/5, SCREEN_HEIGHT - SCREEN_WIDTH/3, SCREEN_WIDTH/5,SCREEN_WIDTH/5+15)];
        [self.myRemoveReminderButton setHidden:NO];
    }
}

-(void)deleteTap
{
    NSInteger itemID = [self.currentIGoalID integerValue];
    if(itemID >=0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"永久删除该目标?",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"不",nil)  otherButtonTitles:NSLocalizedString(@"是的",nil), nil];
        alert.tag = 77;
        [alert show];
        
    }
}
-(void)removeRemind
{
    NSInteger itemID = [self.currentIGoalID integerValue];
    if(itemID >=0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"取消此提醒?",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"不",nil)  otherButtonTitles:NSLocalizedString(@"是的",nil), nil];
        alert.tag = 88;
        [alert show];
        
    }
}



-(int)searchEventID
{
    int recorderID = 0;
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"mainVC/Could not open db.");
        return recorderID;
    }
    
    if (self.isEditing) {
        return [self.currentIGoalID intValue];
    }else
    {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM SQLITE_SEQUENCE WHERE name='GOALS'"];
        if ([rs next]) {
            recorderID = [rs intForColumn:@"seq"];
        }
        
        [db close];
        return recorderID;
    }
    
}

-(void)closeVC
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)saveGoal
{
    NSLog(@"saving goal...");
    if (![self validateData]) {
        return;
    }
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"goalDetailVC/Could not open db.");
        return;
    }
    
    NSNumber *totalTime = @-1.0f;
    NSNumber *totalCount = @-1;
    if (self.isByTime) {
        totalTime = [NSNumber numberWithDouble:[self.totalNum doubleValue]];
    }else
    {
        totalCount = [NSNumber numberWithInt:[self.totalNum intValue]];
    }
    
    NSString *reminderDays = @"";
    for (NSString *oneDay in self.remindDays) {
        reminderDays = [reminderDays stringByAppendingString:[NSString stringWithFormat:@"%@,",oneDay]];
    }
    if (reminderDays.length>0) {
        reminderDays  = [reminderDays substringToIndex:reminderDays.length - 1];
    }
    if (!self.remindTime) {
        self.remindTime = @"";
    }
    
    if (self.isEditing) {
        
        
        BOOL sql = [db executeUpdate:@"update GOALS set TYPE=? ,byTime = ? ,target_time = ? ,target_count = ? ,remind_time = ?, remind_days = ?, is_completed = ? where goal_id = ?" ,[NSNumber numberWithInt:self.goalType],[NSNumber numberWithInt:self.isByTime],totalTime,totalCount,self.remindTime,reminderDays,@0,self.currentIGoalID];
        if (!sql) {
            NSLog(@"ERROR123: %d - %@", db.lastErrorCode, db.lastErrorMessage);
        }else
        {
            [self dismissViewControllerAnimated:YES completion:nil];
            
            [MobClick event:@"editGoal"];
        }
    }else
    {
        FMResultSet *rs = [db executeQuery:@"select * from GOALS where TYPE = ? AND theme = ? AND is_completed = ?", [NSNumber numberWithInt:self.goalType],self.category,@0];
        if ([rs next]) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.animationType = MBProgressHUDAnimationZoom;
            hud.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = NSLocalizedString(@"该目标已经存在",nil) ;
            [hud hide:YES afterDelay:1.5];
            return;
        }
        
        BOOL sql = [db executeUpdate:@"INSERT INTO GOALS(TYPE,theme,byTime,target_time,target_count,done_time,done_count,remind_time,remind_days,is_completed) VALUES(?,?,?,?,?,?,?,?,?,?)" ,[NSNumber numberWithInt:self.goalType],self.category,[NSNumber numberWithInt:self.isByTime],totalTime,totalCount,@0,@0,self.remindTime,reminderDays,@0];
        
        if (!sql) {
            NSLog(@"ERROR: %d - %@", db.lastErrorCode, db.lastErrorMessage);
        }else
        {
            [self dismissViewControllerAnimated:YES completion:nil];
            if (self.goalType == 0) {
                [MobClick event:@"addWorkGoal"];
            }else
            {
                [MobClick event:@"addLifeGoal"];
            }
            
        }
        
    }
    [db close];
    
    [self setNotificationsForGoal:[self searchEventID]];
    
    
    
}


-(BOOL)validateData
{
    if (!self.category) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.animationType = MBProgressHUDAnimationZoom;
        hud.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"请选择一个主题",nil) ;
        [hud hide:YES afterDelay:1.5];
        
        return NO;
    }else if (!self.totalNum)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.animationType = MBProgressHUDAnimationZoom;
        hud.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"请设置您的目标",nil);
        [hud hide:YES afterDelay:1.5];
        return NO;
        
    }
    
    return YES;
}

-(void)configDetailTable
{
    CGFloat height ;
    if (IS_IPHONE_4_OR_LESS) {
        height =65;
    }else
    {
        height =80;
    }
    
    self.goalInfoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, topBarHeight + 5, SCREEN_WIDTH, height*3 )];
    self.goalInfoTable.showsVerticalScrollIndicator = NO;
    self.goalInfoTable.scrollEnabled = NO;
    self.goalInfoTable.backgroundColor = [UIColor clearColor];
    self.goalInfoTable.delegate = self;
    self.goalInfoTable.dataSource = self;
    self.goalInfoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.goalInfoTable];
    
}

#pragma mark tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.remindTable) {
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.remindTable) {
        
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.categoryTableView)
    {
        return ((int)(SCREEN_WIDTH/8));
    }else if(tableView == self.remindTable)
    {
        return 35;
    } else
    {
        if (IS_IPHONE_4_OR_LESS) {
            return 62;
        }else
        {
            return 80;
        }
        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (tableView == self.categoryTableView)
    {
        if (self.moneyTypeSeg.selectedSegmentIndex == 0) {
            return (self.workCategoryArray.count/4) + 1;
        }else
        {
            return (self.lifeCategoryArray.count/4) + 1;
        }
        
    }else if(tableView == self.remindTable)
    {
        return 7;
    }else
        return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.categoryTableView)
    {
        NSString *CellIdentifier = @"categoryCell";
        
        categoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[categoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier andWidth:tableView.frame.size.width];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.categoryDelegate = self;
            
        }
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        if (self.moneyTypeSeg.selectedSegmentIndex == 0) {
            if (self.workCategoryArray.count/4 > indexPath.row)
            {
                for (NSInteger  i = 4* indexPath.row; i < 4* (indexPath.row + 1); i++) {
                    [tempArray addObject:self.workCategoryArray[i]];
                }
            }else
            {
                for (NSInteger  i = 4* indexPath.row; i < self.workCategoryArray.count; i++) {
                    [tempArray addObject:self.workCategoryArray[i]];
                }
            }
        }else
        {
            if (self.lifeCategoryArray.count/4 > indexPath.row)
            {
                for (NSInteger  i = 4* indexPath.row; i < 4* (indexPath.row + 1); i++) {
                    [tempArray addObject:self.lifeCategoryArray[i]];
                }
            }else
            {
                for (NSInteger  i = 4* indexPath.row; i < self.lifeCategoryArray.count; i++) {
                    [tempArray addObject:self.lifeCategoryArray[i]];
                }
            }
        }
        [cell contentWithCategories:tempArray];
        
        return cell;
        
    }
    else if(tableView == self.remindTable)
    {
        NSString *CellIdentifier = @"remindCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            
        }
        [cell.textLabel setText:[NSString stringWithFormat:NSLocalizedString(@"每%@",nil),self.weekDays[indexPath.row]]];
        cell.textLabel.textColor =  [UIColor colorWithWhite:0.2f alpha:1.0f];
        for (NSString *oneDay in self.remindDays) {
            if ([oneDay isEqualToString:@""]) {
                cell.accessoryType = UITableViewCellAccessoryNone;
                continue;
            }
            NSInteger index = [oneDay integerValue];
            if (indexPath.row == index) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                
                break;
            }else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
        return cell;
    }
    NSString *CellIdentifier = @"goalInfoCell";
    itemDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[itemDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        
    }
    [cell.leftText setTextColor:self.myTextColor];
    [cell.rightText setTitleColor:self.myTextColor forState:UIControlStateNormal];
    cell.rightText.titleLabel.numberOfLines = 1;
    
    cell.padDelegate = self;
    cell.rightText.tag = indexPath.row + 10;
    
    switch (indexPath.row) {
        case 0:
            [cell.leftText  setText:NSLocalizedString(@" 主 题",nil)] ;

            if(self.category)
            {
                [cell removeExpend];
                if (self.isEditing) {
                    NSString *type = self.goalType?NSLocalizedString(@"生活",nil):NSLocalizedString(@"工作",nil);
                    NSString *theme = [NSString stringWithFormat:@"%@ > %@",type,self.category];
                    [cell.rightText setTitle:theme forState:UIControlStateNormal];
                    [cell.rightText setEnabled:NO];
                }else
                {
                    NSString *type = self.goalType?NSLocalizedString(@"生活",nil):NSLocalizedString(@"工作",nil);
                    NSString *theme = [NSString stringWithFormat:@"%@ > %@",type,self.category];
                    [cell.rightText setTitle:theme forState:UIControlStateNormal];
                }
            }else
            {
                [cell addExpend];
                [cell.rightText setTitle:NSLocalizedString(@"请选择",nil) forState:UIControlStateNormal];
                [cell.rightText setTitleColor:[self.myTextColor colorWithAlphaComponent:0.9f] forState:UIControlStateNormal];
            }
            break;
        case 1:
            
            [cell addExpend];
            
            if(self.totalNum)
            {
                
                if (self.isByTime) {
                    [cell.leftText setText: NSLocalizedString(@"目标时间:",nil)];
                    [cell.rightText setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@小时",nil),self.totalNum] forState:UIControlStateNormal];
                }else
                {
                    [cell.leftText setText: NSLocalizedString(@"目标次数:",nil)];
                    [cell.rightText setTitle:[NSString stringWithFormat:NSLocalizedString(@"%ld次",nil),[self.totalNum integerValue]] forState:UIControlStateNormal];
                }
                
            }else
            {
                [cell.leftText setText: NSLocalizedString(@" 目 标:",nil)];
                
                [cell.rightText setTitle:NSLocalizedString(@"请选择",nil) forState:UIControlStateNormal];
                [cell.rightText setTitleColor:[self.myTextColor colorWithAlphaComponent:0.9f] forState:UIControlStateNormal];
            }
            break;
        case 2:
            [cell.leftText  setText: NSLocalizedString(@" 提 醒",nil)];

            if(self.remindTime && ![self.remindTime isEqualToString:@""])
            {
                [cell redrawRightButton:CGRectMake(cell.rightText.frame.origin.x, 10, cell.rightText.frame.size.width, 58)];
                cell.rightText.tag = indexPath.row + 10;
                cell.rightText.titleLabel.numberOfLines = 3;

//                [cell.rightText setFrame:CGRectMake(cell.rightText.frame.origin.x, cell.rightText.frame.origin.y-10, cell.rightText.frame.size.width, 60)];
                cell.rightText.titleLabel.font = [UIFont fontWithName:@"Avenir-Book" size:14.0f];
                
                NSString *remindWeekDay = @"";
                for (NSString *oneDay in self.remindDays) {
                    if ([oneDay isEqualToString:@""]) {
                        continue;
                    }
                    NSInteger index = [oneDay integerValue];
                    remindWeekDay = [remindWeekDay stringByAppendingString:[NSString stringWithFormat:@"%@,",self.weekDays[index]]];
                }
                if (remindWeekDay.length>0) {
                    remindWeekDay  = [remindWeekDay substringToIndex:remindWeekDay.length - 1];
                }
                NSString *reminder = [self.remindTime stringByAppendingString:[NSString stringWithFormat:@"\n%@",remindWeekDay]];
                [cell.rightText setTitle:reminder forState:UIControlStateNormal];
                
            }else
            {
                [cell redrawRightButton:CGRectMake(cell.leftText.frame.origin.x + cell.leftText.frame.size.width +10, cell.leftText.frame.origin.y, SCREEN_WIDTH*3/5 -10 - 20-20 -10, 30)];
                cell.rightText.tag = indexPath.row + 10;
                cell.rightText.titleLabel.numberOfLines = 1;
                cell.rightText.titleLabel.font = [UIFont fontWithName:@"Avenir-Book" size:14.0f];

                [cell addExpend];
                [cell.rightText setTitle:NSLocalizedString(@"请选择",nil) forState:UIControlStateNormal];
                [cell.rightText setTitleColor:[self.myTextColor colorWithAlphaComponent:0.9f] forState:UIControlStateNormal];
            }
            break;
            
        case 3:
            
            break;
            
        default:
            break;
    }
    return cell;
}

-(void)configNumberPadInView:(UIView *)content
{
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:NSLocalizedString(@"次数",nil),NSLocalizedString(@"时间",nil),nil];
    self.goalByTimeSeg = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    self.goalByTimeSeg.frame = CGRectMake(SCREEN_WIDTH*2/7, 8, SCREEN_WIDTH*3/7, 30);
    self.goalByTimeSeg.tintColor =  TextColor2;
    self.goalByTimeSeg.selectedSegmentIndex = self.isByTime;
    [self.goalByTimeSeg addTarget:self action:@selector(goalAction:)forControlEvents:UIControlEventValueChanged];  //添加委托方法
    [content addSubview:self.goalByTimeSeg];
    if (self.isEditing) {
        [self.goalByTimeSeg setHidden:YES];
    }else
    {
        [self.goalByTimeSeg setHidden:NO];
    }
    
    self.InputLabel = [[UILabel alloc] initWithFrame:CGRectMake(categoryLabelWith + 10,self.goalByTimeSeg.frame.size.height + self.goalByTimeSeg.frame.origin.y + 5, content.frame.size.width - categoryLabelWith - 20, SCREEN_WIDTH/4-15)];
    
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                 @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                   UIFontDescriptorNameAttribute:@"HelveticaNeue-Thin",
                                                   UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: 42.0f]
                                                   }];
    
    [self.InputLabel setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0]];
    self.InputLabel.textColor = self.myTextColor;
    self.InputLabel.textAlignment = NSTextAlignmentRight;
    self.InputLabel.adjustsFontSizeToFitWidth = YES;
    [content addSubview:self.InputLabel];
    [self.InputLabel setText:self.totalNum];
    
    
    self.categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,  self.InputLabel.frame.origin.y, categoryLabelWith, self.InputLabel.frame.size.height)];
    
    UIFontDescriptor *categoryFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                  UIFontDescriptorNameAttribute:@"HelveticaNeue-Thin",
                                                  UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: 32.0f]
                                                  }];
    
    [self.categoryLabel setFont:[UIFont fontWithDescriptor:categoryFontDescriptor size:0.0]];
    self.categoryLabel.textColor = self.myTextColor;
    self.categoryLabel.textAlignment = NSTextAlignmentCenter;
    self.categoryLabel.adjustsFontSizeToFitWidth = YES;
    if (self.isByTime) {
        [self.categoryLabel setText:NSLocalizedString(@"小 时",nil)];
    }else
    {
        [self.categoryLabel setText:NSLocalizedString(@"次 数",nil)];
    }
    [content addSubview:self.categoryLabel];
    
    
    self.InputNumberString = @"";
    self.NumberToOperate = @"0";
    if (!self.InputLabel.text) {
        [self.InputLabel setText:@"0"];
    }
    
    
    UIView *numberPadView = [[UIView alloc] initWithFrame:CGRectMake(0, content.frame.size.height - (content.frame.size.width)*7/10 - 10, content.frame.size.width, (content.frame.size.width)*7/10)];
    numberPadView.backgroundColor = [UIColor blackColor];
    [content addSubview:numberPadView];
    
    CGFloat buttonWidth = (numberPadView.frame.size.width-2)/4 ;
    CGFloat buttonHeight = (numberPadView.frame.size.height-2)/4  ;
    
    for (int i = 0; i<4; i++) { // 4 coloum
        for (int j = 0; j<4; j++) {  // 4 row
            numberPadButton * btn = [[numberPadButton alloc] initWithFrame:CGRectMake(1+i * (buttonWidth), 1+j*(buttonHeight), buttonWidth, buttonHeight)];
            
            btn.tag = j*4+i+1;
            [btn setupSymbols];
            [numberPadView addSubview:btn];
            if (btn.tag == 8) {
                self.plusBtn = btn;
                self.doingPlus = NO;
            }else if(btn.tag ==12)
            {
                self.minusBtn =btn;
                self.doingMinus = NO;
            }
            [btn setTitle:[NSString stringWithFormat:@"%@",btn.symbolText] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(keyTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            
        }
    }
}
-(void)keyTapped:(numberPadButton *)sender
{
    if (sender.isNumber ){
        
        if (!self.plusBtn.enabled || !self.minusBtn.enabled) {
            self.InputNumberString = @"";
            [self.InputLabel setText:@""];
            
            [self.plusBtn keyNotSelectedStyle];
            [self.minusBtn keyNotSelectedStyle];
        }
        
        
        NSString *intPart = [self.InputLabel .text componentsSeparatedByString:@"."][0];
        if (intPart.length>10) {
            return;
        }
        if (sender.tag == 15 && [self.InputNumberString rangeOfString:@"."].length != 0)  {
            /* represent " . " key*/
            return;
        }else
        {
            self.InputNumberString =  [self.InputNumberString stringByAppendingString:sender.symbolText];
            
            if ( [self.InputNumberString rangeOfString:@"."].length != 0)  {
                NSString *clean = [NSString stringWithFormat:@"%.2f", [self.InputNumberString doubleValue]];
                [self.InputLabel setText:clean];
            }else
            {
                NSString *clean = [NSString stringWithFormat:@"%lld", [self.InputNumberString longLongValue]];
                [self.InputLabel setText:clean];
                
            }
        }
    }else
    {
        if(sender.tag == 4) // delete button
        {
            if (!self.plusBtn.enabled || !self.minusBtn.enabled) {
                [self.plusBtn keyNotSelectedStyle];
                [self.minusBtn keyNotSelectedStyle];
                self.doingMinus = NO;
                self.doingPlus = NO;
                
            }
            
            self.InputNumberString = self.InputLabel.text;
            if (self.InputNumberString.length == 0) {
                return;
            }else if (self.InputNumberString.length == 1) {
                self.InputNumberString = @"0";
            }else
            {
                self.InputNumberString = [self.InputNumberString substringToIndex:self.InputNumberString.length-1];
            }
            [self.InputLabel setText:self.InputNumberString];
        }
        
        if(sender.tag == 8) // ' + ' button
        {
            if (!self.minusBtn.enabled) {
                [self.minusBtn keyNotSelectedStyle];
                [sender keySelectedStyle];
                self.doingPlus = YES;
                self.doingMinus= NO;
                return;
            }
            
            if ([self.NumberToOperate doubleValue] > 0.0001 || [self.NumberToOperate doubleValue] < -0.0001) {
                
                if (self.doingPlus) {
                    double result = self.InputLabel.text.doubleValue + self.NumberToOperate.doubleValue;
                    NSString *resultText = [NSString stringWithFormat:@"%.2f",result];
                    if ([resultText rangeOfString:@".00"].length != 0) {
                        resultText = [resultText componentsSeparatedByString:@"."][0];
                    }
                    [self.InputLabel setText:resultText];
                }else if (self.doingMinus) {
                    double result = self.NumberToOperate.doubleValue - self.InputLabel.text.doubleValue;
                    if (result<0.0001) {
                        [self.InputLabel setText:@"0"];
                    }else
                    {
                        NSString *resultText = [NSString stringWithFormat:@"%.2f",result];
                        if ([resultText rangeOfString:@".00"].length != 0) {
                            resultText = [resultText componentsSeparatedByString:@"."][0];
                        }
                        [self.InputLabel setText:resultText];
                    }
                }
            }
            [sender keySelectedStyle];
            self.doingPlus = YES;
            self.doingMinus= NO;
            self.NumberToOperate = self.InputLabel.text;
            
        }
        
        if(sender.tag == 12) // ' - ' button
        {
            if (!self.plusBtn.enabled) {
                [self.plusBtn keyNotSelectedStyle];
                [sender keySelectedStyle];
                self.doingMinus = YES;
                self.doingPlus = NO;
                return;
            }
            
            if ([self.NumberToOperate doubleValue] > 0.0001 || [self.NumberToOperate doubleValue] < -0.0001) {
                
                if (self.doingPlus) {
                    double result = self.InputLabel.text.doubleValue + self.NumberToOperate.doubleValue;
                    NSString *resultText = [NSString stringWithFormat:@"%.2f",result];
                    if ([resultText rangeOfString:@".00"].length != 0) {
                        resultText = [resultText componentsSeparatedByString:@"."][0];
                    }
                    [self.InputLabel setText:resultText];
                }else if (self.doingMinus) {
                    double result = self.NumberToOperate.doubleValue - self.InputLabel.text.doubleValue;
                    if (result<0.0001) {
                        [self.InputLabel setText:@"0"];
                    }else
                    {
                        NSString *resultText = [NSString stringWithFormat:@"%.2f",result];
                        if ([resultText rangeOfString:@".00"].length != 0) {
                            resultText = [resultText componentsSeparatedByString:@"."][0];
                        }
                        [self.InputLabel setText:resultText];
                    }
                }
            }
            [sender keySelectedStyle];
            self.doingMinus = YES;
            self.doingPlus = NO;
            self.NumberToOperate = self.InputLabel.text;
            
        }
        
        if(sender.tag == 16)
        {
            if (!self.plusBtn.enabled || !self.minusBtn.enabled) {
                [self.plusBtn keyNotSelectedStyle];
                [self.minusBtn keyNotSelectedStyle];
                self.doingMinus = NO;
                self.doingPlus = NO;
                
            }
            
            if ([self.NumberToOperate doubleValue] > 0.0001 || [self.NumberToOperate doubleValue] < -0.0001) {
                
                if (self.doingPlus) {
                    double result = self.InputLabel.text.doubleValue + self.NumberToOperate.doubleValue;
                    NSString *resultText = [NSString stringWithFormat:@"%.2f",result];
                    if ([resultText rangeOfString:@".00"].length != 0) {
                        resultText = [resultText componentsSeparatedByString:@"."][0];
                    }
                    [self.InputLabel setText:resultText];
                }else if (self.doingMinus) {
                    double result = self.NumberToOperate.doubleValue - self.InputLabel.text.doubleValue;
                    if (result<0.0001) {
                        [self.InputLabel setText:@"0"];
                    }else
                    {
                        NSString *resultText = [NSString stringWithFormat:@"%.2f",result];
                        if ([resultText rangeOfString:@".00"].length != 0) {
                            resultText = [resultText componentsSeparatedByString:@"."][0];
                        }
                        [self.InputLabel setText:resultText];
                    }
                }else
                {
                    [self.InputLabel setText:self.NumberToOperate];
                }
                
                self.NumberToOperate = @"0";
                
            }
            
            if ([self.InputLabel.text isEqualToString:@"0"])
            {
                self.InputNumberString = @"";
            }else
            {
                self.InputNumberString = self.InputLabel.text;
            }
            
        }
    }
    
}



-(void)showingModelOfHeight:(CGFloat)height andColor:(UIColor *)backColor forRow:(NSInteger)row
{
    UIView *contentView;
    UIView *gestureView;
    UIView *dimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    dimView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.7];
    [self.view addSubview:dimView];
    self.myDimView = dimView;
    gestureView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT- height)];
    gestureView.backgroundColor = [UIColor clearColor];
    gestureView.tag = 101;
    [dimView addSubview:gestureView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissDimView)];
    
    [gestureView addGestureRecognizer:tap];
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(10, SCREEN_HEIGHT, SCREEN_WIDTH-20, height)];
    contentView.tag = 100;
    contentView.backgroundColor = backColor;
    [dimView addSubview:contentView];
    contentView.layer.cornerRadius = 10;
    
    
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionLayoutSubviews animations:^{
        if (contentView) {
            [contentView setFrame:CGRectMake(contentView.frame.origin.x, SCREEN_HEIGHT- (height-10), contentView.frame.size.width, contentView.frame.size.height)];
        }
    } completion:nil ];
    
    if (row == 0) {
        
        NSArray *segmentedArray = [[NSArray alloc]initWithObjects:NSLocalizedString(@"工作",nil),NSLocalizedString(@"生活",nil),nil];
        self.moneyTypeSeg = [[UISegmentedControl alloc]initWithItems:segmentedArray];
        self.moneyTypeSeg.frame = CGRectMake(SCREEN_WIDTH*2/7, 8, SCREEN_WIDTH*3/7, 30);
        self.moneyTypeSeg.tintColor =  TextColor2;
        self.moneyTypeSeg.selectedSegmentIndex = 0;
        [self.moneyTypeSeg addTarget:self action:@selector(segmentAction:)forControlEvents:UIControlEventValueChanged];  //添加委托方法
        [contentView addSubview:self.moneyTypeSeg];
        
        UITableView *categoryTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 48, SCREEN_WIDTH-20, contentView.frame.size.height-48)];
        categoryTable.showsVerticalScrollIndicator = YES;
        categoryTable.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        categoryTable.backgroundColor = [UIColor clearColor];
        categoryTable.delegate = self;
        categoryTable.dataSource = self;
        categoryTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        categoryTable.canCancelContentTouches = YES;
        categoryTable.delaysContentTouches = YES;
        self.categoryTableView = categoryTable;
        [contentView addSubview:categoryTable];
    }else if (row == 1 )
    {
        [self configNumberPadInView:contentView];
        
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(8, 5, 60, 35)];
        [cancelBtn setTitle:NSLocalizedString(@"取消",nil) forState:UIControlStateNormal];
        [cancelBtn setTitleColor:self.myTextColor forState:UIControlStateNormal];
        cancelBtn.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue" size:15.0];
        [contentView addSubview:cancelBtn];
        
        UIButton *selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(contentView.frame.size.width-68, 5, 60, 35)];
        [selectBtn setTitle:NSLocalizedString(@"确定",nil) forState:UIControlStateNormal];
        [selectBtn setTitleColor:self.myTextColor forState:UIControlStateNormal];
        selectBtn.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        [contentView addSubview:selectBtn];
        selectBtn.tag = 20+row;
        
        [cancelBtn addTarget:self action:@selector(cancelSetting) forControlEvents:UIControlEventTouchUpInside];
        [selectBtn addTarget:self action:@selector(goalChoose:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
    }else if(row == 2)
    {
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(8, 5, 60, 35)];
        [cancelBtn setTitle:NSLocalizedString(@"取消",nil) forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor colorWithWhite:0.2f alpha:1.0f] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue" size:15.0];
        [contentView addSubview:cancelBtn];
        
        UIButton *selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(contentView.frame.size.width-68, 5, 60, 35)];
        [selectBtn setTitle:NSLocalizedString(@"确定",nil) forState:UIControlStateNormal];
        [selectBtn setTitleColor:[UIColor colorWithWhite:0.35f alpha:0.9f] forState:UIControlStateNormal];
        selectBtn.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        [contentView addSubview:selectBtn];
        selectBtn.tag = 20+row;
        
        [cancelBtn addTarget:self action:@selector(cancelSetting) forControlEvents:UIControlEventTouchUpInside];
        [selectBtn addTarget:self action:@selector(goalChoose:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *timeTitle = [[UILabel alloc] initWithFrame:CGRectMake(contentView.frame.size.width/2 - 100, 8, 200, 20)];
        [timeTitle setText:NSLocalizedString(@"提醒时间",nil)];
        [timeTitle setTextColor:[UIColor colorWithWhite:0.35f alpha:0.9f]];
        timeTitle.textAlignment = NSTextAlignmentCenter;
        timeTitle.font =  [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        [contentView addSubview:timeTitle];
        
        UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(contentView.frame.size.width/2 - 150,timeTitle.frame.size.height + timeTitle.frame.origin.y + 10,300,150)];
        datePicker.datePickerMode = UIDatePickerModeTime;
        NSDate* date = [NSDate date];
        if (self.remindTime && ![self.remindTime isEqualToString:@""]) {
            [datePicker setDate:[[CommonUtility sharedCommonUtility] timeFromString:self.remindTime]];
        }else
        {
            [datePicker setDate:date];
        }
        [contentView addSubview:datePicker];
        self.myRemindPicker = datePicker;
        
        UILabel *pickerTitle = [[UILabel alloc] initWithFrame:CGRectMake(contentView.frame.size.width/2 - 100, datePicker.frame.size.height + datePicker.frame.origin.y + 8, 200, 20)];
        [pickerTitle setText:NSLocalizedString(@"提醒日期",nil)];
        [pickerTitle setTextColor:[UIColor colorWithWhite:0.35f alpha:0.9f]];
        pickerTitle.textAlignment = NSTextAlignmentCenter;
        pickerTitle.font =  [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        [contentView addSubview:pickerTitle];
        
        UITableView *repeatTable = [[UITableView alloc] initWithFrame:CGRectMake(0, pickerTitle.frame.size.height + pickerTitle.frame.origin.y + 5, SCREEN_WIDTH-20, 35*7)];
        repeatTable.showsVerticalScrollIndicator = NO;
        repeatTable.scrollEnabled = NO;
        repeatTable.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        repeatTable.backgroundColor = [UIColor clearColor];
        repeatTable.delegate = self;
        repeatTable.dataSource = self;
        repeatTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        repeatTable.canCancelContentTouches = YES;
        repeatTable.delaysContentTouches = YES;
        repeatTable.allowsMultipleSelection = YES;
        self.remindTable = repeatTable;
        [contentView addSubview:repeatTable];
        
        
        for (NSString *oneDay in self.remindDays) {
            if ([oneDay isEqualToString:@""]) {
                continue;
            }
            NSIndexPath *oneIndex = [NSIndexPath indexPathForRow:[oneDay integerValue] inSection:0];
            [self.remindTable selectRowAtIndexPath:oneIndex animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        
        
    }
}
#pragma mark cell delegate for show pad
-(void)showPad:(UIButton *)sender
{
    if (sender.tag - 10 == 0) {
        [self showingModelOfHeight:300 andColor:[UIColor colorWithRed:0.18f green:0.18f blue:0.18f alpha:1.0f] forRow:0];
    }else if (sender.tag - 10 == 1)
    {
        [self showingModelOfHeight:SCREEN_WIDTH*1.03 andColor:[UIColor colorWithRed:0.18f green:0.18f blue:0.18f alpha:1.0f] forRow:1];
    }else if (sender.tag -10 == 2)
    {
        [self showingModelOfHeight:480 andColor:[UIColor colorWithRed:0.85f green:0.85f blue:0.85f alpha:1.0f] forRow:2];
        
    }
}

-(void)dismissDimView
{
    UIView *contentView = [self.myDimView viewWithTag:100];
    [UIView animateWithDuration:0.32f animations:^{
        if (contentView) {
            [contentView setFrame:CGRectMake(contentView.frame.origin.x, SCREEN_HEIGHT, contentView.frame.size.width, contentView.frame.size.height)];
        }
    } completion:^(BOOL isfinished){
        [self.myDimView removeFromSuperview];
    }];
}
-(void)cancelSetting
{
    [self dismissDimView];
}

-(void)goalChoose:(UIButton *)sender
{
    if (sender.tag == 21) {
        self.isByTime = self.goalByTimeSeg.selectedSegmentIndex;
        self.totalNum = [NSString stringWithFormat:@"%@",self.InputLabel.text];
        if ([self.totalNum integerValue] <= 0) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.animationType = MBProgressHUDAnimationZoom;
            hud.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = NSLocalizedString(@"目标不能为0",nil);
            [hud hide:YES afterDelay:1.5];
            return;
        }
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [indexPaths addObject: indexPath];
        [self.goalInfoTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        
    }else if (sender.tag == 22)
    {
        if ([[self.remindTable indexPathsForSelectedRows] count] == 0 && self.remindDays.count == 0) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.animationType = MBProgressHUDAnimationZoom;
            hud.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = NSLocalizedString(@"请选择提醒日期",nil);
            [hud hide:YES afterDelay:1.5];
            return;
        }
        NSDate *reminder = self.myRemindPicker.date;
        self.remindTime = [[CommonUtility sharedCommonUtility] stringFromTime:reminder];
        NSMutableArray *selectedDays = [[NSMutableArray alloc] initWithCapacity:7];
        for (NSIndexPath *oneIndex in [self.remindTable indexPathsForSelectedRows]) {
            [selectedDays addObject:[NSString stringWithFormat:@"%ld",oneIndex.row]];
        }
        if (selectedDays.count>0) {
            self.remindDays = [NSArray arrayWithArray:selectedDays];
            self.remindDays = [self.remindDays sortedArrayUsingComparator:^(id a, id b) {
                return [a compare:b options:NSNumericSearch];
            }];
        }
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        [indexPaths addObject: indexPath];
        [self.goalInfoTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        
        [MobClick event:@"reminder"];
    }
    [self dismissDimView];
}

-(void)segmentAction:(UISegmentedControl *)Seg{
    NSInteger Index = Seg.selectedSegmentIndex;
    NSLog(@"Index %ld", (long)Index);
    [self.categoryTableView reloadData];
}

-(void)goalAction:(UISegmentedControl *)Seg{
    NSInteger Index = Seg.selectedSegmentIndex;
    NSLog(@"Index %ld", (long)Index);
    if (Index == 1) {
        [self.categoryLabel setText:NSLocalizedString(@"小 时",nil)];
    }else
    {
        [self.categoryLabel setText:NSLocalizedString(@"次 数",nil)];
    }
}

#pragma mark category delegate
-(void)categoryTap:(categoryButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:NSLocalizedString(@"+ 新主题",nil)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            categoryManagementViewController *exportVC = [[categoryManagementViewController alloc] initWithNibName:@"categoryManagementViewController" bundle:nil];
            [self presentViewController:exportVC animated:YES completion:nil];
        });
        [self dismissDimView];
        return;
    }
    self.category =sender.titleLabel.text;
    self.goalType =(int)self.moneyTypeSeg.selectedSegmentIndex;
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [indexPaths addObject: indexPath];
    [self.goalInfoTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self dismissDimView];
}

-(void)setNotificationsForGoal:(int)goalID
{
    NSCalendar *gregorian = [[NSCalendar alloc]  initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger dayofweek = [[gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]] weekday] -1;// this will give you current day of week
    
    if (self.remindDays.count>0) {
        db = [[CommonUtility sharedCommonUtility] db];
        if (![db open]) {
            NSLog(@"mainVC/Could not open db.");
            return;
        }
        

        FMResultSet *result = [db executeQuery:@"select  remind_time  from GOALS where goal_id = ?" ,self.currentIGoalID];
        if ([result next]) {
            NSString *remindTimeTemp = [result stringForColumnIndex:0];
            if (![remindTimeTemp isKindOfClass:[NSNull class]] &&![remindTimeTemp isEqualToString:@""]) {
                [self removeReminder:self.currentIGoalID];
            }
        }
        [db close];
    }
    
    for (NSString *oneDay in self.remindDays) {
        if ([oneDay isEqualToString:@""]) {
            continue;
        }
        NSInteger index = [oneDay integerValue];
        NSInteger dayInterval = (index + 7 - dayofweek)%7;
        NSString *dstDate = [[CommonUtility sharedCommonUtility] dateByAddingDate:[NSDate date] andDaysToAdd:dayInterval];
        NSString *dstTime = [NSString stringWithFormat:@"%@ %@:00",dstDate,self.remindTime];
        NSDate *fireTime = [[CommonUtility sharedCommonUtility] fullTimeFromString:dstTime];
        
//        self.remindDays = nil;
//        self.remindTime = @"";
        UILocalNotification *notification=[[UILocalNotification alloc] init];
        if (notification!=nil) {
            
            notification.fireDate=fireTime;
            
            notification.repeatInterval=NSWeekCalendarUnit;//循环次数，kCFCalendarUnitWeekday一周一次
            notification.timeZone=[NSTimeZone defaultTimeZone];
            notification.applicationIconBadgeNumber=1; //应用的红色数字
            notification.soundName= UILocalNotificationDefaultSoundName;//声音，可以换成alarm.soundName = @"myMusic.caf"
            //去掉下面2行就不会弹出提示框
            notification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"是时候开始<%@>了",nil),self.category];
            notification.hasAction = NO; //是否显示额外的按钮，为no时alertAction消失
            NSDictionary *infoDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:goalID] forKey:@"reminderID"];
            notification.userInfo = infoDict; //添加额外的信息
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 77) {

        if (buttonIndex ==1) {
            [MobClick event:@"deleteGoal"];
            
            db = [[CommonUtility sharedCommonUtility] db];
            if (![db open]) {
                NSLog(@"mainVC/Could not open db.");
                return;
            }
            
            NSString *sqlCommand = [NSString stringWithFormat:@"delete from GOALS where goal_id =%ld",(long) [self.currentIGoalID integerValue]];
            BOOL sql = [db executeUpdate:sqlCommand];
            if (!sql) {
                NSLog(@"ERROR: %d - %@", db.lastErrorCode, db.lastErrorMessage);
            }
            [db close];
            [self closeVC];
            
        }
    }else if (alertView.tag == 88) {
        
        if (buttonIndex ==1) {
            [MobClick event:@"deleteReminder"];
            
            db = [[CommonUtility sharedCommonUtility] db];
            if (![db open]) {
                NSLog(@"mainVC/Could not open db.");
                return;
            }
            
            self.remindDays = nil;
            self.remindTime = @"";
            
            BOOL sql = [db executeUpdate:@"update GOALS set remind_time = ?, remind_days = ? where goal_id = ?" ,@"",@"",self.currentIGoalID];
            if (!sql) {
                NSLog(@"ERROR123: %d - %@", db.lastErrorCode, db.lastErrorMessage);
            }else
            {
                [self removeReminder:self.currentIGoalID];
                [MobClick event:@"removeReminder"];
            }
            [db close];
            
            [self.goalInfoTable reloadData];
            [self modifyButtons];

        }
    }
}

-(void)removeReminder:(NSNumber *)goalID
{
    UIApplication *app = [UIApplication sharedApplication];
    
    //获取本地推送数组
    
    NSArray *localArray = [app scheduledLocalNotifications];
    
    //声明本地通知对象
    
    
    if (localArray) {
        
        for (UILocalNotification *noti in localArray) {
            
            NSDictionary *dict = noti.userInfo;
            
            if (dict) {
                
                NSNumber *inKey = [dict objectForKey:@"reminderID"];
                
                if ([inKey isEqualToNumber :goalID]) {
                    
                    [app cancelLocalNotification:noti];
                }
            }
        }
    }

}

@end
