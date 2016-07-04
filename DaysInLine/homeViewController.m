//
//  ViewController.m
//  DaysInLine
//
//  Created by Eric Cao on 5/27/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "AppDelegate.h"
#import "homeViewController.h"
#import "SideMenuViewController.h"
#import "MFSideMenu.h"
#import "global.h"
#import "BottomView.h"
#import "RZTransitions.h"
#import "CommonUtility.h"
#import "pickerLabel.h"
#import "calendarViewController.h"
#import "constellationView.h"
#import "myLifeTableViewCell.h"
#import "myWorkTableViewCell.h"
#import "itemObj.h"
#import "itemDetailViewController.h"
#import "checkEventViewController.h"
#import "trackViewController.h"

@interface homeViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,constellationDelegate>
@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) NSMutableArray *todayItems;
@property (nonatomic,strong)  constellationView *myConstellView;
@property (nonatomic,strong) UIView *summaryView;
@property (nonatomic,strong)  UIView *tableMidLine;
@property (nonatomic,strong) UIButton *addNewBtn;
@property (nonatomic,strong) UIButton *trackBtn;
@property (nonatomic,strong) UIView *myDimView;

@end

@implementation homeViewController
@synthesize summaryView;
@synthesize db;

- (void)configUIAppearance{
    NSLog(@"home config ui ");
    NSString *showModel =  [[NSUserDefaults standardUserDefaults] objectForKey:SHOWMODEL];
    if ([showModel isEqualToString:@"白天"]) {
        self.myTextColor = TextColor0;
    }else if([showModel isEqualToString:@"夜间"]) {
        self.myTextColor = TextColor2;
    }

    NSString *backName;
    if (!showModel) {
        backName = @"白天.png";
    }else
    {
        backName  = [NSString stringWithFormat:@"%@.png",showModel];
    }

    if (!self.myBackImage)
    {
        self.myBackImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [self.myBackImage setImage:[UIImage imageNamed:backName]];
        [self.view addSubview:self.myBackImage];
        [self.view sendSubviewToBack:self.myBackImage];
        [self.view setNeedsDisplay];
    }else
    {
        [self.myBackImage setImage:[UIImage imageNamed:backName]];
    }

    [self.maintableView reloadData];

    [self configTextColor];

    
}

- (void)registerLuckChangedNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(configLuckyText)
                                                 name:LuckChanged
                                               object:nil];
}

-(void)configTextColor
{
    NSLog(@"configTextColor");
    
    [self.titleTextLabel setTextColor:self.myTextColor];
    [self.TimelineText setTextColor:self.myTextColor];
    [self.luckyText setTextColor:self.myTextColor];
    [self.constellationButton setTitleColor:self.myTextColor forState:UIControlStateNormal];
    
    
    [self.addNewBtn setTitleColor:self.myTextColor forState:UIControlStateNormal];
    self.addNewBtn.layer.borderColor = self.myTextColor.CGColor;
    [self.trackBtn setTitleColor:self.myTextColor forState:UIControlStateNormal];
    self.trackBtn.layer.borderColor = self.myTextColor.CGColor;
    
    myTextLabel *workLabel = (myTextLabel *)[summaryView viewWithTag:11];
    myTextLabel *lifeLabel = (myTextLabel *)[summaryView viewWithTag:22];

    [workLabel setTextColor:self.myTextColor];
    [lifeLabel setTextColor:self.myTextColor];
    [self.tableMidLine setBackgroundColor:self.myTextColor];
    
    UIView *bottomLine1 = [workLabel viewWithTag:10];
    bottomLine1.backgroundColor = self.myTextColor;
    UIView *bottomLine2 = [lifeLabel viewWithTag:10];
    bottomLine2.backgroundColor = self.myTextColor;

}


-(void)cancelPriorLocalNotificationEveryNight
{
    NSArray * allLocalNotification=[[UIApplication sharedApplication] scheduledLocalNotifications];
    
    for (UILocalNotification * localNotification in allLocalNotification) {
        NSString * alarmValue=[localNotification.userInfo objectForKey:@"key"];
        if ([@"name" isEqualToString:alarmValue]) {
               [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
        }
    }
    return;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self cancelPriorLocalNotificationEveryNight];
    [self registerLuckChangedNotification];

    constellationList = [[NSArray alloc]initWithObjects:@"白羊座     3.21-4.19",@"金牛座     4.20-5.20",@"双子座     5.21-6.21",@"巨蟹座     6.22-7.22",@"狮子座     7.23-8.22",@"处女座     8.23-9.22",@"天秤座     9.23-10.23",@"天蝎座     10.24-11.22",@"射手座     11.23-12.21",@"摩羯座     12.22-1.19",@"水瓶座     1.20-2.18",@"双鱼座     2.19-3.20",nil];
    constellationSelected = constellationList[0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuStateEventOccurred:)
                                                 name:MFSideMenuStateNotificationEvent
                                               object:nil];
    
    self.titleTextLabel.alpha = 1.0f;
    self.TimelineText.alpha = 0.0f;
    

    
    [self configLuckyText];
    [self configTextColor];

    
    self.navigationController.navigationBarHidden = YES;
    self.luckyText.alpha = 1.0f;
    
    if (IS_IPHONE_6P || IS_IPHONE_6) {
        bottomHeight = 65;
    }else
    {
        bottomHeight = bottomBar;
    }
    
    self.maintableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT- bottomHeight -topBarHeight) style:UITableViewStylePlain];
    
//    self.maintableView.backgroundColor = [UIColor colorWithPatternImage:self.myBackImage.image];

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
    
    [self configHeaderView];
    [self configBottomView];
    
    if ([CommonUtility isSystemLangChinese]) {
        moneyLuckSpace = self.luckView.frame.size.height + self.luckView.frame.origin.y - topBarHeight;
    }else
    {
        moneyLuckSpace = 0;
    }
    if (IS_IPHONE_5) {
        moneyLuckSpace = moneyLuckSpace-58;
    }else if (IS_IPHONE_4_OR_LESS)
    {
        moneyLuckSpace = moneyLuckSpace-76;
    }else if(IS_IPHONE_6P)
    {
        moneyLuckSpace = moneyLuckSpace-20;
    }else
    {
        moneyLuckSpace = moneyLuckSpace-38;
    }
    
    UIView *midLine = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 0.5, moneyLuckSpace+ 18, 1, self.maintableView.frame.size.height)];
    midLine.backgroundColor = self.myTextColor;
    [self.maintableView addSubview:midLine];
    [self.maintableView sendSubviewToBack:midLine];
    self.tableMidLine = midLine;

    
    if ([CommonUtility isSystemLangChinese]) {
        [self.maintableView addObserver: self forKeyPath: @"contentOffset" options: NSKeyValueObservingOptionNew context: nil];
    }else
    {
        self.TimelineText.alpha = 1.0f;
        self.titleTextLabel.alpha =0.0f;
        self.luckyText.alpha = 0.0f;
    }
    
    [[RZTransitionsManager shared] setAnimationController:[[RZCirclePushAnimationController alloc] init]
                                       fromViewController:[self class]
                                                forAction:RZTransitionAction_PresentDismiss];
    
//    [[CommonUtility sharedCommonUtility] addADWithY:bottomHeight InView:self.view OfRootVC:self];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (self.maintableView.contentOffset.y > -0.0001 && self.maintableView.contentOffset.y - moneyLuckSpace*2/5 < 0.000001) {
        
        self.luckyText.alpha = 1.0 - self.maintableView.contentOffset.y/(moneyLuckSpace*1/3);
        self.titleTextLabel.alpha = 1.0 - self.maintableView.contentOffset.y/(moneyLuckSpace*1/3);
        self.TimelineText.alpha = 0.0f;
        
    }else if (self.maintableView.contentOffset.y > -0.0001 && self.maintableView.contentOffset.y - moneyLuckSpace < 0.000001)
    {
        self.TimelineText.alpha = (self.maintableView.contentOffset.y - moneyLuckSpace*2/5)/(moneyLuckSpace*3/5);
        self.titleTextLabel.alpha = 0.0f;
        self.luckyText.alpha = 0.0f;
        
        
    }else if (self.maintableView.contentOffset.y < -0.00001)
    {
        [self.maintableView setContentOffset:CGPointMake(0, 0)];
    }else
    {
        self.TimelineText.alpha = 1.0f;
        self.titleTextLabel.alpha = 0.0f;
        self.luckyText.alpha = 0.0f;
    }
    
}

-(void)prepareData
{
    
    self.todayItems = [[NSMutableArray alloc] init];
    
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"mainVC/Could not open db.");
        return;
    }
    
    NSString *today = [[CommonUtility sharedCommonUtility] todayDate];
    FMResultSet *rs = [db executeQuery:@"select * from EVENTS where date = ? ORDER BY startTime", today];
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
    
    [self.tableMidLine setFrame:CGRectMake(SCREEN_WIDTH/2 - 0.5, moneyLuckSpace+ 18, 1, self.maintableView.contentSize.height)];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.maintableView setContentOffset:CGPointMake(0, 0)];
    
    [super viewWillAppear:animated];
    [self prepareData];
    [MobClick beginLogPageView:@"homePage"];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"homePage"];
}

- (IBAction)menuTapped:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:^{
        if ([self.menuContainerViewController .rightMenuViewController isKindOfClass:[SideMenuViewController class]]) {
            SideMenuViewController *mySide = (SideMenuViewController *)self.menuContainerViewController .rightMenuViewController;
            mySide.myMenuTable.userInteractionEnabled = YES;
        }
    }];
    
}

- (void)menuStateEventOccurred:(NSNotification *)notification {
    
    if ([[[notification userInfo] objectForKey:@"eventType"] intValue] == MFSideMenuStateEventMenuDidClose) {
        self.menuContainerViewController.panMode = MFSideMenuPanModeNone ;
        
    }else if([[[notification userInfo] objectForKey:@"eventType"] intValue] == MFSideMenuStateEventMenuDidOpen)
    {
        self.menuContainerViewController.panMode = MFSideMenuPanModeDefault ;
    }
}

-(void)configLuckyText
{
    self.luckyText.minimumScaleFactor = 0.7f;
    self.luckyText.adjustsFontSizeToFitWidth =YES;
    
    NSString *Constellation = [[NSUserDefaults standardUserDefaults] objectForKey:@"Constellation"];
    if (!Constellation) {
        [self.luckyText makeText:@"设置星座，随时掌握财运 >"];
        return;
    }
    
    if ([CommonUtility isSystemLangChinese]) {
        [[CommonUtility sharedCommonUtility] fetchConstellation:Constellation ForView:self.luckyText];
    }
}

-(void)configHeaderView
{
    summaryView = [[UIView alloc] initWithFrame:CGRectMake( self.maintableView.frame.origin.x,  0,  self.maintableView.frame.size.width, summaryViewHeight )];
    summaryView.backgroundColor = [UIColor clearColor];
    
//    UIView *midLine = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 0.5, 15, 1, summaryViewHeight-15)];
//    midLine.backgroundColor = self.myTextColor;
//    [summaryView addSubview:midLine];

    myTextLabel *workLabel = [[myTextLabel alloc] initWithFrame:CGRectMake(0, 0, summaryView.frame.size.width/2, summaryViewHeight) andColor:self.myTextColor];
    [workLabel setText:NSLocalizedString(@"工作",nil)];
    UIView *bottomLine = [[UIView alloc ] initWithFrame:CGRectMake(workLabel.frame.size.width/8, workLabel.frame.size.height - 11, workLabel.frame.size.width*3/4, 1)];
    bottomLine.backgroundColor = self.myTextColor;
    [workLabel addSubview:bottomLine];
    bottomLine.tag = 10;
    workLabel.tag = 11;
    [summaryView addSubview:workLabel];
    
    myTextLabel *lifeLabel = [[myTextLabel alloc] initWithFrame:CGRectMake(summaryView.frame.size.width/2, 0, summaryView.frame.size.width/2, summaryViewHeight) andColor:self.myTextColor];
    [lifeLabel setText:NSLocalizedString(@"生活",nil)];
    UIView *bottomLine2 = [[UIView alloc ] initWithFrame:CGRectMake(workLabel.frame.size.width/8, workLabel.frame.size.height - 11, workLabel.frame.size.width*3/4, 1)];
    bottomLine2.backgroundColor = self.myTextColor;
    [lifeLabel addSubview:bottomLine2];
    bottomLine2.tag = 10;
    lifeLabel.tag =22;
    [summaryView addSubview:lifeLabel];
}


- (IBAction)showCalendar:(id)sender {
    
    calendarViewController *calendarVC = [[calendarViewController alloc] initWithNibName:@"calendarViewController" bundle:nil];
    [self.navigationController pushViewController:calendarVC animated:YES];
}

- (IBAction)showModes:(id)sender {
    
    [MobClick event:@"showModel"];
    
    UIView *dimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    dimView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.7];
    [self.view addSubview:dimView];
    self.myDimView = dimView;
    
    UIView *gestureView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT*3/4)];
    gestureView.backgroundColor = [UIColor clearColor];
    [dimView addSubview:gestureView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [gestureView addGestureRecognizer:tap];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT/4)];
    contentView.tag = 100;
    contentView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.9 alpha:0.9f];
    [dimView addSubview:contentView];
    [UIView animateWithDuration:0.32f delay:0.15f options:UIViewAnimationOptionLayoutSubviews animations:^{
        if (contentView) {
            [contentView setFrame:CGRectMake(contentView.frame.origin.x, SCREEN_HEIGHT*3/4, contentView.frame.size.width, contentView.frame.size.height)];
        }
    } completion:nil ];
    
    
    UILabel *autoChangeTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, contentView.frame.size.height*2/5)];
    [autoChangeTitle setText:NSLocalizedString(@"自动调整",nil) ];
    autoChangeTitle.textAlignment = NSTextAlignmentLeft;
    [contentView addSubview:autoChangeTitle];
    
    UISwitch *enableAutoSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(contentView.frame.size.width-110, autoChangeTitle.frame.size.height/2 -20, 80, 40)];
    enableAutoSwitch.tintColor = [UIColor colorWithRed:0.39 green:0.39 blue:0.42 alpha:0.88];
    [enableAutoSwitch setCenter:CGPointMake(contentView.frame.size.width-70, autoChangeTitle.center.y)];
    [contentView addSubview:enableAutoSwitch];
    NSString *autoSwitchString = [[NSUserDefaults standardUserDefaults] objectForKey:AUTOSWITCH];
    if ([autoSwitchString isEqualToString:@"on"])
    {
        enableAutoSwitch.on = YES;
    }else
    {
        enableAutoSwitch.on = NO;
    }
    [enableAutoSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
    UILabel *modelTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, contentView.frame.size.height*2/5, 80, contentView.frame.size.height*3/5)];
    [modelTitle setText:NSLocalizedString(@"显示模式",nil)];
    modelTitle.textAlignment = NSTextAlignmentLeft;
    [contentView addSubview:modelTitle];
    
    
    UIView *midline = [[UIView alloc] initWithFrame:CGRectMake(0, contentView.frame.size.height*2/5, contentView.frame.size.width, 0.65f)];
    midline.backgroundColor = [UIColor darkGrayColor];
    [contentView addSubview:midline];
    
    NSArray *timeTitle = @[@"白天",@"夜间"];
    for (int i = 2; i>0; i--) {
        UIButton *timeButton = [[UIButton alloc] initWithFrame:CGRectMake(contentView.frame.size.width - 85 - (2-i) *(60+45), contentView.frame.size.height*2/5 + modelTitle.frame.size.height/2 - 20, 60, 40)];
        timeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [timeButton setTitle:NSLocalizedString(timeTitle[i - 1] ,nil)forState:UIControlStateNormal];
        timeButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
        [timeButton setTitleColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.95] forState:UIControlStateNormal];
        timeButton.tag = i;
        [timeButton addTarget:self action:@selector(timeSelect:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:timeButton];
        
        UIView *selectedBar = [[UIView alloc] initWithFrame:CGRectMake(0, timeButton.frame.size.height-3, timeButton.frame.size.width, 3)];
        selectedBar.backgroundColor = [UIColor colorWithRed:247/255.0f green:81/255.0f blue:94/255.0f alpha:0.9];
        selectedBar.tag = 10;
        [timeButton addSubview:selectedBar];
        [selectedBar setHidden:YES];
    }
    
    NSString *showModel =  [[NSUserDefaults standardUserDefaults] objectForKey:SHOWMODEL];
    for (int i = 0 ; i < 2; i++) {
        if ([showModel isEqualToString:timeTitle[i]])
        {
            UIButton *button = (UIButton *)[contentView viewWithTag:i+1];
            
            [button setTitleColor:[UIColor colorWithRed:247/255.0f green:81/255.0f blue:94/255.0f alpha:0.9]forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:19.0f];
            UIView *selectBar = (UIView *)[button viewWithTag:10];
            [selectBar setHidden:NO];
            break;
        }
    }
}

-(void)timeSelect:(UIButton *)sender
{
    for (int i =2; i>0; i--) {
        UIView *superView = sender.superview;
        UIButton *button = (UIButton *)[superView viewWithTag:i];
        [button setTitleColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.95] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
        UIView *selectBar = (UIView *)[button viewWithTag:10];
        [selectBar setHidden:YES];
        
    }
    
    [sender setTitleColor:[UIColor colorWithRed:247/255.0f green:81/255.0f blue:94/255.0f alpha:0.9]forState:UIControlStateNormal];
    sender.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:19.0f];
    UIView *selectBar = (UIView *)[sender viewWithTag:10];
    [selectBar setHidden:NO];
    
    NSArray *timeTitle = @[@"白天",@"夜间"];
    
    [[NSUserDefaults standardUserDefaults] setObject:timeTitle[sender.tag - 1] forKey:SHOWMODEL];
    [[NSNotificationCenter defaultCenter] postNotificationName:ThemeChanged  object:nil];
    
    if ([timeTitle[sender.tag - 1] isEqualToString:@"白天"]) {
        self.myTextColor = TextColor0;
    }else if([timeTitle[sender.tag - 1] isEqualToString:@"夜间"]) {
        self.myTextColor = TextColor2;
    }

    [self.maintableView reloadData];
    [self configTextColor];
    
}
-(void)switchAction:(UISwitch *)sender
{
    if (sender.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"on" forKey:AUTOSWITCH];
    }else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"off" forKey:AUTOSWITCH];
    }
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate judgeTimeFrame];
    
    NSString *showModel =  [[NSUserDefaults standardUserDefaults] objectForKey:SHOWMODEL];
    NSArray *timeTitle = @[@"白天",@"夜间"];
    UIView *contentView = [self.myDimView viewWithTag:100];
    
    //还原未选状态
    for (int i =2 ; i>0; i--) {
        UIView *superView = sender.superview;
        UIButton *button = (UIButton *)[superView viewWithTag:i];
        [button setTitleColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.95] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.5f];
        UIView *selectBar = (UIView *)[button viewWithTag:10];
        [selectBar setHidden:YES];
        
    }
    //选择一个模式
    for (int i = 0 ; i < 2; i++) {
        if ([showModel isEqualToString:timeTitle[i]])
        {
            UIButton *button = (UIButton *)[contentView viewWithTag:i+1];
            
            [button setTitleColor:[UIColor colorWithRed:247/255.0f green:81/255.0f blue:94/255.0f alpha:0.9]forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:19.0f];
            UIView *selectBar = (UIView *)[button viewWithTag:10];
            [selectBar setHidden:NO];
            break;
        }
    }
    
}
-(void)dismissKeyboard
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

- (IBAction)configConstellation:(id)sender {
    
    constellationView *constellView = [[constellationView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    constellView.constellPicker.delegate = self;
    constellView.constellPicker.dataSource = self;
    constellView.constellDelegate = self;
    [constellView addGesture];
    NSString *Constellation = [[NSUserDefaults standardUserDefaults] objectForKey:@"Constellation"];

    NSInteger row = 0;
    for (int i = 0; i<constellationList.count; i ++) {
        if ([Constellation isEqualToString:[constellationList[i] componentsSeparatedByString:@" "][0]]) {
            row = i;
            break;
        }
    }
    [constellView.constellPicker selectRow:12*1000 + row inComponent:0 animated:NO];

    self.myConstellView = constellView;
    [self.view addSubview:constellView];
    
}
-(void)constellationChoose
{
    [MobClick event:@"setConstellation"];
    
    NSString *constellationOnly = [constellationSelected componentsSeparatedByString:@" "][0];
    
    [[NSUserDefaults standardUserDefaults] setObject:constellationOnly forKey:@"Constellation"];
    if ([CommonUtility isSystemLangChinese]) {
        [[CommonUtility sharedCommonUtility] fetchConstellation:constellationOnly ForView:self.luckyText];
    }
    
    if ([self.luckyText.text isEqualToString:@"设置星座，随时掌握财运 >"]) {
        [UIView animateWithDuration:0.35f animations:^(void){
            [self.maintableView setContentOffset:CGPointMake(0, moneyLuckSpace)];
        }];
    }
    [self.myConstellView removeDimView];
    
}
-(void)cancelConstellation
{
    [self.myConstellView removeDimView];
}

-(void)configBottomView
{

    CGFloat space = 10;
    if (IS_IPHONE_5_OR_LESS) {
        space =5;
    }
    
    BottomView *bottomView = [[BottomView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-bottomHeight, SCREEN_WIDTH, bottomHeight)];
    bottomView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:bottomView];
    
    highLightButton *addNewButton = [[highLightButton alloc] initWithFrame:CGRectMake(20, space, SCREEN_WIDTH/2-40, bottomHeight-2*space)];
    
    [addNewButton setTitleColor:TextColor1 forState:UIControlStateNormal];
    addNewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    addNewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    addNewButton.layer.borderColor = self.myTextColor.CGColor;
    addNewButton.layer.borderWidth = 0.75;
    [addNewButton setTitle:NSLocalizedString(@"新事项",nil) forState:UIControlStateNormal];
    CGFloat scale = 0.6f;
    if (IS_IPHONE_6) {
        scale = 0.5f;
    }else
    {
        scale = 0.65f;
    }
    [addNewButton addLeftImage:[UIImage imageNamed:@"addEvent"] andScale:scale];
    self.addNewBtn = addNewButton;
    
    highLightButton *trackButton = [[highLightButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2+20, space, SCREEN_WIDTH/2-40, bottomHeight-2*space)];
    [trackButton setTitle:NSLocalizedString(@"目标推进",nil) forState:UIControlStateNormal];
    trackButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    trackButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [trackButton setTitleColor:TextColor1 forState:UIControlStateNormal];
    trackButton.layer.borderColor = self.myTextColor.CGColor;
    trackButton.layer.borderWidth = 0.75;
    [trackButton addLeftImage:[UIImage imageNamed:@"goal"] andScale:scale];

    self.trackBtn = trackButton;
    
    [addNewButton addTarget:self action:@selector(addNewItem:) forControlEvents:UIControlEventTouchUpInside];
    [trackButton addTarget:self action:@selector(trackItems) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomView addSubview:trackButton];
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
    NSDate *targetDay = [NSDate date];
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setDateFormat:@"yyyy-MM-dd"];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    dateFormatter1.calendar = cal;
    
    NSString *targetDate = [dateFormatter1 stringFromDate:targetDay];
    addItemVC.targetDate = targetDate;
    
    NSString *now = [[CommonUtility sharedCommonUtility] timeNow];
    NSString *nowLater =[[CommonUtility sharedCommonUtility] timeByAddingMinutes:now andMinsToAdd:30];
    
    addItemVC.itemStartTime = now;
    addItemVC.itemEndTime = nowLater;
    
    return addItemVC;
}

-(void)trackItems
{
    trackViewController *trackVC = [[trackViewController alloc] initWithNibName:@"trackViewController" bundle:nil];
    [self.navigationController pushViewController:trackVC animated:YES];
}

#pragma mark picker delegate
// pickerView 列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view
{
    pickerLabel *picker = [[pickerLabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 60, 38)];
    [picker makeText:[constellationList objectAtIndex:(row%[constellationList count])]];
    return picker;
}



// pickerView 每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [constellationList count] + 1000000;
}

// 每列宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
    return SCREEN_WIDTH-60;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 38;
}
// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    constellationSelected = [constellationList objectAtIndex:(row%[constellationList count])];
    NSLog(@"constellationSelected  :%@",constellationSelected);

}

//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [constellationList objectAtIndex:(row%[constellationList count])];
}



#pragma mark -
#pragma mark Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if ([CommonUtility isSystemLangChinese]) {
            return moneyLuckSpace;
        }
        return 0;
    }else if(indexPath.section == 1 && indexPath.row == self.todayItems.count){
        
        return (self.maintableView.frame.size.height - summaryViewHeight - (rowHeight * self.todayItems.count));

    }else
        return rowHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }else if (section == 1 ) {
        return summaryViewHeight;
    }else
        return 0;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        [self configConstellation:nil];
    }else
    {
        if (indexPath.row< self.todayItems.count) {
            checkEventViewController *myCheckVC = [[checkEventViewController alloc] initWithNibName:@"checkEventViewController" bundle:nil];
            myCheckVC.currentItem = self.todayItems[indexPath.row];
            [self.navigationController pushViewController:myCheckVC animated:YES];
        }

    }

}


#pragma mark -
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView             // Default is 1 if not implemented
{
    return 2;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0 )
    {
        return nil;
    }else if (section == 1)
    {
        return summaryView;
    }else
        return nil;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    }else if(section == 1)
    {

        return self.todayItems.count<((self.maintableView.frame.size.height-summaryViewHeight)/rowHeight)?self.todayItems.count +1:self.todayItems.count ;
    }else
    {
        return self.todayItems.count;
    }
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        return cell;
        
    }else if(indexPath.section == 1 && indexPath.row == self.todayItems.count)
    {
        NSString *CellIdentifier = @"CellFill1";
        
        myLifeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[myLifeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            
        }
        
        return cell;
    }else 
    {
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
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    for (UITableViewCell *cell in self.maintableView.visibleCells) {
        if ([cell isKindOfClass:[myLifeTableViewCell class]] ) {
            myLifeTableViewCell *oneCell = (myLifeTableViewCell *)cell;
            CGFloat hiddenFrameHeight = scrollView.contentOffset.y + summaryViewHeight - cell.frame.origin.y;
            if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
                [oneCell maskCellFromTop:hiddenFrameHeight];
            }
        }else  if ([cell isKindOfClass:[myWorkTableViewCell class]] ) {
            myWorkTableViewCell *oneCell = (myWorkTableViewCell *)cell;
            CGFloat hiddenFrameHeight = scrollView.contentOffset.y + summaryViewHeight - cell.frame.origin.y;
            if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
                [oneCell maskCellFromTop:hiddenFrameHeight];
            }
        }

    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView// called when scroll view grinds to a halt
{
    if ([CommonUtility isSystemLangChinese] && scrollView.contentOffset.y<moneyLuckSpace && scrollView.contentOffset.y>0.001) {
        
        //    if (scrollView.contentOffset.y<moneyLuckSpace && scrollView.contentOffset.y>0.001) {
        [UIView animateWithDuration:0.35f animations:^(void){
            [scrollView setContentOffset:CGPointMake(0, moneyLuckSpace)];
        }];
    }else
        return;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([CommonUtility isSystemLangChinese] && scrollView.contentOffset.y<moneyLuckSpace && scrollView.contentOffset.y>0.001) {
        
        //    if (scrollView.contentOffset.y<moneyLuckSpace && scrollView.contentOffset.y>0.001) {
        
        if (!decelerate) {
            [UIView animateWithDuration:0.35f animations:^(void){
                [scrollView setContentOffset:CGPointMake(0, moneyLuckSpace)];
            }];
        }else
            return;
        
    }else
        return;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
