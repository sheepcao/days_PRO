//
//  historyViewController.m
//  DaysInLine
//
//  Created by Eric Cao on 6/3/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "historyViewController.h"
#import "global.h"
#import "BottomView.h"
#import "RZTransitions.h"
#import "CommonUtility.h"
#import "myLifeTableViewCell.h"
#import "myWorkTableViewCell.h"
#import "itemObj.h"
#import "itemDetailViewController.h"
#import "checkEventViewController.h"
#import "topBarView.h"
@interface historyViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    CGFloat bottomHeight;
}

@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) NSMutableArray *todayItems;
@property (nonatomic,strong) UIView *summaryView;
@property (strong, nonatomic)  UITableView *maintableView;
@property (nonatomic,strong) UIButton *addNewBtn;
@end

@implementation historyViewController
@synthesize db;
@synthesize summaryView;





- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    if (IS_IPHONE_6P || IS_IPHONE_6) {
        bottomHeight = 65;
    }else
    {
        bottomHeight = bottomBar;
    }

    [self configTitle];
    [self configTable];
    [self configHeaderView];
    [self configBottomView];


    
    [[RZTransitionsManager shared] setAnimationController:[[RZCirclePushAnimationController alloc] init]
                                       fromViewController:[self class]
                                                forAction:RZTransitionAction_PresentDismiss];
    
    
//    [[CommonUtility sharedCommonUtility] addADWithY:bottomHeight InView:self.view OfRootVC:self];

}

-(void)configTable
{
    
    self.maintableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT- bottomHeight -topBarHeight) style:UITableViewStylePlain];
    
    self.maintableView.showsVerticalScrollIndicator = NO;
    self.maintableView.backgroundColor = [UIColor clearColor];
    self.maintableView.delegate = self;
    self.maintableView.dataSource = self;
    self.maintableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.maintableView.canCancelContentTouches = YES;
    self.maintableView.delaysContentTouches = YES;
    self.maintableView.bounces = NO;
    
    [self.view addSubview:self.maintableView];
    [self.view bringSubviewToFront:self.maintableView];
    

    

    UIView *midLine = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 0.5, 18, 1, self.maintableView.frame.size.height)];
    midLine.backgroundColor = self.myTextColor;
    [self.maintableView addSubview:midLine];
    [self.maintableView sendSubviewToBack:midLine];
    
}

-(void)prepareData
{
    
    self.todayItems = [[NSMutableArray alloc] init];
    
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"mainVC/Could not open db.");
        return;
    }
    
    FMResultSet *rs = [db executeQuery:@"select * from EVENTS where date = ? ORDER BY startTime", self.recordDate];
    while ([rs next]) {
        itemObj *oneItem = [[itemObj alloc] init];
        oneItem.itemID = [NSNumber numberWithInt: [rs intForColumn:@"eventID"]];
        oneItem.itemCategory  = [rs stringForColumn:@"TITLE"];
        oneItem.itemDescription = [rs stringForColumn:@"mainText"];
        oneItem.itemType = [rs intForColumn:@"TYPE"];
        oneItem.targetTime = [rs stringForColumn:@"date"];
        oneItem.startTime = [rs doubleForColumn:@"startTime"];
        oneItem.endTime = [rs doubleForColumn:@"endTime"];
        oneItem.photoNames = [rs stringForColumn:@"photoDir"];
        
        
        [self.todayItems addObject:oneItem];
        
    }
    [db close];
    
    [self.maintableView reloadData];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.maintableView setContentOffset:CGPointMake(0, 0)];
    
    [super viewWillAppear:animated];
    [self prepareData];
    [MobClick beginLogPageView:@"historyPage"];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"historyPage"];
}

-(void)configTitle
{
    UIView *topbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topRowHeight)];
    topbar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topbar];
    
    UIButton * closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 32, 40, 40)];
    closeViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    closeViewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [closeViewButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    closeViewButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [closeViewButton setTitleColor:   normalColor forState:UIControlStateNormal];
    [closeViewButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    closeViewButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:closeViewButton];
    
    
    UILabel *titileLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 50, 32, 100, 40)];
    [titileLabel setText:self.recordDate];
    titileLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:titleSize];
    titileLabel.textAlignment = NSTextAlignmentCenter;
    [titileLabel setTextColor:normalColor];
    [topbar addSubview:titileLabel];

}

-(void)configHeaderView
{
    summaryView = [[UIView alloc] initWithFrame:CGRectMake(self.maintableView.frame.origin.x, 0, self.maintableView.frame.size.width, summaryViewHeight)];
    summaryView.backgroundColor = [UIColor clearColor];
    
    UIView *midLine = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 0.5, 15, 1, summaryViewHeight-15)];
    midLine.backgroundColor = self.myTextColor;
    [summaryView addSubview:midLine];
    
    myTextLabel *workLabel = [[myTextLabel alloc] initWithFrame:CGRectMake(0, 0, summaryView.frame.size.width/2, summaryViewHeight) andColor:self.myTextColor];
    [workLabel setText:NSLocalizedString(@"工作",nil)];
    UIView *bottomLine = [[UIView alloc ] initWithFrame:CGRectMake(workLabel.frame.size.width/8, workLabel.frame.size.height - 11, workLabel.frame.size.width*3/4, 1)];
    bottomLine.backgroundColor = self.myTextColor;
    [workLabel addSubview:bottomLine];
    [summaryView addSubview:workLabel];
    
    myTextLabel *lifeLabel = [[myTextLabel alloc] initWithFrame:CGRectMake(summaryView.frame.size.width/2, 0, summaryView.frame.size.width/2, summaryViewHeight) andColor:self.myTextColor];
    [lifeLabel setText:NSLocalizedString(@"生活",nil)];
    UIView *bottomLine2 = [[UIView alloc ] initWithFrame:CGRectMake(workLabel.frame.size.width/8, workLabel.frame.size.height - 11, workLabel.frame.size.width*3/4, 1)];
    bottomLine2.backgroundColor = self.myTextColor;
    [lifeLabel addSubview:bottomLine2];
    [summaryView addSubview:lifeLabel];
}



-(void)configBottomView
{
    BottomView *bottomView = [[BottomView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-bottomHeight, SCREEN_WIDTH, bottomHeight)];
    bottomView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:bottomView];
    
    highLightButton *addNewButton = [[highLightButton alloc] initWithFrame:CGRectMake(40, 6, SCREEN_WIDTH-80, bottomHeight-12)];
    [addNewButton setTitle:NSLocalizedString(@"新事项",nil) forState:UIControlStateNormal];
    [addNewButton setTitleColor:self.myTextColor forState:UIControlStateNormal];
    addNewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    addNewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    addNewButton.layer.borderColor = self.myTextColor.CGColor;
    addNewButton.layer.borderWidth = 0.75;
    [addNewButton addLeftImage:[UIImage imageNamed:@"addEvent"] andScale:0.6];

    self.addNewBtn = addNewButton;
    
    [addNewButton addTarget:self action:@selector(addNewItem:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:addNewButton];
}
-(void)addNewItem:(UIButton *)sender
{
    
    [self presentViewController:[self nextAddNewItemViewController] animated:YES completion:nil];
    
}

- (UIViewController *)nextAddNewItemViewController
{
    itemDetailViewController* addItemVC = [[itemDetailViewController alloc] init];
    [addItemVC setTransitioningDelegate:[RZTransitionsManager shared]];
    addItemVC.isEditing = NO;

    addItemVC.targetDate = self.recordDate;
    
    NSString *now = [[CommonUtility sharedCommonUtility] timeNow];
    NSString *nowLater =[[CommonUtility sharedCommonUtility] timeByAddingMinutes:now andMinsToAdd:30];
    
    addItemVC.itemStartTime = now;
    addItemVC.itemEndTime = nowLater;
    
    return addItemVC;
}

-(void)closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return rowHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return summaryViewHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row< self.todayItems.count) {
        checkEventViewController *myCheckVC = [[checkEventViewController alloc] initWithNibName:@"checkEventViewController" bundle:nil];
        myCheckVC.currentItem = self.todayItems[indexPath.row];
        [self.navigationController pushViewController:myCheckVC animated:YES];
    }
    
}


#pragma mark -
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView             // Default is 1 if not implemented
{
    return 1;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return summaryView;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.todayItems.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

        NSInteger itemID = -1;
        NSString *category = @"";
        NSString *description = @"";
        int itemType = -1;
        NSString *targetTime = @"";
        double endTime = 0.0f;
        double startTime = 0.0f;
        
        if(self.todayItems.count>indexPath.row)
        {
            itemObj *oneItem = self.todayItems[indexPath.row];
            itemID = [oneItem.itemID integerValue];
            category = oneItem.itemCategory;
            description = oneItem.itemDescription;
            itemType = oneItem.itemType;
            startTime = oneItem.startTime;
            endTime = oneItem.endTime;
            targetTime = oneItem.targetTime;
            
        }
        
        if (itemType == 0) {
            NSString *CellItemIdentifier = @"CellWork";
            myWorkTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellItemIdentifier];
            if (cell == nil) {
                cell = [[myWorkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellItemIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor clearColor];
                
            }
            [cell.category setText:category];
            [cell.note setText:description];
            
            NSString *startString = [[CommonUtility sharedCommonUtility] timeInLine:((int)startTime)];
            NSString *endString = [[CommonUtility sharedCommonUtility] timeInLine:((int)endTime)];
            
            [cell.itemTimeLabel setText:[NSString stringWithFormat:@"%@ — %@",startString,endString]];
            [cell makeColor:category];
            [cell makeTextStyle];
            return cell;
            
            
        }else
        {
            NSString *CellItemIdentifier = @"CellLife";
            myLifeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellItemIdentifier];
            if (cell == nil) {
                cell = [[myLifeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellItemIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor clearColor];
            }
            [cell.category setText:category];
            [cell.note setText:description];
            NSString *startString = [[CommonUtility sharedCommonUtility] timeInLine:((int)startTime)];
            NSString *endString = [[CommonUtility sharedCommonUtility] timeInLine:((int)endTime)];
            
            [cell.itemTimeLabel setText:[NSString stringWithFormat:@"%@ — %@",startString,endString]];
            
            [cell makeColor:category];
            [cell makeTextStyle];
            return cell;
        }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    for (UITableViewCell *cell in self.maintableView.visibleCells) {
        if ([cell isKindOfClass:[myLifeTableViewCell class]]) {
            myLifeTableViewCell *oneCell = (myLifeTableViewCell *)cell;
            CGFloat hiddenFrameHeight = scrollView.contentOffset.y + summaryViewHeight - cell.frame.origin.y;
            if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
                [oneCell maskCellFromTop:hiddenFrameHeight];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
