//
//  trendViewController.m
//  DaysInLine
//
//  Created by Eric Cao on 6/17/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "trendViewController.h"
#import "topBarView.h"
#import "global.h"
#import "CommonUtility.h"
#import "PNChart.h"

#define lineChartWidth  700

@interface trendViewController ()
{
    NSInteger daysOffsite;
    NSString *weekStart;
    NSString *weekEnd;
    
    CGFloat weekWork;
    CGFloat lastWeekWork;
    CGFloat weekLife;
    CGFloat lastWeekLife;
}
@property (strong, nonatomic) PNLineChart * mainChart;
@property (strong, nonatomic) PNLineChart * axisChart;
@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) PNLineChart *mylineChart;
@property (nonatomic,strong) UIScrollView *mychartScroll;

@property (nonatomic,strong) NSString *startDate;
@property (nonatomic,strong) NSString *endDate;

@property (nonatomic,strong) NSMutableArray *chartDataArray;
@property (nonatomic,strong) NSMutableArray *chartLifeDataArray;

@property (nonatomic,strong) NSMutableArray *chartDatesArray;
@end

@implementation trendViewController
@synthesize db;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSDate * todayDate = [NSDate date];
    weekStart = [[CommonUtility sharedCommonUtility] weekStartDayOf:todayDate];
    weekEnd = [[CommonUtility sharedCommonUtility] weekEndDayOf:todayDate];
    self.endDate = weekEnd;
    self.startDate = weekStart;
    daysOffsite = -7;
    [self prepareChartData];

    [self configTopbar];
    [self configBasicInfo];
    [self configLineChartAxis];
    [self configLineChart];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareChartData
{
    self.chartDataArray = [[NSMutableArray alloc] init];
    self.chartLifeDataArray = [[NSMutableArray alloc] init];

    self.chartDatesArray = [[NSMutableArray alloc] init];
    
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"mainVC/Could not open db.");
        return;
    }
    for (int i = 8; i>=0; i--) {
        
        
        NSString *lastStartDate = [[CommonUtility sharedCommonUtility] dateByAddingDays:self.startDate andDaysToAdd:daysOffsite * i];
        NSString *lastnextEndDay = [[CommonUtility sharedCommonUtility] dateByAddingDays:self.endDate andDaysToAdd:daysOffsite * i];
        
        NSArray *dateStartArray = [lastStartDate componentsSeparatedByString:@"-"];
        NSArray *dateEndArray = [lastnextEndDay componentsSeparatedByString:@"-"];
        
        if (dateStartArray.count>2 && dateEndArray.count>2) {
                [self.chartDatesArray addObject:[NSString stringWithFormat:@"%@/%@-%@/%@",dateStartArray[1],dateStartArray[2],dateEndArray[1],dateEndArray[2]]];
        }
        
        FMResultSet *resultTime = [db executeQuery:@"select sum(startTime), sum(endTime) from EVENTS where strftime('%s', date) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND TYPE = ?", lastStartDate,lastnextEndDay,@0];
        
        if ([resultTime next]) {
            double totalTime = [resultTime doubleForColumnIndex:1] - [resultTime doubleForColumnIndex:0];
            
            [self.chartDataArray addObject:[NSNumber numberWithDouble:totalTime/60]];
            
            if (i == 1) {
                lastWeekWork = totalTime;
            }else if (i == 0)
            {
                weekWork = totalTime;
            }
            
        }
        FMResultSet *resultLifeTime = [db executeQuery:@"select sum(startTime), sum(endTime) from EVENTS where strftime('%s', date) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND TYPE = ?", lastStartDate,lastnextEndDay,@1];
        
        if ([resultLifeTime next]) {
            double totalTime = [resultLifeTime doubleForColumnIndex:1] - [resultLifeTime doubleForColumnIndex:0];
            [self.chartLifeDataArray addObject:[NSNumber numberWithDouble:totalTime/60]];
            
            if (i == 1) {
                lastWeekLife = totalTime;
            }else if (i == 0)
            {
                weekLife = totalTime;
            }
        }
    }
    [db close];
    
}


-(void)configTopbar
{
    topBarView *topbar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topBarHeight)];
    topbar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topbar];
    [topbar.titleLabel  setText:NSLocalizedString(@"近期走势",nil)];
    
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 26, 40, 40)];
    saveButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    saveButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [saveButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    saveButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [saveButton setTitleColor: normalColor forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    saveButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:saveButton];
    
}
-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)configBasicInfo
{
    CGFloat space =30;
    if (IS_IPHONE_4_OR_LESS) {
        space = 5;
    }
    
    UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/16, topBarHeight+space, SCREEN_WIDTH*7/8, SCREEN_WIDTH/2.5)];
    infoView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:infoView];
    
    NSArray *titles = @[@"",NSLocalizedString(@"本周投入", nil),NSLocalizedString(@"日均投入", nil),NSLocalizedString(@"环比增长", nil)];
    
    for(int i = 0;i<4;i++)
    {
        UILabel *titlesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0 + i * infoView.frame.size.width/4 , 0, infoView.frame.size.width/4, infoView.frame.size.height/3)];
        [titlesLabel setText:titles[i]];
        titlesLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
        titlesLabel.textAlignment = NSTextAlignmentCenter;
        [titlesLabel setTextColor:self.myTextColor];
        [infoView addSubview:titlesLabel];
        
    }
    UIView *firstRowLine = [[UIView alloc] initWithFrame:CGRectMake(0, infoView.frame.size.height/3, infoView.frame.size.width, 0.8)];
    firstRowLine.backgroundColor = TextColor1;
    [infoView addSubview:firstRowLine];
    
 //////////////////////////////////////for work time
    NSString *totalWork = [NSString stringWithFormat:NSLocalizedString(@"%.2f h",nil),weekWork/60];
    NSString *ratioWork;
    if (lastWeekWork < 0.001) {
        ratioWork = @"—";
    }else
    {
        if ((weekWork - lastWeekWork) >0) {
            ratioWork = [NSString stringWithFormat:@"+%.2f%%",(weekWork-lastWeekWork)*100/lastWeekWork];
        }else
        {
            ratioWork = [NSString stringWithFormat:@"%.2f%%",(weekWork-lastWeekWork)*100/lastWeekWork];
        }
    }
    NSString *dayOfWork = [NSString stringWithFormat:NSLocalizedString(@"%.2f h",nil),(weekWork/60)/7];

    NSArray *workData = @[NSLocalizedString(@"工作",nil),totalWork,dayOfWork,ratioWork];
    
    for(int i = 0;i<4;i++)
    {
        UILabel *titlesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0 + i * infoView.frame.size.width/4 , infoView.frame.size.height/3, infoView.frame.size.width/4, infoView.frame.size.height/3)];
        [titlesLabel setText:workData[i]];
        if (i == 0) {
            titlesLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0f];
            [titlesLabel setTextColor:self.myTextColor];
        }else
        {
            titlesLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0f];
            [titlesLabel setTextColor:GoldColor];
        }
        titlesLabel.textAlignment = NSTextAlignmentCenter;
        [infoView addSubview:titlesLabel];
    }
    
    UIView *secondRowLine = [[UIView alloc] initWithFrame:CGRectMake(0, infoView.frame.size.height*2/3, infoView.frame.size.width, 0.8)];
    secondRowLine.backgroundColor = TextColor1;
    [infoView addSubview:secondRowLine];
    
    /////////////////////////////////for life time
    
    NSString *totalLife= [NSString stringWithFormat:NSLocalizedString(@"%.2f h",nil),weekLife/60];
    NSString *ratioLife;
    if (lastWeekLife < 0.001) {
        ratioLife = @"—";
    }else
    {
        if ((weekLife - lastWeekLife) >0) {
            ratioLife = [NSString stringWithFormat:@"+%.2f%%",(weekLife-lastWeekLife)*100/lastWeekLife];
        }else
        {
            ratioLife = [NSString stringWithFormat:@"%.2f%%",(weekLife-lastWeekLife)*100/lastWeekLife];
        }
    }
    NSString *dayOfLife = [NSString stringWithFormat:NSLocalizedString(@"%.2f h",nil),(weekLife/60)/7];
    
    NSArray *lifeData = @[NSLocalizedString(@"生活",nil),totalLife,dayOfLife,ratioLife];
    
    for(int i = 0;i<4;i++)
    {
        UILabel *titlesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0 + i * infoView.frame.size.width/4 , infoView.frame.size.height*2/3, infoView.frame.size.width/4, infoView.frame.size.height/3)];
        [titlesLabel setText:lifeData[i]];
        if (i == 0) {
            titlesLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0f];
            [titlesLabel setTextColor:self.myTextColor];
        }else
        {
            titlesLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0f];
            [titlesLabel setTextColor:GoldColor];
        }
        titlesLabel.textAlignment = NSTextAlignmentCenter;
        [infoView addSubview:titlesLabel];
    }
    

    UIView *colomnLine = [[UIView alloc] initWithFrame:CGRectMake(infoView.frame.size.width/4-3, 8, 0.8, infoView.frame.size.height-13)];
    colomnLine.backgroundColor = TextColor1;
    [infoView addSubview:colomnLine];
}


-(void)configLineChart
{
    CGFloat tableY = SCREEN_HEIGHT - SCREEN_WIDTH*14/20;
    
    PNLineChart * lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 0, lineChartWidth, SCREEN_WIDTH*13/20)];
    lineChart.chartMarginLeft = 0;
    lineChart.chartMarginRight = 0;
    lineChart.backgroundColor = [UIColor clearColor];
    lineChart.yLabelColor = [UIColor clearColor];
    lineChart.xLabelColor = PNWhite;
    lineChart.xLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.0f];
    
    [lineChart setXLabels:self.chartDatesArray];
    
    UIScrollView *chartScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(35, tableY, SCREEN_WIDTH-35, SCREEN_WIDTH*13/20)];
    self.mychartScroll = chartScroll;
    
    chartScroll.contentSize = CGSizeMake(lineChartWidth, chartScroll.frame.size.height);
    chartScroll.bounces = NO;
    chartScroll.showsHorizontalScrollIndicator = NO;
    
    [UIView animateWithDuration:0.49f delay:0.5f options:UIViewAnimationOptionLayoutSubviews animations:^{
        [self.mychartScroll setContentOffset:CGPointMake(lineChartWidth -50- (SCREEN_WIDTH - 35) , 0)];
    } completion:nil];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, lineChartWidth, SCREEN_WIDTH*13/20 - lineChart.chartMarginBottom);
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:1.0 alpha:0.41].CGColor, (id)[UIColor colorWithWhite:1.0 alpha:0.012].CGColor, nil];
    
    gradientLayer.startPoint = CGPointMake(0.0f, 1.0f);
    gradientLayer.endPoint = CGPointMake(0.0f, 0.0f);
    chartScroll.layer.mask = gradientLayer;
    
    [chartScroll.layer insertSublayer:gradientLayer atIndex:0];
    // Line Chart No.1
    NSArray * data01Array = [NSArray arrayWithArray:self.chartDataArray];
    PNLineChartData *data01 = [PNLineChartData new];
    data01.inflexionPointStyle = PNLineChartPointStyleCircle;
    data01.color = PNTitleColor;
    data01.lineWidth = 2.0f;
    data01.itemCount = lineChart.xLabels.count;
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [data01Array[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    NSArray * data02Array = [NSArray arrayWithArray:self.chartLifeDataArray];
    PNLineChartData *data02 = [PNLineChartData new];
    data02.inflexionPointStyle = PNLineChartPointStyleCircle;
    data02.color = PNRed;
    data02.lineWidth = 1.6f;
    data02.itemCount = self.chartDatesArray.count;
    data02.getData = ^(NSUInteger index) {
        CGFloat yValue = [data02Array[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    lineChart.chartData = @[data01,data02];
    lineChart.showLabel = YES;
    lineChart.showCoordinateAxis = NO;
    lineChart.showAxisX = YES;
    
    lineChart.axisColor = PNLightGrey;
    lineChart.axisWidth = 1.0f;
    
    [lineChart strokeChart];
    
    [chartScroll addSubview:lineChart];
    [self.view addSubview:chartScroll];
    self.mainChart = lineChart;
    
    UILabel *legendWork = [[UILabel alloc ] initWithFrame:CGRectMake( SCREEN_WIDTH/2 -100, chartScroll.frame.origin.y - 22, 38, 15)];
    [legendWork setText:NSLocalizedString(@"工作", nil)];
    legendWork.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10.5f];
    legendWork.textAlignment = NSTextAlignmentCenter;
    legendWork.textColor = self.myTextColor;
    [self.view addSubview:legendWork];
    UIView *legendWorkLine = [[UIView alloc] initWithFrame:CGRectMake(legendWork.frame.origin.x + legendWork.frame.size.width + 5,legendWork.frame.origin.y + legendWork.frame.size.height/2 -1, 45, 2)];
    legendWorkLine.layer.cornerRadius = 1;
    [legendWorkLine setBackgroundColor:PNTitleColor];
    [self.view addSubview:legendWorkLine];

    UILabel *legendLife = [[UILabel alloc ] initWithFrame:CGRectMake( SCREEN_WIDTH/2 +7, legendWork.frame.origin.y , 38, 15)];
    [legendLife setText:NSLocalizedString(@"生活", nil)];
    legendLife.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10.5f];
    legendLife.textAlignment = NSTextAlignmentCenter;
    legendLife.textColor = self.myTextColor;
    [self.view addSubview:legendLife];
    UIView *legendLifeLine = [[UIView alloc] initWithFrame:CGRectMake(legendLife.frame.origin.x + legendLife.frame.size.width + 5, legendLife.frame.origin.y + legendLife.frame.size.height/2 -1, 45, 2)];
    legendLifeLine.layer.cornerRadius = 1;
    [legendLifeLine setBackgroundColor:PNRed];
    [self.view addSubview:legendLifeLine];
    
}


-(void)configLineChartAxis
{
    CGFloat tableY = SCREEN_HEIGHT - SCREEN_WIDTH*14/20;
    PNLineChart * lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, tableY, lineChartWidth, SCREEN_WIDTH*13/20)];
    lineChart.backgroundColor = [UIColor clearColor];
    lineChart.chartMarginTop = 10;
    lineChart.yLabelColor = PNWhite;
    lineChart.xLabelColor = [UIColor clearColor];
    lineChart.yLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.0f];
    
    [lineChart setXLabels:self.chartDatesArray];
    
    // Line Chart No.1
    NSArray * data01Array = [NSArray arrayWithArray:self.chartDataArray];
    PNLineChartData *data01 = [PNLineChartData new];
    data01.inflexionPointStyle = PNLineChartPointStyleCircle;
    data01.color = PNTitleColor;
    data01.lineWidth = 2.0f;
    data01.itemCount = lineChart.xLabels.count;
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [data01Array[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    NSArray * data02Array = [NSArray arrayWithArray:self.chartLifeDataArray];
    PNLineChartData *data02 = [PNLineChartData new];
    data02.inflexionPointStyle = PNLineChartPointStyleCircle;
    data02.color = PNRed;
    data02.lineWidth = 1.6f;
    data02.itemCount = self.chartDatesArray.count;
    data02.getData = ^(NSUInteger index) {
        CGFloat yValue = [data02Array[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    lineChart.chartData = @[data01,data02];
    lineChart.showCoordinateAxis = NO;
    lineChart.showLabel = YES;
    lineChart.showAxisY = YES;
    lineChart.axisColor = PNLightGrey;
    lineChart.axisWidth = 1.0f;
    
    self.axisChart = lineChart;
    [self.view addSubview:lineChart];
    
}


@end
