//
//  finishedGoalsViewController.m
//  DaysInLine
//
//  Created by Eric Cao on 6/13/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "finishedGoalsViewController.h"
#import "topBarView.h"
#import "global.h"
#import "finishedTableViewCell.h"
#import "goalObj.h"
#import "CommonUtility.h"

@interface finishedGoalsViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *goalsTable;
@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) NSMutableArray *goalArray;
@end

@implementation finishedGoalsViewController
@synthesize db;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configTopbar];
    [self configDetailTable];
    [self prepareGoalsData];
    

//    [[CommonUtility sharedCommonUtility] addADWithY:0 InView:self.view OfRootVC:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)prepareGoalsData
{
    self.goalArray = [[NSMutableArray alloc] init];
    
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"mainVC/Could not open db.");
        return;
    }
    
    FMResultSet *rs = [db executeQuery:@"select * from GOALS where is_completed = ? order by finish_date desc", @1];
    while ([rs next]) {
        goalObj *oneItem = [[goalObj alloc] init];
        oneItem.goalID = [NSNumber numberWithInt: [rs intForColumn:@"goal_id"]];
        oneItem.themeOnly  = [rs stringForColumn:@"theme"];
        oneItem.goalType = [rs intForColumn:@"TYPE"];
        NSString *type = oneItem.goalType?NSLocalizedString(@"生活",nil):NSLocalizedString(@"工作",nil);
        oneItem.goalTheme = [NSString stringWithFormat:@"%@ > %@",type,oneItem.themeOnly];
        oneItem.finishDate  = [rs stringForColumn:@"finish_date"];
        
        oneItem.byTime = [rs intForColumn:@"byTime"];
        if (oneItem.byTime) {
            oneItem.targetTime = [rs doubleForColumn:@"target_time"];
            oneItem.doneTime = [rs doubleForColumn:@"done_time"];
            if (oneItem.targetTime < oneItem.doneTime) {
                oneItem.doneTime = oneItem.targetTime;
            }
        }else
        {
            oneItem.targetCount = [rs intForColumn:@"target_count"];
            oneItem.doneCount = [rs intForColumn:@"done_count"];
            if (oneItem.targetCount < oneItem.doneCount) {
                oneItem.doneCount = oneItem.targetCount;
            }
        }
        [self.goalArray addObject:oneItem];
        
    }

    [self.goalsTable reloadData];
    
}



-(void)configTopbar
{
    topBarView *topbar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topBarHeight)];
    topbar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topbar];
    [topbar.titleLabel  setText:NSLocalizedString(@"成就列表",nil)];
    
    UIButton * closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 30, 40, 40)];
    closeViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    closeViewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [closeViewButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    closeViewButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    [closeViewButton setTitleColor:   normalColor forState:UIControlStateNormal];
    [closeViewButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    closeViewButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:closeViewButton];
    
       
}
-(void)closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)configDetailTable
{
    
    self.goalsTable = [[UITableView alloc] initWithFrame:CGRectMake(16, topBarHeight + 5, SCREEN_WIDTH-32, SCREEN_HEIGHT - topBarHeight - 5 - 5)];
    self.goalsTable.showsVerticalScrollIndicator = NO;
    self.goalsTable.scrollEnabled = YES;
    self.goalsTable.backgroundColor = [UIColor clearColor];
    self.goalsTable.delegate = self;
    self.goalsTable.dataSource = self;
    self.goalsTable.canCancelContentTouches = YES;
    self.goalsTable.delaysContentTouches = YES;
    self.goalsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.goalsTable.layer.cornerRadius = 8;
    [self.view addSubview:self.goalsTable];
    
}

#pragma mark -
#pragma mark Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.goalArray.count;
}

- (finishedTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger itemID = -1;
    NSString *theme = @"";
    NSString *themeOnly = @"";
    
    //    NSString *description = @"";
    int itemType = -1;
    BOOL isByTime = -1;
    
    double timeDone = -1.0f;
    double timeTotal = -1.0f;
    NSString *finishDate = @"";
    NSString *totalNum = @"";
    
    if(self.goalArray.count>indexPath.row)
    {
        goalObj *oneGoal = self.goalArray[indexPath.row];
        itemID = [oneGoal.goalID integerValue];
        theme = oneGoal.goalTheme;
        itemType = oneGoal.goalType;
        isByTime = oneGoal.byTime;
        themeOnly = oneGoal.themeOnly;
        finishDate = oneGoal.finishDate;
        
        if (isByTime) {
            timeDone = oneGoal.doneTime;
            timeTotal = oneGoal.targetTime;
             totalNum = [NSString stringWithFormat:NSLocalizedString(@"共 %.2f 小时",nil),timeTotal];
        }else
        {
            timeDone = oneGoal.doneCount;
            timeTotal = oneGoal.targetCount;
            totalNum = [NSString stringWithFormat:NSLocalizedString(@"共 %ld 次",nil),(NSInteger)timeTotal];
        }
        
        
    }
    
    static NSString *CellItemIdentifier = @"CellFinished";
    finishedTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellItemIdentifier];
    if (cell == nil) {
        cell = [[finishedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellItemIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    [cell.themeLabel setText:theme];
    [cell.finishedDateLabel setText:[NSString stringWithFormat:NSLocalizedString(@"于 %@ 完成",nil),finishDate]];
    [cell.totalLabel setText:totalNum];

    return cell;
    
}

@end
