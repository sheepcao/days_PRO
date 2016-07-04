//
//  summaryViewController.m
//  DaysInLine
//
//  Created by Eric Cao on 6/13/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "summaryViewController.h"
#import "topBarView.h"
#import "global.h"
#import "RATreeView.h"
#import "RADataObject.h"
#import "RATableViewCell.h"
#import "dayRATableViewCell.h"
#import "itemRATableViewCell.h"
#import "CommonUtility.h"
#import "itemObj.h"
#import "exportViewController.h"

@interface summaryViewController ()<RATreeViewDelegate, RATreeViewDataSource>
@property(nonatomic,strong)  RATreeView * treeView;
@property(nonatomic,strong) NSArray * data;
@property (nonatomic,strong) topBarView *topBar;
@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) NSMutableDictionary *monthlyDataDict;
@property (nonatomic,strong) UIButton *exportButton;
@end

@implementation summaryViewController
@synthesize db;
@synthesize exportButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareDB];
    
    [self configTopbar];
    [self configTable];
//    [[CommonUtility sharedCommonUtility] addADWithY:0 InView:self.view OfRootVC:self];

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"Flow"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"Flow"];
}


-(void)configTopbar
{
    self.topBar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topBarHeight)];
    self.topBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.topBar];
    [self.topBar.titleLabel  setText:NSLocalizedString(@"事项总览",nil)];
    
    
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
    
    exportButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 65, 35, 50, 40)];
    exportButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    exportButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [exportButton setTitle:NSLocalizedString(@"导出",nil) forState:UIControlStateNormal];
    [exportButton setTitleColor:   normalColor forState:UIControlStateNormal];
    [exportButton addTarget:self action:@selector(exportVC) forControlEvents:UIControlEventTouchUpInside];
    exportButton.backgroundColor = [UIColor clearColor];
    [self.topBar addSubview:exportButton];

}
-(void)closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)exportVC
{
    exportViewController *myExport = [[exportViewController alloc] initWithNibName:@"exportViewController" bundle:nil];
    [self.navigationController pushViewController:myExport animated:YES];
//
}

-(void)configTable
{
    self.treeView = [[RATreeView alloc] initWithFrame:CGRectMake(0, self.topBar.frame.size.height+5, SCREEN_WIDTH, SCREEN_HEIGHT - (self.topBar.frame.size.height+5))];
    self.treeView.backgroundColor = [UIColor clearColor];
    self.treeView.delegate = self;
    self.treeView.dataSource = self;
    self.treeView.separatorStyle = RATreeViewCellSeparatorStyleNone;
    
    [self.treeView reloadData];
    [self.view addSubview:self.treeView];
    [self.treeView registerNib:[UINib nibWithNibName:NSStringFromClass([RATableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([RATableViewCell class])];
    [self.treeView registerNib:[UINib nibWithNibName:NSStringFromClass([dayRATableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([dayRATableViewCell class])];
    [self.treeView registerNib:[UINib nibWithNibName:NSStringFromClass([itemRATableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([itemRATableViewCell class])];
}


- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item
{
    NSInteger level = [self.treeView levelForCellForItem:item];
    if (level  == 0) {
        return 70;
    }else if(level == 1)
    {
        return 50;
    }
    return 26;
}


- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(id)item
{
    NSInteger level = [self.treeView levelForCellForItem:item];
    RADataObject *dataObject = item;
    NSInteger numberOfChildren = [dataObject.children count];
    
    if (level == 0) {
        RATableViewCell *cell = (RATableViewCell *)[treeView cellForItem:item];
        if (numberOfChildren > 0) {
            [cell goExpendAnimated:YES];
        }
    }else if(level == 1)
    {
        dayRATableViewCell *cell = (dayRATableViewCell *)[treeView cellForItem:item];
        if (numberOfChildren > 0) {
            [cell goExpendAnimated:YES];
        }
    }else
    {
        
    }
    
    
    NSLog(@"expand");
}

- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(id)item
{
    NSInteger level = [self.treeView levelForCellForItem:item];
    RADataObject *dataObject = item;
    NSInteger numberOfChildren = [dataObject.children count];
    
    if (level == 0) {
        RATableViewCell *cell = (RATableViewCell *)[treeView cellForItem:item];
        if (numberOfChildren > 0) {
            [cell goCollapseAnimated:YES];
        }
    }else if(level == 1)
    {
        dayRATableViewCell *cell = (dayRATableViewCell *)[treeView cellForItem:item];
        if (numberOfChildren > 0) {
            [cell goCollapseAnimated:YES];
        }
    }}


#pragma mark TreeView Data Source

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item
{
    RADataObject *dataObject = item;
    
    NSInteger level = [self.treeView levelForCellForItem:item];
    NSInteger numberOfChildren = [dataObject.children count];
    BOOL expanded = [self.treeView isCellForItemExpanded:item];
    UITableViewCell * cell1;
    if (level == 0) {
        RATableViewCell *cell = [self.treeView dequeueReusableCellWithIdentifier:NSStringFromClass([RATableViewCell class])];
        [cell setupWithTitle:dataObject.name childCount:numberOfChildren level:level isExpanded:expanded andIncome:dataObject.workTimeString andExpense:dataObject.lifeTimeString andColor:self.myTextColor];
        cell1 = cell;
    }else if(level == 1)
    {
        dayRATableViewCell *cell = [self.treeView dequeueReusableCellWithIdentifier:NSStringFromClass([dayRATableViewCell class])];
        [cell setupWithTitle:dataObject.name childCount:numberOfChildren level:level isExpanded:expanded andIncome:dataObject.workTimeString andExpense:dataObject.lifeTimeString andColor:self.myTextColor];
        cell1 = cell;
    }else if (level == 2)
    {
        itemRATableViewCell *cell = [self.treeView dequeueReusableCellWithIdentifier:NSStringFromClass([itemRATableViewCell class])];
        [cell setupWithCategory:dataObject.name andIncome:dataObject.startTimeString andExpense:dataObject.endTimeString andColor:self.myTextColor];
        cell1 = cell;
    }
    
    cell1.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    
    return cell1;
}

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return [self.data count];
    }
    
    RADataObject *data = item;
    return [data.children count];
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item
{
    RADataObject *data = item;
    if (item == nil) {
        return [self.data objectAtIndex:index];
    }
    
    return data.children[index];
}

-(void)prepareDB
{
    self.monthlyDataDict = [[NSMutableDictionary alloc] init];
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"summaryVC/Could not open db.");
        return;
    }
    NSString *minDate = [[CommonUtility sharedCommonUtility] todayDate];
    NSString *maxDate = minDate;
    
    FMResultSet *rs = [db executeQuery:@"select date from EVENTS order by date LIMIT 1"];
    while ([rs next]) {
        minDate = [rs stringForColumn:@"date"];
    }
    FMResultSet *rs2 = [db executeQuery:@"select date from EVENTS order by date desc LIMIT 1"];
    while ([rs2 next]) {
        maxDate = [rs2 stringForColumn:@"date"];
    }
    
    NSArray *minArray = [minDate componentsSeparatedByString:@"-"];
    NSString *minYear = minArray[0];
    NSString *minMonth = minArray[1];
    
    NSArray *maxArray = [maxDate componentsSeparatedByString:@"-"];
    NSString *maxYear = maxArray[0];
    NSString *maxMonth = maxArray[1];
    
    NSInteger totalMonth = ([maxYear integerValue] - [minYear integerValue]) *12 + ([maxMonth integerValue] - [minMonth integerValue]) + 1;
    
    NSMutableArray *allMonth = [[NSMutableArray alloc] init];
    
    for (int i = 0; i<totalMonth; i ++) {
        
        NSMutableArray *monthArray = [[NSMutableArray alloc] init];
        
        NSInteger startYear = ([minMonth integerValue] + i - 1) /12 +[minYear integerValue];
        NSInteger startMonth = ([minMonth integerValue] + i ) %12;
        if (startMonth == 0) {
            startMonth = 12;
        }
        
        NSInteger endYear = ([minMonth integerValue] +( i+1) - 1) /12 +[minYear integerValue];
        NSInteger endMonth = ([minMonth integerValue] + (i + 1) ) %12;
        if (endMonth == 0) {
            endMonth = 12;
        }
        
        
        NSString *start = [NSString stringWithFormat:@"%ld-%02ld-01",(long)startYear,(long)startMonth];
        NSString *end = [NSString stringWithFormat:@"%ld-%02ld-01",(long)endYear,(long)endMonth];
        NSString *priorEndDay = [[CommonUtility sharedCommonUtility] dateByAddingDays: end andDaysToAdd:-1];

        FMResultSet *rs = [db executeQuery:@"select distinct date from EVENTS where strftime('%s', date) BETWEEN strftime('%s', ?) AND strftime('%s', ?) order by date desc", start,priorEndDay];
        while ([rs next]) {
            NSString *dateString = [rs stringForColumn:@"date"];
            NSArray *timeParts = [dateString componentsSeparatedByString:@" "];
            NSString *dateOnly = timeParts[0];
            
            if(![monthArray containsObject:dateOnly])
            {
                [monthArray addObject:dateOnly];
            }
        }
        
        NSString *monthName = [NSString stringWithFormat:@"%ld-%02ld",(long)startYear,(long)startMonth];
        RADataObject *monthData = [self dailyDataFrom:monthName withArray:monthArray duringStart:start andEnd:priorEndDay];
        [allMonth addObject:monthData];
    }
    [db close];
    NSMutableArray *tempMonthArray = [[NSMutableArray alloc] init];
    
    for (int i = (int)allMonth.count-1 ; i>=0 ;i--) {
        [tempMonthArray addObject:allMonth[i]];
    }
    self.data = [NSArray arrayWithArray:tempMonthArray];
    
}

-( RADataObject *)dailyDataFrom:(NSString *)monthName  withArray:(NSArray *)monthlyArray duringStart:(NSString *)startDate andEnd:(NSString *)endDate
{
    NSMutableArray *monthlyDataArray = [[NSMutableArray alloc] init];
    
    for (NSString *date in monthlyArray) {
        NSMutableArray *oneDayItems = [[NSMutableArray alloc] init];
//        NSString *nextDay = [[CommonUtility sharedCommonUtility] dateByAddingDays: date andDaysToAdd:1];
        
        FMResultSet *rs = [db executeQuery:@"select * from EVENTS where strftime('%s', date) BETWEEN strftime('%s', ?) AND strftime('%s', ?) order by date desc", date,date];
        while ([rs next]) {
            itemObj *oneItem = [[itemObj alloc] init];
            
            oneItem.itemID = [NSNumber numberWithInt: [rs intForColumn:@"eventID"]];
            
            oneItem.itemCategory  = [rs stringForColumn:@"TITLE"];
//            oneItem.itemDescription = [rs stringForColumn:@"mainText"];
            oneItem.itemType = [rs intForColumn:@"TYPE"];
            oneItem.startTime = [rs doubleForColumn:@"startTime"];
            oneItem.endTime = [rs doubleForColumn:@"endTime"];
            oneItem.targetTime = [rs stringForColumn:@"date"];
            NSString *type = oneItem.itemType?NSLocalizedString(@"生活",nil):NSLocalizedString(@"工作",nil);
            NSString *theme = [NSString stringWithFormat:@"%@ > %@",type,oneItem.itemCategory];
            
            RADataObject *itemData = [RADataObject dataObjectWithName:theme andStartTime:oneItem.startTime andEndTime:oneItem.endTime children:nil];
            
            [oneDayItems addObject:itemData];
        }
        NSString *dayOnly = @"01";
        NSArray *dayOnlyArray = [date componentsSeparatedByString:@"-"];
        if (dayOnlyArray.count>2) {
            dayOnly = dayOnlyArray[2];
        }
        
        double sumLife = 0.00f;
        double sumWork = 0.00f;
        
        FMResultSet *resultLife = [db executeQuery:@"select sum(startTime), sum(endTime) from EVENTS where strftime('%s', date) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND TYPE = 1", date,date];
        if ([resultLife next]) {
            sumLife =  [resultLife doubleForColumnIndex:1] - [resultLife doubleForColumnIndex:0];
        }
        
        FMResultSet *resultWork = [db executeQuery:@"select sum(startTime), sum(endTime)  from EVENTS where strftime('%s', date) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND TYPE = 0", date,date];
        
        if ([resultWork next]) {
            sumWork =  [resultWork doubleForColumnIndex:1] - [resultWork doubleForColumnIndex:0];
        }
        
        RADataObject *dailyData = [RADataObject dataObjectWithName:dayOnly andWorkTime:sumWork andLifeTime:sumLife children:oneDayItems];
        
        [monthlyDataArray addObject:dailyData];
    }
    
    double sumLifeMonth = 0.00f;
    double sumWorkMonth = 0.00f;
    FMResultSet *resultIncomeMonth = [db executeQuery:@"select sum(startTime), sum(endTime) from EVENTS where strftime('%s', date) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND TYPE = 1", startDate,endDate];
    if ([resultIncomeMonth next]) {
        sumLifeMonth =  [resultIncomeMonth doubleForColumnIndex:1] - [resultIncomeMonth doubleForColumnIndex:0];
    }
    FMResultSet *resultExpenseMonth = [db executeQuery:@"select sum(startTime), sum(endTime)  from EVENTS where strftime('%s', date) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND TYPE = 0", startDate,endDate];
    if ([resultExpenseMonth next]) {
        sumWorkMonth =  [resultExpenseMonth doubleForColumnIndex:1] - [resultExpenseMonth doubleForColumnIndex:0];
    }
    
    RADataObject *monthlyData = [RADataObject dataObjectWithName:monthName andWorkTime:sumWorkMonth andLifeTime:sumLifeMonth children:monthlyDataArray];
    
    return monthlyData;
}


@end
