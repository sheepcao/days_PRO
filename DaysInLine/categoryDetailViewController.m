//
//  categoryDetailViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 4/25/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#define summaryLabelWidth 60
#define summaryLabelHeight 20

#import "categoryDetailViewController.h"
#import "global.h"
#import "topBarView.h"
#import "dateSelectView.h"
#import "dateShowView.h"
#import "CommonUtility.h"
#import "itemObj.h"
#import "categoryItemsTableViewCell.h"
#import "checkEventViewController.h"


@interface categoryDetailViewController ()<UITableViewDataSource,UITableViewDelegate,FlatDatePickerDelegate,UIScrollViewDelegate>
{
    CGFloat fontSize;
}
@property (nonatomic,strong) topBarView *myTopBar;
@property (nonatomic ,strong) UITableView *itemsTable;
@property (nonatomic,strong) dateSelectView *dateView;
@property (nonatomic,strong)  dateShowView *showTimeView;
@property (nonatomic,strong) NSString *startTime;
@property (nonatomic,strong) NSString *endTime;
@property (nonatomic,strong) NSMutableArray *timeWindowItems;
@property (nonatomic,strong) FMDatabase *db;

@property (nonatomic,strong) UILabel *moneyRatioLabel;
@property (nonatomic,strong) UILabel *moneyCountLabel;
@property (nonatomic,strong) UILabel *moneyLabel;

@end

@implementation categoryDetailViewController
@synthesize db;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configTopbar];
    [self configItemsTable];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"themeDetail"];

    [self prepareDataFrom:self.startDate toDate:self.endDate];
    [self.itemsTable reloadData];

//    [[CommonUtility sharedCommonUtility] addADWithY:0 InView:self.view OfRootVC:self];
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"categoryDetail"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)prepareDataFrom:(NSString *)startDate toDate:(NSString *)endDate
{
    NSMutableArray *allItems= [[NSMutableArray alloc] init];
    
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"mainVC/Could not open db.");
        return;
    }
    
//    NSString *nextEndDay = [[CommonUtility sharedCommonUtility] dateByAddingDays:endDate andDaysToAdd:1];
    

    FMResultSet *rs = [db executeQuery:@"select * from EVENTS where TITLE = ? AND TYPE = ? AND strftime('%s', date) BETWEEN strftime('%s', ?) AND strftime('%s', ?)", self.categoryName,[NSNumber numberWithInteger:self.categoryType],startDate,endDate];
    
    while ([rs next]) {
        itemObj *oneItem = [[itemObj alloc] init];
        oneItem.itemID = [NSNumber numberWithInt: [rs intForColumn:@"eventID"]];
        oneItem.itemCategory  = [rs stringForColumn:@"TITLE"];
        oneItem.itemDescription = [rs stringForColumn:@"mainText"];
        oneItem.itemType = [rs intForColumn:@"TYPE"];
        oneItem.startTime = [rs doubleForColumn:@"startTime"];
        oneItem.endTime = [rs doubleForColumn:@"endTime"];
        oneItem.targetTime = [rs stringForColumn:@"date"];
        [allItems addObject:oneItem];
    }
    
    NSMutableDictionary *itemsDic = [[NSMutableDictionary alloc] init];
    
    for (itemObj *item in allItems) {

        NSString *dateString =item.targetTime;
        
        NSArray *itemsOneDay = [itemsDic objectForKey:dateString];
        if (!itemsOneDay) {
            NSArray *itemsAday = [[NSArray alloc] initWithObjects:item, nil];
            [itemsDic setObject:itemsAday forKey:dateString];
        }else
        {
            NSMutableArray *tempItemsOneDay = [[NSMutableArray alloc] initWithArray:itemsOneDay];
            [tempItemsOneDay addObject:item];
            NSArray *newItemsOneDay = [[NSArray alloc] initWithArray:tempItemsOneDay];
            [itemsDic setObject:newItemsOneDay forKey:dateString];
        }
    }
    
    if (!self.timeWindowItems) {
        self.timeWindowItems = [[NSMutableArray alloc] init];
    }else
    {
        [self.timeWindowItems removeAllObjects];
    }
    NSArray *keys = [itemsDic allKeys];
    keys = [keys sortedArrayUsingComparator:^(id a, id b) {
        return [b compare:a options:NSNumericSearch];
    }];
    for (NSString *key in [itemsDic allKeys]) {
        [self.timeWindowItems addObject:[itemsDic objectForKey:key]];
    }
    
    double catgoryTime = 0.0f;
    FMResultSet *resultMoney = [db executeQuery:@"select sum(startTime), sum(endTime) from EVENTS where strftime('%s', date) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND TITLE = ? AND TYPE = ?", startDate,endDate,self.categoryName,[NSNumber numberWithInteger:self.categoryType]];
    if ([resultMoney next]) {
        catgoryTime =  [resultMoney doubleForColumnIndex:1] - [resultMoney doubleForColumnIndex:0];
        [self.moneyLabel setText:[NSString stringWithFormat:NSLocalizedString(@"%.2f h",nil),catgoryTime/60]];
        
    }
    
    FMResultSet *resultRatio = [db executeQuery:@"select sum(startTime), sum(endTime) from EVENTS where strftime('%s', date) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND TYPE = ?", startDate,endDate,[NSNumber numberWithInteger:self.categoryType]];
    if ([resultRatio next]) {
        double sumTime =  [resultRatio doubleForColumnIndex:1] - [resultRatio doubleForColumnIndex:0];
        if (sumTime>0.0001) {
            [self.moneyRatioLabel setText:[NSString stringWithFormat:@"%.2f%%",catgoryTime*100/sumTime]];
        }else
        {
            [self.moneyRatioLabel setText:@"0.00%"];
        }
    }
    
    FMResultSet *resultCount = [db executeQuery:@"select count(*) from EVENTS where strftime('%s', date) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND TITLE = ? AND TYPE = ?", startDate,endDate,self.categoryName,[NSNumber numberWithInteger:self.categoryType]];
    
    if ([resultCount next]) {
        int moneyCount =  [resultCount intForColumnIndex:0];
        [self.moneyCountLabel setText:[NSString stringWithFormat:NSLocalizedString(@"%d 笔",nil),moneyCount]];
    }
    [db close];
    
}
////////////////////////////////////////////////////////////////////////


-(void)configTopbar
{
    topBarView *topBar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200+20)];
    topBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topBar];
    self.myTopBar = topBar;
    
    [self configDateSelection];
    
    UIButton * closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 32, 40, 40)];
    closeViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    closeViewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [closeViewButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    closeViewButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [closeViewButton setTitleColor:   normalColor forState:UIControlStateNormal];
    [closeViewButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    closeViewButton.backgroundColor = [UIColor clearColor];
    [topBar addSubview:closeViewButton];
    
    [self.myTopBar.titleLabel  setText:NSLocalizedString(@"主题明细",nil)];

    UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4, topBar.frame.size.height - 100,SCREEN_WIDTH/2,65)];
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                 @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                   UIFontDescriptorNameAttribute:@"HelveticaNeue-UltraLight",
                                                   UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: SCREEN_WIDTH/8.5]
                                                   }];
    
    [categoryLabel setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0]];
    categoryLabel.textColor = self.myTextColor;
    categoryLabel.textAlignment = NSTextAlignmentCenter;
    categoryLabel.adjustsFontSizeToFitWidth = YES;
    NSString *type = self.categoryType?NSLocalizedString(@"生活",nil):NSLocalizedString(@"工作",nil);
    NSString *theme = [NSString stringWithFormat:@"%@ > %@",type,self.categoryName];
    [categoryLabel setText:theme];
    [topBar addSubview:categoryLabel];
    
    
    
    UILabel *moneyRatio = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - summaryLabelWidth/4,categoryLabel.frame.origin.y +categoryLabel.frame.size.height +10, summaryLabelWidth, summaryLabelHeight)];
    [moneyRatio setText:@""];
    moneyRatio.font = [UIFont fontWithName:@"HelveticaNeue" size:13.5f];
    moneyRatio.textAlignment = NSTextAlignmentCenter;
    [moneyRatio setTextColor:self.myTextColor];
    [topBar addSubview:moneyRatio];
    self.moneyRatioLabel = moneyRatio;
    
    UIView *seperatorLine1 = [[UILabel alloc] initWithFrame:CGRectMake(moneyRatio.frame.origin.x - 1,moneyRatio.frame.origin.y , 0.68, moneyRatio.frame.size.height)];
    [seperatorLine1 setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.8]];
    [topBar addSubview:seperatorLine1];
    
    UIView *seperatorLine2 = [[UILabel alloc] initWithFrame:CGRectMake(moneyRatio.frame.origin.x +moneyRatio.frame.size.width ,moneyRatio.frame.origin.y , 0.68, moneyRatio.frame.size.height)];
    [seperatorLine2 setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.8]];
    [topBar addSubview:seperatorLine2];
    
    UILabel *totalAmount = [[UILabel alloc] initWithFrame:CGRectMake(seperatorLine1.frame.origin.x - summaryLabelWidth - 40, moneyRatio.frame.origin.y, summaryLabelWidth+32, summaryLabelHeight)];
    [totalAmount setText:@""];
    totalAmount.adjustsFontSizeToFitWidth = YES;
    totalAmount.font = [UIFont fontWithName:@"HelveticaNeue" size:13.5f];
    totalAmount.textAlignment = NSTextAlignmentRight;
    [totalAmount setTextColor:self.myTextColor];
    [topBar addSubview:totalAmount];
    self.moneyLabel = totalAmount;
    
    UILabel *totalCount = [[UILabel alloc] initWithFrame:CGRectMake(seperatorLine2.frame.origin.x +1 + 8, moneyRatio.frame.origin.y, summaryLabelWidth, summaryLabelHeight)];
    [totalCount setText:@""];
    totalCount.adjustsFontSizeToFitWidth = YES;
    totalCount.font = [UIFont fontWithName:@"HelveticaNeue" size:13.5f];
    totalCount.textAlignment = NSTextAlignmentLeft;
    [totalCount setTextColor:self.myTextColor];
    [topBar addSubview:totalCount];
    self.moneyCountLabel = totalCount;
}

-(void)configDateSelection
{
    self.dateView = [[dateSelectView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    dateShowView *showDateView = [[dateShowView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/5, 70, SCREEN_WIDTH*3/5, 45)];
    [showDateView.startLabel setText:self.startDate];
    [showDateView.endLabel setText:self.endDate];
    [self.myTopBar addSubview:showDateView];
    [showDateView.selectionButton addTarget:self action:@selector(dateSelect) forControlEvents:UIControlEventTouchUpInside];
    self.showTimeView = showDateView;
    
}

-(void)configItemsTable
{
    self.itemsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.myTopBar.frame.size.height + self.myTopBar.frame.origin.y + 5, SCREEN_WIDTH, (SCREEN_HEIGHT- SCREEN_WIDTH/2)*3/4)];
    self.itemsTable.showsVerticalScrollIndicator = YES;
    self.itemsTable.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    self.itemsTable.backgroundColor = [UIColor clearColor];
    self.itemsTable.delegate = self;
    self.itemsTable.dataSource = self;
    self.itemsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.itemsTable];
    
}
//
-(void)dateSelect
{
    [self.view addSubview:self.dateView];
    self.dateView.flatDatePicker.delegate =self;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    dateFormatter.calendar = cal;
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *startDate = [dateFormatter dateFromString:self.showTimeView.startLabel.text];
    [self.dateView.flatDatePicker setDate:startDate animated:NO];
    [self.dateView.flatDatePicker.labelTitle setText:[NSString stringWithFormat:NSLocalizedString(@"开始时间: %@",nil),self.showTimeView.startLabel.text]];
    [self.dateView.flatDatePicker makeTitle];
    
    [self.dateView.flatDatePicker show];
}


#pragma mark - FlatDatePicker Delegate

- (void)flatDatePicker:(FlatDatePicker*)datePicker dateDidChange:(NSDate*)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    dateFormatter.calendar = cal;
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    
    NSString *value = [dateFormatter stringFromDate:date];
    
    NSLog(@"date picker:%@",value);
    if (!datePicker.isSelectingEndTime) {
        [datePicker.labelTitle setText:[NSString stringWithFormat:NSLocalizedString(@"开始时间: %@",nil),value]];
        [datePicker makeTitle];
        
    }else
    {
        [datePicker.labelTitle setText:[NSString stringWithFormat:NSLocalizedString(@"截止时间: %@",nil),value]];
        [datePicker makeTitle];
        
    }
    
}

- (void)flatDatePicker:(FlatDatePicker*)datePicker didCancel:(UIButton*)sender {
    [self.dateView removeFromSuperview];
}

- (void)flatDatePicker:(FlatDatePicker*)datePicker didValid:(UIButton*)sender date:(NSDate*)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    dateFormatter.calendar = cal;
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *value = [dateFormatter stringFromDate:date];
    NSDate *endDate = [dateFormatter dateFromString:self.showTimeView.endLabel.text];
    if (!datePicker.isSelectingEndTime) {
        self.startTime = value;
        [self.dateView.flatDatePicker setDate:endDate animated:NO];
        [datePicker.labelTitle setText:[NSString stringWithFormat:NSLocalizedString(@"截止时间: %@",nil),self.showTimeView.endLabel.text]];
        [datePicker makeTitle];
        
    }else
    {
        self.endTime = value;
        [self prepareDataFrom:self.startTime toDate:self.endTime];
        
        [self.itemsTable reloadData];
        
        [self.dateView removeFromSuperview];
        [self.showTimeView.startLabel setText:self.startTime];
        [self.showTimeView.endLabel setText:self.endTime];
        
    }
    
}


#pragma mark -
#pragma mark Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_WIDTH/8.5;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SCREEN_WIDTH/16;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath");
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[categoryItemsTableViewCell class]]) {
        categoryItemsTableViewCell *itemCell = (categoryItemsTableViewCell *)cell;
        [itemCell.category setTextColor:[UIColor colorWithRed:1.0f green:0.65f blue:0.0f alpha:1.0f]];
        
        checkEventViewController *itemDetailVC = [[checkEventViewController alloc] initWithNibName:@"checkEventViewController" bundle:nil];

        if (indexPath.section >= self.timeWindowItems.count ) {
            return;
        }else
        {
            NSArray *itemsOfDay = (NSArray *)self.timeWindowItems[indexPath.section];
            if (indexPath.row >= itemsOfDay.count) {
                return;
            }
            
            
            itemObj *oneItem = itemsOfDay[indexPath.row];
            itemDetailVC.currentItem = oneItem;

                 [self.navigationController pushViewController:itemDetailVC animated:YES];
        }
        
    }
    [self tableView:tableView didDeselectRowAtIndexPath:indexPath];
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didDeselectRowAtIndexPath");
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[categoryItemsTableViewCell class]]) {
        categoryItemsTableViewCell *itemCell = (categoryItemsTableViewCell *)cell;
        [itemCell.category setTextColor:self.myTextColor];
    }
    
}

#pragma mark -
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.timeWindowItems.count;
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, SCREEN_WIDTH/16)];
    headerView.backgroundColor = [UIColor clearColor];
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, headerView.frame.size.height - 18, 160, 18)];
    dateLabel.textAlignment = NSTextAlignmentLeft;
    dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:SCREEN_WIDTH/28];
    dateLabel.textColor = [UIColor colorWithRed:253/255.0f green:197/255.0f blue:65/255.0f alpha:1.0f];
    [headerView addSubview:dateLabel];
    NSArray *itemsOfDay = (NSArray *)self.timeWindowItems[section];
    if(itemsOfDay.count>0)
    {
        itemObj *oneItem = itemsOfDay[0];
        NSString *dateString = oneItem.targetTime;
        [dateLabel setText:dateString];
    }
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *itemsOfDay = (NSArray *)self.timeWindowItems[section];
    
    return itemsOfDay.count;
}

- (categoryItemsTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"categoryItemsCell";
    
    categoryItemsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[categoryItemsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    NSArray *itemsOfDay = (NSArray *)self.timeWindowItems[indexPath.section];
    if(itemsOfDay.count>indexPath.row)
    {
        itemObj *oneItem = itemsOfDay[indexPath.row];
        NSString *category = oneItem.itemCategory;
        NSString *description = oneItem.itemDescription;
        
        if (![description isEqualToString:@""]) {
            description = [@" - " stringByAppendingString:description];
        }
        
        NSString *contentString = [NSString stringWithFormat:@"%@%@",category,description];
        [cell.category setText:contentString];

        NSString *startString = [[CommonUtility sharedCommonUtility] timeInLine:((int)oneItem.startTime)];
        NSString *endString = [[CommonUtility sharedCommonUtility] timeInLine:((int)oneItem.endTime)];
        
        [cell.money setText:[NSString stringWithFormat:@"%@ — %@",startString,endString]];
        [cell makeTextStyle:self.myTextColor];

    }
    
    return cell;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    for (UITableViewCell *cell in self.itemsTable.visibleCells) {
        if ([cell isKindOfClass:[categoryItemsTableViewCell class]]) {
            categoryItemsTableViewCell *oneCell = (categoryItemsTableViewCell *)cell;
            CGFloat hiddenFrameHeight = scrollView.contentOffset.y + [self tableView:self.itemsTable heightForHeaderInSection:0] - cell.frame.origin.y;
            if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
                [oneCell maskCellFromTop:hiddenFrameHeight];
            }
        }
    }
}


-(void)closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
