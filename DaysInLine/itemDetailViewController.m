//
//  itemDetailViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 4/23/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "itemDetailViewController.h"
#import "global.h"
#import "topBarView.h"
#import "itemDetailTableViewCell.h"
#import "CommonUtility.h"
#import "RZTransitions.h"
#import "BottomView.h"
#import "categoryTableViewCell.h"
#import "categoryObject.h"
#import "categoryManagementViewController.h"
#import "dateSelectView.h"
#import "pickerLabel.h"
#import "photoCell.h"
#import "AppDelegate.h"


@interface itemDetailViewController ()<UITableViewDataSource,UITableViewDelegate,showPadDelegate,categoryTapDelegate,FlatDatePickerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    CGFloat bottomHeight;
    CGFloat btnHeight;
    BOOL isNewRecord;

}
@property (nonatomic,strong) UITableView *itemInfoTable;
@property (nonatomic,strong) UITableView *photoTable;
@property (nonatomic ,strong) UITableView *categoryTableView;
@property (nonatomic,strong) UIView *myDimView;

@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) NSMutableArray *workCategoryArray;
@property (nonatomic,strong) NSMutableArray *lifeCategoryArray;
@property (nonatomic ,strong) UISegmentedControl *moneyTypeSeg;
@property (nonatomic,strong) dateSelectView *dateView;
@property (nonatomic, strong) UIPickerView *timePicker;
@property (nonatomic, strong) UIImageView *bigPhoto;

@property (nonatomic,strong) NSMutableArray *photosArray;

@property (nonatomic,strong) NSArray *dayOffsiteArray;
@property (nonatomic,strong) NSArray *hourArray;
@property (nonatomic,strong) NSArray *minuteArray;

@property (nonatomic,strong) NSString *hourTemp;
@property (nonatomic,strong) NSString *minuteTemp;
@property (nonatomic,strong) NSString *dayOffsiteTemp;

@property (nonatomic ,strong) UIView *noteView;
@property (nonatomic ,strong) UITextView *noteBody;
@property (nonatomic ,strong) UIButton *noteDoneButton;

//recorder
@property (strong, nonatomic)  UIImageView *voiceImageview;
@property (nonatomic, strong)AVAudioPlayer * avPlay;
@property (nonatomic, strong) AVAudioRecorder * recorder;
//坚挺音量大小,控制话筒图片
@property (nonatomic, strong) NSTimer * timer;
@end

@implementation itemDetailViewController
@synthesize db;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self preparePhotos];
    [self configDimView];
    [self configAudio];
    [self configNoteView];
    [self configTopbar];
    [self configDetailTable];
    [self configBottomView];
    
//    if (IS_IPHONE_5_OR_LESS) {
//        
//    }else
//    {
//        [[CommonUtility sharedCommonUtility] addADWithY:0 InView:self.view OfRootVC:self];
//    }
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    self.workCategoryArray = [[CommonUtility sharedCommonUtility] prepareCategoryDataForWork:YES];
    self.lifeCategoryArray = [[CommonUtility sharedCommonUtility] prepareCategoryDataForWork:NO];
    [MobClick beginLogPageView:@"itemDetail"];
}

- (void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"viewWillDisappear");
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [MobClick endLogPageView:@"itemDetail"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)preparePhotos
{
    self.photosArray = [[NSMutableArray alloc] init];
    if (self.photoNames) {
        
        NSURL *storeURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.sheepcao.DaysInLine"];
        NSString *destPath = [storeURL path];
        
        NSArray *namesArray = [self.photoNames componentsSeparatedByString:@";"];
        for (int i = 0; i < namesArray.count; i++) {
            NSString *fullPath = [destPath stringByAppendingPathComponent:namesArray[i]];
            UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
            if (savedImage) {
                [self.photosArray addObject:savedImage];
            }
        }
    }
    [self.photosArray addObject:[UIImage imageNamed:@"addPic.png"]];

}


-(void)configDimView
{
    
    self.timePicker = [[UIPickerView alloc]initWithFrame:CGRectMake(20, 20,SCREEN_WIDTH-40 , 200 -25)];
    self.timePicker.showsSelectionIndicator=YES;
    self.timePicker.delegate = self;

    
    self.dayOffsiteArray = [NSArray arrayWithObjects:@" ",@"+1", nil];
    self.hourArray = [NSArray arrayWithObjects:@"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23", nil];
    
    NSMutableArray *minTempArray = [[NSMutableArray alloc] init];
    for (int i =0; i<60; i++) {
        [minTempArray addObject:[NSString stringWithFormat:@"%02d",i]];
    }
    self.minuteArray = [NSArray arrayWithArray:minTempArray];
    
}
-(void)configTopbar
{
    topBarView *topbar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topBarHeight)];
    topbar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topbar];
    
    if (self.isEditing) {
        [topbar.titleLabel  setText:NSLocalizedString(@"事项编辑",nil)];
    }else
    {
        [topbar.titleLabel  setText:NSLocalizedString(@"新增事项",nil)];
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
    [saveButton addTarget:self action:@selector(saveItem:) forControlEvents:UIControlEventTouchUpInside];
    saveButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:saveButton];
    
    
}

-(void)configBottomView
{
    CGFloat photoHeigh;
    if (IS_IPHONE_4_OR_LESS) {
        photoHeigh = 100;
    }else
    {
        photoHeigh = 135;
    }
    
    CGFloat f = (SCREEN_HEIGHT-SCREEN_WIDTH)*0.5;
    self.photoTable = [[UITableView alloc]initWithFrame:CGRectMake(0, f, photoHeigh, SCREEN_WIDTH) style:UITableViewStylePlain];
    [self.photoTable setCenter:CGPointMake(SCREEN_WIDTH/2, self.itemInfoTable.frame.size.height + self.itemInfoTable.frame.origin.y+photoHeigh-30)];
    self.photoTable.dataSource = self;
    self.photoTable.delegate = self;
    self.photoTable.transform = CGAffineTransformMakeRotation(-M_PI/2);
    self.photoTable.backgroundColor = [UIColor clearColor];
    self.photoTable.pagingEnabled = YES;
    self.photoTable.showsVerticalScrollIndicator = NO;
    self.photoTable.separatorStyle = UITableViewCellSeparatorStyleNone;

    UIView *upline = [[UIView alloc] initWithFrame:CGRectMake(0,self.photoTable.frame.origin.y-1.5,self.photoTable.frame.size.width, 1.2)];
    upline.backgroundColor = normalColor;
    upline.layer.shadowOffset = CGSizeMake(0.5, 0.6);
    upline.layer.shadowColor = [UIColor blackColor].CGColor;
    upline.layer.shadowOpacity = 0.8;
    
    UIView *downline = [[UIView alloc] initWithFrame:CGRectMake(0,self.photoTable.frame.origin.y + self.photoTable.frame.size.height-1.5,self.photoTable.frame.size.width,1.2)];
    downline.backgroundColor = normalColor;
    downline.layer.shadowOffset = CGSizeMake(0.5, 0.6);
    downline.layer.shadowColor = [UIColor blackColor].CGColor;
    downline.layer.shadowOpacity = 0.8;
    [self.view addSubview:upline];
    [self.view addSubview:downline];

    [self.view addSubview:self.photoTable];
  
}


-(void)configDetailTable
{
    CGFloat height ;
    if (IS_IPHONE_4_OR_LESS) {
        height =50;
    }else
    {
        height =60;
    }
    
    self.itemInfoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, topBarHeight + 5, SCREEN_WIDTH, height*5 )];
    self.itemInfoTable.showsVerticalScrollIndicator = NO;
    self.itemInfoTable.scrollEnabled = NO;
    self.itemInfoTable.backgroundColor = [UIColor clearColor];
    self.itemInfoTable.delegate = self;
    self.itemInfoTable.dataSource = self;
    self.itemInfoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.itemInfoTable];
    
}

-(void)configNoteView
{
    if (IS_IPHONE_4_OR_LESS) {
        btnHeight = 34;
    }else
    {
        btnHeight = 44;
    }
    
    UIView *noteView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 150)];
    noteView.backgroundColor = numberColor;
    self.noteView = noteView;
    [self.view addSubview:noteView];
    UILabel *noteTitle = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 25, 3, 50, 17)];
    noteTitle.backgroundColor = [UIColor clearColor];
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                 @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                   UIFontDescriptorNameAttribute:@"HelveticaNeue",
                                                   UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: 16.0f]
                                                   }];
    [noteTitle setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0]];
    [noteTitle setText:NSLocalizedString(@"备 注",nil)];
    [noteTitle setTextColor:[UIColor whiteColor]];
    noteTitle.textAlignment = NSTextAlignmentCenter;
    
    
    UIButton *finishNoteButton = [[UIButton alloc] initWithFrame:CGRectMake(noteView.frame.size.width - 70, noteView.frame.size.height - btnHeight +4, 70, btnHeight)];
    [finishNoteButton setImage:[UIImage imageNamed:@"doneBig"] forState:UIControlStateNormal];
    [finishNoteButton setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 2, 15)];
    //    [finishNoteButton setTitle:@"完成" forState:UIControlStateNormal];
    finishNoteButton.layer.cornerRadius = 4.0f;
    [finishNoteButton setBackgroundColor:[UIColor colorWithRed:242/255.0f green:191/255.0f blue:109/255.0f alpha:1.0f]];
    [finishNoteButton addTarget:self action:@selector(finishNote) forControlEvents:UIControlEventTouchUpInside];
    self.noteDoneButton = finishNoteButton;
    [noteView addSubview:finishNoteButton];
    
    
    UITextView *noteText = [[UITextView alloc] initWithFrame:CGRectMake(20, noteTitle.frame.origin.y+noteTitle.frame.size.height + 5, SCREEN_WIDTH-40, noteView.frame.size.height - (noteTitle.frame.origin.y+noteTitle.frame.size.height + 5) - finishNoteButton.frame.size.height)];
    UIFontDescriptor *bodyFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                            @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                              UIFontDescriptorNameAttribute:@"HelveticaNeue-LightItalic",
                                              UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: 14.0f]
                                              }];
    [noteText setFont:[UIFont fontWithDescriptor:bodyFontDescriptor size:0.0]];
    noteText.backgroundColor = [UIColor clearColor];
    [noteText setTextColor:self.myTextColor];
    noteText.textAlignment = NSTextAlignmentLeft;
    noteText.tintColor = [UIColor whiteColor];
    
    self.noteBody = noteText;
    [noteView addSubview:noteTitle];
    [noteView addSubview:noteText];
    
    
}

-(void)updateNotePad
{
    [self.noteDoneButton setFrame:CGRectMake(self.noteView.frame.size.width - 70, self.noteView.frame.size.height - btnHeight + 4, 70, btnHeight)];
    [self.noteBody setFrame:CGRectMake(20, 25, SCREEN_WIDTH-40, self.noteView.frame.size.height - 25 - self.noteDoneButton.frame.size.height)];
    
}

-(void)keyboardWasShown:(NSNotification*)notification
{

    if ([[UIApplication sharedApplication] applicationState] !=UIApplicationStateActive) {
        return;
    }
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.noteView setFrame:CGRectMake(0, 150, self.noteView.frame.size.width, SCREEN_HEIGHT-keyboardSize.height-(150))];
        [self updateNotePad];
    }];
    
    
    [self.view layoutIfNeeded];
}

-(void)finishNote
{
    [UIView animateWithDuration:0.25f animations:^{
        [self.noteView setFrame:CGRectMake(0, SCREEN_HEIGHT, self.noteView.frame.size.width, self.noteView.frame.size.height)];
    }];
    [self.view layoutIfNeeded];

    
    if (self.noteBody.text && ![[self.noteBody.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        self.itemDescription = self.noteBody.text;
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
        [indexPaths addObject: indexPath];
        [self.itemInfoTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        
    }
    

    [self dismissDimView];
    [self.noteBody resignFirstResponder];


    [MobClick event:@"addNote"];
    
}

- (void)configAudio
{
    
    NSMutableDictionary *recodeSeting = [@{} mutableCopy];
    [recodeSeting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    //录音通道数
    [recodeSeting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    //线性采样位数
    [recodeSeting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音质量
    [recodeSeting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    //数据持久化(将声音存储到磁盘中)
    NSString *strUrl = [[CommonUtility sharedCommonUtility] voicePathWithRecorderID:[self searchEventID]];
    NSURL *url = [NSURL fileURLWithPath:strUrl];
    NSError *error = nil;
    //初始化AVAudioRecorder
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                        error:nil];
    
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recodeSeting error:&error];
    self.recorder.meteringEnabled = YES;
    
    
    AVAudioPlayer * player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recorder.url error:nil];
    self.avPlay = player;
    if(player)
    {
        isNewRecord = NO;
    }else
    {
        isNewRecord = YES;
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
        return [self.currentItemID intValue];
    }else
    {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM SQLITE_SEQUENCE WHERE name='EVENTS'"];
        if ([rs next]) {
            recorderID = [rs intForColumn:@"seq"];
        }
        
        [db close];
        return recorderID+1;
    }
    
}

#pragma mark save event

-(void)saveItem:(UIButton *)sender
{
    NSLog(@"saving item...");
    if (![self validateData]) {
        return;
    }
    
    if (![db open]) {
        NSLog(@"addNewItemVC/Could not open db.");
        return;
    }
    
    double startNum = [[CommonUtility sharedCommonUtility] timeToDouble:self.itemStartTime];
    double endNum = [[CommonUtility sharedCommonUtility] timeToDouble:self.itemEndTime];

    
    if (self.isEditing) {
        BOOL sql = [db executeUpdate:@"update EVENTS set TYPE=? ,TITLE = ? ,mainText = ? ,startTime = ? ,endTime = ? ,distance = ? ,photoDir = ? where eventID = ?" ,[NSNumber numberWithInteger:self.itemType],self.category,self.itemDescription,[NSNumber numberWithDouble:startNum],[NSNumber numberWithDouble:endNum],[NSNumber numberWithDouble:(endNum - startNum)],self.photoNames,[NSNumber numberWithInt:[self searchEventID]]];
        if (!sql) {
            NSLog(@"ERROR123: %d - %@", db.lastErrorCode, db.lastErrorMessage);
        }else
        {
            [self.refreshDelegate refreshData];
            [self dismissViewControllerAnimated:YES completion:nil];
            
            [MobClick event:@"editItem"];
            
        }
    }else
    {
        BOOL sql = [db executeUpdate:@"INSERT INTO EVENTS(TYPE,TITLE,mainText,date,startTime,endTime,distance,photoDir) VALUES(?,?,?,?,?,?,?,?)" ,[NSNumber numberWithInteger:self.itemType],self.category,self.itemDescription,self.targetDate,[NSNumber numberWithDouble:startNum],[NSNumber numberWithDouble:endNum],[NSNumber numberWithDouble:(endNum - startNum)],self.photoNames];
        
        if (!sql) {
            NSLog(@"ERROR: %d - %@", db.lastErrorCode, db.lastErrorMessage);
        }else
        {
            if (self.relatedGoalID) {
                if (self.isRelatedGoalByTime) {
                    
                    double doneTime =0.0;
                    FMResultSet *rs = [db executeQuery:@"select done_time from GOALS where goal_id = ?", [NSNumber numberWithInteger:self.relatedGoalID]];
                    if ([rs next]) {
                        doneTime = [rs doubleForColumn:@"done_time"];
                    }
                    double hours = (endNum - startNum)/60;
                    BOOL sql = [db executeUpdate:@"UPDATE GOALS set done_time = ?  where goal_id = ?" ,[NSNumber numberWithDouble:(doneTime + hours)] ,[NSNumber numberWithInteger:self.relatedGoalID]];
                    
                    if (!sql) {
                        NSLog(@"ERROR: %d - %@", db.lastErrorCode, db.lastErrorMessage);
                    }
                }else
                {
                    int doneCount =0;
                    FMResultSet *rs = [db executeQuery:@"select done_count from GOALS where goal_id = ?", [NSNumber numberWithInteger:self.relatedGoalID]];
                    if ([rs next]) {
                        doneCount = [rs intForColumn:@"done_count"];
                    }
                    BOOL sql = [db executeUpdate:@"UPDATE GOALS set done_count = ?  where goal_id = ?" ,[NSNumber numberWithDouble:(doneCount + 1)] ,[NSNumber numberWithInteger:self.relatedGoalID]];

                    if (!sql) {
                        NSLog(@"ERROR: %d - %@", db.lastErrorCode, db.lastErrorMessage);
                    }

                }
            }
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.refreshDelegate refreshData];
            if (self.moneyTypeSeg.selectedSegmentIndex == 0) {
                [MobClick event:@"addWork"];
            }else
            {
                [MobClick event:@"addLife"];
            }

        }
        
    }
    [db close];
    
}

-(BOOL)validateData
{
    double startNum = [[CommonUtility sharedCommonUtility] timeToDouble:self.itemStartTime];
    double endNum = [[CommonUtility sharedCommonUtility] timeToDouble:self.itemEndTime];

    if (!self.category) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.animationType = MBProgressHUDAnimationZoom;
        hud.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"请选择一个主题",nil) ;
        [hud hide:YES afterDelay:1.5];
        
        return NO;
    }else if (startNum >= endNum)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.animationType = MBProgressHUDAnimationZoom;
        hud.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"开始时间应该早于结束时间",nil);
        [hud hide:YES afterDelay:1.5];
        return NO;

    }else
    {
        if (!self.itemDescription) {
            self.itemDescription = @"";
        }
        
        if (!self.photoNames) {
            self.photoNames = @"";
        }
    }
    

    
    return YES;
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
    }else if (row == 1 || row == 2 )
    {

        
//        self.timePicker = [[UIPickerView alloc]initWithFrame:CGRectMake(20, 20,SCREEN_WIDTH-40 , contentView.frame.size.height -25)];
//        self.timePicker.showsSelectionIndicator=YES;
//        self.timePicker.delegate = self;
        self.timePicker.tag = row;
        [contentView addSubview:self.timePicker];
        [self.timePicker reloadAllComponents];
        
        if (row == 1) {
            NSString *hour = [self.itemStartTime componentsSeparatedByString:@":"][0];
            [self.timePicker selectRow:[hour integerValue] inComponent:0 animated:YES];
            [self pickerView:self.timePicker didSelectRow:[hour integerValue] inComponent:0];
            
            NSString *minute = [self.itemStartTime componentsSeparatedByString:@":"][1];
            [self.timePicker selectRow:[minute integerValue] inComponent:1 animated:YES];
            [self pickerView:self.timePicker didSelectRow:[minute integerValue] inComponent:1];

        }else
        {
            NSArray *endArrray = [self.itemEndTime componentsSeparatedByString:@"  "];
            if (endArrray.count > 1) {
                [self.timePicker selectRow:1 inComponent:0 animated:YES];
                [self pickerView:self.timePicker didSelectRow:1 inComponent:0];
                
                NSString *times = endArrray[1];
                
                NSString *hour = [times componentsSeparatedByString:@":"][0];
                [self.timePicker selectRow:[hour integerValue] inComponent:1 animated:YES];
                [self pickerView:self.timePicker didSelectRow:[hour integerValue] inComponent:1];
                
                NSString *minute = [times componentsSeparatedByString:@":"][1];
                [self.timePicker selectRow:[minute integerValue] inComponent:2 animated:YES];
                [self pickerView:self.timePicker didSelectRow:[minute integerValue] inComponent:2];
                
            }else
            {
                [self.timePicker selectRow:0 inComponent:0 animated:YES];
                [self pickerView:self.timePicker didSelectRow:0 inComponent:0];
                
                
                NSString *hour = [self.itemEndTime componentsSeparatedByString:@":"][0];
                [self.timePicker selectRow:[hour integerValue] inComponent:1 animated:YES];
                [self pickerView:self.timePicker didSelectRow:[hour integerValue] inComponent:1];
                
                NSString *minute = [self.itemEndTime componentsSeparatedByString:@":"][1];
                [self.timePicker selectRow:[minute integerValue] inComponent:2 animated:YES];
                [self pickerView:self.timePicker didSelectRow:[minute integerValue] inComponent:2];
            }

        }
        
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(8, 5, 60, 35)];
        [cancelBtn setTitle:NSLocalizedString(@"取消",nil) forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.95] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue" size:15.0];
        [contentView addSubview:cancelBtn];
        
        UIButton *selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(contentView.frame.size.width-68, 5, 60, 35)];
        [selectBtn setTitle:NSLocalizedString(@"确定",nil) forState:UIControlStateNormal];
        [selectBtn setTitleColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.95] forState:UIControlStateNormal];
        selectBtn.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        [contentView addSubview:selectBtn];
        selectBtn.tag = 20+row;
        
        [cancelBtn addTarget:self action:@selector(cancelTime) forControlEvents:UIControlEventTouchUpInside];
        [selectBtn addTarget:self action:@selector(timeChoose:) forControlEvents:UIControlEventTouchUpInside];

    }else if(row == 6)
    {
        self.myDimView.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.93];

        
        UIView *operateBar = [[UIView alloc] initWithFrame:CGRectMake(6, 0,(SCREEN_WIDTH -32), 50)];
        operateBar.backgroundColor = [UIColor colorWithRed:0.18f green:0.18f blue:0.18f alpha:1.0f] ;
        UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
//        [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [deleteBtn setImage:[UIImage imageNamed:@"delete0"] forState:UIControlStateNormal];
        [deleteBtn setImageEdgeInsets:UIEdgeInsetsMake(6, 5, 6, 5)];
//        deleteBtn.layer.borderWidth = 0.5f;
        deleteBtn.layer.borderColor = normalColor.CGColor;
        
        UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(operateBar.frame.size.width - 45 , 5, 40, 40)];
//        [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
        [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [closeBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];

//        closeBtn.layer.borderWidth = 0.5f;
        closeBtn.layer.borderColor = normalColor.CGColor;
        
        UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(operateBar.frame.size.width/2 - 45 , 5, 40, 40)];
        [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        [leftBtn setImage:[UIImage imageNamed:@"left"] forState:UIControlStateNormal];
//        leftBtn.layer.borderWidth = 0.5f;
        leftBtn.layer.borderColor = normalColor.CGColor;
        
        UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(operateBar.frame.size.width/2+5 , 5, 40, 40)];
        [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        [rightBtn setImage:[UIImage imageNamed:@"right"] forState:UIControlStateNormal];

//        rightBtn.layer.borderWidth = 0.5f;
        rightBtn.layer.borderColor = normalColor.CGColor;
        
        [operateBar addSubview:deleteBtn];
        [operateBar addSubview:closeBtn];
        [operateBar addSubview:leftBtn];
        [operateBar addSubview:rightBtn];
        [contentView addSubview:operateBar];
        
        [deleteBtn addTarget:self action:@selector(deletePhoto) forControlEvents:UIControlEventTouchUpInside];
        [closeBtn addTarget:self action:@selector(closePhoto) forControlEvents:UIControlEventTouchUpInside];
        [leftBtn addTarget:self action:@selector(leftPhoto) forControlEvents:UIControlEventTouchUpInside];
        [rightBtn addTarget:self action:@selector(rightPhoto) forControlEvents:UIControlEventTouchUpInside];
        
        self.bigPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(6, operateBar.frame.size.height, (SCREEN_WIDTH -32), (SCREEN_WIDTH -32))];
        [contentView addSubview:self.bigPhoto];

    }
}

-(void)deletePhoto
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"确认删除照片?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:NSLocalizedString(@"删除",nil), nil];
    alert.tag = 11;
    [alert show];
    

}

-(void)closePhoto
{
    [self dismissDimView];
}

-(void)leftPhoto
{
    NSUInteger index =  [self.photosArray indexOfObject:self.bigPhoto.image];
    if (index>0) {
        
        UIImage *image = self.photosArray[index-1];
        CGRect aframe = self.bigPhoto.frame;
        aframe.size.height = (image.size.height/image.size.width) *aframe.size.width;
        [self.bigPhoto setFrame:aframe];
        [self.bigPhoto setImage:self.photosArray[index - 1]];
    }
}

-(void)rightPhoto
{
    NSUInteger index =  [self.photosArray indexOfObject:self.bigPhoto.image];
    if (index<self.photosArray.count -2) {
        UIImage *image = self.photosArray[index + 1];
        CGRect aframe = self.bigPhoto.frame;
        aframe.size.height = (image.size.height/image.size.width) *aframe.size.width;
        [self.bigPhoto setFrame:aframe];
        [self.bigPhoto setImage:self.photosArray[index + 1]];
    }
}


-(void)segmentAction:(UISegmentedControl *)Seg{
    NSInteger Index = Seg.selectedSegmentIndex;
    NSLog(@"Index %ld", (long)Index);
    [self.categoryTableView reloadData];
    
}

-(void)timeChoose:(UIButton *)sender
{
    if (sender.tag == 21) {
        self.itemStartTime = [NSString stringWithFormat:@"%@:%@",self.hourTemp,self.minuteTemp];
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [indexPaths addObject: indexPath];
        [self.itemInfoTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];

    }else
    {
        if ([self.dayOffsiteTemp isEqualToString:@" "]) {
            self.itemEndTime = [NSString stringWithFormat:@"%@:%@",self.hourTemp,self.minuteTemp];
        }else
        {
            self.itemEndTime = [NSString stringWithFormat:@"%@  %@:%@",self.dayOffsiteTemp,self.hourTemp,self.minuteTemp];
        }
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        [indexPaths addObject: indexPath];
        [self.itemInfoTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];

    }

    [self dismissDimView];
}

-(void)cancelTime
{
    [self dismissDimView];
}



#pragma mark picker delegate
// pickerView 列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (pickerView.tag == 1) {
        return 2;
    }else
        return 3;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view
{
    pickerLabel *picker = [[pickerLabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 60, 38)];
    if (pickerView.tag == 1) {
        
        if (component == 0) {
            [picker makeText:[self.hourArray objectAtIndex:(row%[self.hourArray count])]];
        }else if(component == 1)
        {
            [picker makeText:[self.minuteArray objectAtIndex:(row%[self.minuteArray count])]];
        }
    }else
    {
        if (component == 0) {
            [picker makeText:[self.dayOffsiteArray objectAtIndex:(row%[self.dayOffsiteArray count])]];
        }else if (component == 1) {
            [picker makeText:[self.hourArray objectAtIndex:(row%[self.hourArray count])]];
        }else if(component == 2)
        {
            [picker makeText:[self.minuteArray objectAtIndex:(row%[self.minuteArray count])]];
        }

    }
    
    return picker;

}



// pickerView 每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (pickerView.tag == 1) {
        
        return 1000000;
    }else
    {
        if (component == 0) {
            return 2;
        }else
            return 1000000;
    }
}

// 每列宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
    return 80;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 32;
}
// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{


    if (pickerView.tag == 1) {
        
        if (component == 0) {
            self.hourTemp = [self.hourArray objectAtIndex:(row%[self.hourArray count])];
        }else
        {
            self.minuteTemp = [self.minuteArray objectAtIndex:(row%[self.minuteArray count])];
        }
        
    }else
    {
        if (component == 0) {
            self.dayOffsiteTemp = [self.dayOffsiteArray objectAtIndex:(row%[self.dayOffsiteArray count])];
        }else if (component == 1) {
            self.hourTemp = [self.hourArray objectAtIndex:(row%[self.hourArray count])];
        }else
        {
            self.minuteTemp = [self.minuteArray objectAtIndex:(row%[self.minuteArray count])];
        }
    }
    
    NSLog(@"row   :%ld  component:%ld",(long)row,(long)component);


}

#pragma mark - 保存图片至沙盒 和 系统相册
- (void) saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    [MobClick event:@"photo"];
    
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.1);
    
    NSURL *storeURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.sheepcao.DaysInLine"];
    NSString *destPath = [storeURL path];
    
    
    // 获取沙盒目录
    NSString *fullPath = [destPath
                          stringByAppendingPathComponent:imageName];
    
    NSLog(@"image path___:%@",fullPath);
    
    // 将图片写入文件
    [imageData writeToFile:fullPath atomically:NO];

}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage *photo = info[UIImagePickerControllerOriginalImage];

    [self.photosArray insertObject:photo atIndex:self.photosArray.count - 1];
    [self .photoTable reloadData];
    
    NSString *UUID = [[NSUUID UUID] UUIDString];
    NSString *name = [NSString stringWithFormat:@"%@.png", UUID];
    
    [self saveImage:photo withName: name];
    
    if ([self.photoNames isEqualToString:@""] || self.photoNames == nil) {
        self.photoNames = name;
    } else {
        self.photoNames = [NSString stringWithFormat:@"%@;%@", self.photoNames, name];
    }
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.photoTable) {
        if (indexPath.row == self.photosArray.count - 1) {
            UIImagePickerController *pickVC = [[UIImagePickerController alloc] init];
            //设置照片来源
            pickVC.sourceType =  UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            pickVC.delegate = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self presentViewController:pickVC animated:YES completion:nil];

            });
        }else
        {
            // zoom big the image...

            [self showingModelOfHeight:SCREEN_HEIGHT - topBarHeight  andColor:[UIColor colorWithRed:0.18f green:0.18f blue:0.18f alpha:0.0f] forRow:6];
            
            UIImage *image = self.photosArray[indexPath.row];
            CGRect aframe = self.bigPhoto.frame;
            aframe.size.height = (image.size.height/image.size.width) *aframe.size.width;
            [self.bigPhoto setFrame:aframe];
            [self.bigPhoto setImage:self.photosArray[indexPath.row]];
            

        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.photoTable) {
        return tableView.frame.size.height;
    }else if (tableView == self.categoryTableView)
    {
         return ((int)(SCREEN_WIDTH/8));
    }else{
        if (IS_IPHONE_4_OR_LESS) {
            return 50;
        }else
        {
            return 60;
        }

    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.photoTable) {
        return self.photosArray.count;
    }else if (tableView == self.categoryTableView)
    {
        if (self.moneyTypeSeg.selectedSegmentIndex == 0) {
            return (self.workCategoryArray.count/4) + 1;
        }else
        {
            return (self.lifeCategoryArray.count/4) + 1;
        }

    }else
    return 5;
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
    }else if (tableView == self.categoryTableView)
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
    NSString *CellIdentifier = @"itemInfoCell";
    itemDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[itemDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        
    }
    [cell.leftText setTextColor:self.myTextColor];
    [cell.rightText setTitleColor:self.myTextColor forState:UIControlStateNormal];
    cell.padDelegate = self;
    cell.rightText.tag = indexPath.row + 10;
    
    switch (indexPath.row) {
        case 0:
            [cell.leftText  setText:NSLocalizedString(@" 主 题",nil)] ;
            if(self.category)
            {
                NSString *type = self.itemType?NSLocalizedString(@"生活",nil):NSLocalizedString(@"工作",nil);
                NSString *theme = [NSString stringWithFormat:@"%@ > %@",type,self.category];
                [cell.rightText setTitle:theme forState:UIControlStateNormal];
                if (self.relatedGoalID) {
                    [cell.rightText setEnabled:NO];
                }else
                {
                    [cell.rightText setEnabled:YES];
                    [cell addExpend];

                }
                
            }else
            {
                [cell addExpend];
                [cell.rightText setTitle:NSLocalizedString(@"请选择",nil) forState:UIControlStateNormal];
                [cell.rightText setTitleColor:[self.myTextColor colorWithAlphaComponent:0.9f] forState:UIControlStateNormal];
            }
            break;
        case 1:
            [cell.leftText setText: NSLocalizedString(@"开始时间",nil)];
            [cell addExpend];

            if(self.itemStartTime)
            {
                [cell.rightText setTitle:self.itemStartTime forState:UIControlStateNormal];
                
            }else
            {
                [cell.rightText setTitle:NSLocalizedString(@"请选择",nil) forState:UIControlStateNormal];
                [cell.rightText setTitleColor:[self.myTextColor colorWithAlphaComponent:0.9f] forState:UIControlStateNormal];
            }
            break;
        case 2:
            [cell.leftText  setText: NSLocalizedString(@"结束时间",nil)];
            [cell addExpend];

            if(self.itemEndTime)
            {
                [cell.rightText setTitle:self.itemEndTime forState:UIControlStateNormal];
                
            }else
            {
                [cell.rightText setTitle:NSLocalizedString(@"请选择",nil)forState:UIControlStateNormal];
                [cell.rightText setTitleColor:[self.myTextColor colorWithAlphaComponent:0.9f] forState:UIControlStateNormal];
            }
            break;
        case 3:
            [cell.leftText  setText:NSLocalizedString(@"文字备注",nil)] ;
            if(self.itemDescription && ![self.itemDescription isEqualToString:@""])
            {
                [cell.rightText setTitle:self.itemDescription forState:UIControlStateNormal];
                [self.noteBody setText:self.itemDescription];
                
            }else
            {
                [cell.rightText setTitle:NSLocalizedString(@"请输入",nil) forState:UIControlStateNormal];
                [cell.rightText setTitleColor:[self.myTextColor colorWithAlphaComponent:0.9f] forState:UIControlStateNormal] ;
            }
            break;
            
        case 4:
            [cell.leftText  setText:NSLocalizedString(@"语音备注",nil)] ;
            if( [[AVAudioPlayer alloc] initWithContentsOfURL:self.recorder.url error:nil])
            {
                [cell.rightText setTitle:NSLocalizedString(@"播放(长按重录)",nil) forState:UIControlStateNormal];
                UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(sendVoiceButtonLongPress:)];
                //设置长按时间
                longPress.minimumPressDuration = 1.25;
                [cell.rightText addGestureRecognizer:longPress];
                
            }else
            {
                [cell.rightText setTitle:NSLocalizedString(@"按住 录音",nil) forState:UIControlStateNormal];
                UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(sendVoiceButtonLongPress:)];
                //设置长按时间
                longPress.minimumPressDuration = 0.5;
                [cell.rightText addGestureRecognizer:longPress];
            }
            [cell.rightText setTitleColor:[self.myTextColor colorWithAlphaComponent:0.9f] forState:UIControlStateNormal];

            break;
            
            
        default:
            break;
    }
    return cell;
}

-(void)sendVoiceButtonLongPress:(UILongPressGestureRecognizer *)recognizer
{
    

    
    if (self.avPlay.playing) {
        [self.avPlay stop];
        return;
    }

    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        
        
        self.voiceImageview = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-60, 150, 120, 120)];
        [self.view addSubview:self.voiceImageview];
        
        if ([self.recorder prepareToRecord]) {
            //开始录音
            [self.recorder record];
            [MobClick event:@"record"];
        }
        //定时检测
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(detectionVice) userInfo:nil repeats:YES];
        
    }
    else
    {
        if (recognizer.state == UIGestureRecognizerStateCancelled
            || recognizer.state == UIGestureRecognizerStateFailed
            || recognizer.state == UIGestureRecognizerStateEnded)
        {
            if (self.voiceImageview) {
                [self.voiceImageview removeFromSuperview];
            }
            
            double cTime = self.recorder.currentTime;
            if (cTime > 1.5) {
                NSLog(@"录音成功");
                [self.recorder stop];//录音结束


            }else{
                //删除记录的文件
                [self.recorder stop];//录音结束

                if (isNewRecord) {
                    [self.recorder deleteRecording];
                }
            }
            [self.timer invalidate];//取消定时器
            
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4 inSection:0];
            [indexPaths addObject: indexPath];
            [self.itemInfoTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];

        }
    }
    
    }


- (void)detectionVice
{
    [self.recorder updateMeters];
    double lowPassResults = pow(10, (0.5 * [self.recorder peakPowerForChannel:0]));
    //图片随音量大小变化
    if (0<lowPassResults<=0.08) {
        [self.voiceImageview setImage:[UIImage imageNamed:@"mic1.png"]];
    }else if (0.08<lowPassResults<=0.16) {
        [self.voiceImageview setImage:[UIImage imageNamed:@"mic1.png"]];
    }else if (0.16<lowPassResults<=0.24) {
        [self.voiceImageview setImage:[UIImage imageNamed:@"mic2.png"]];
    }else if (0.24<lowPassResults<=0.32) {
        [self.voiceImageview setImage:[UIImage imageNamed:@"mic2.png"]];
    }else if (0.32<lowPassResults<=0.40) {
        [self.voiceImageview setImage:[UIImage imageNamed:@"mic3.png"]];
    }else if (0.40<lowPassResults<=0.48) {
        [self.voiceImageview setImage:[UIImage imageNamed:@"mic3.png"]];
    }else if (0.48<lowPassResults<=0.56) {
        [self.voiceImageview setImage:[UIImage imageNamed:@"mic4.png"]];
    }else if (0.56<lowPassResults<=0.64) {
        [self.voiceImageview setImage:[UIImage imageNamed:@"mic4.png"]];
    }else if (0.64<lowPassResults<=0.72) {
        [self.voiceImageview setImage:[UIImage imageNamed:@"mic5.png"]];
    }else if (0.72<lowPassResults<=0.80) {
        [self.voiceImageview setImage:[UIImage imageNamed:@"mic5.png"]];
    }else if (0.80<lowPassResults<=0.88) {
        [self.voiceImageview setImage:[UIImage imageNamed:@"mic6.png"]];
    }else{
        [self.voiceImageview setImage:[UIImage imageNamed:@"mic6.png"]];
    }
    
}

#pragma category cell delegate

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
    self.itemType =(int)self.moneyTypeSeg.selectedSegmentIndex;

    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [indexPaths addObject: indexPath];
    [self.itemInfoTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];

    [self dismissDimView];
    
}


#pragma mark cell delegate for show pad
-(void)showPad:(UIButton *)sender
{
    if (sender.tag - 10 == 0) {
        [self showingModelOfHeight:300 andColor:[UIColor colorWithRed:0.18f green:0.18f blue:0.18f alpha:1.0f] forRow:0];
    }else if (sender.tag - 10 == 1 || sender.tag - 10 == 2)
    {
        [self showingModelOfHeight:200 andColor:[UIColor colorWithRed:0.88f green:0.88f blue:0.88f alpha:1.0f] forRow:(sender.tag - 10)];
    }else if (sender.tag -10 == 3)
    {
        [self showingModelOfHeight:SCREEN_HEIGHT andColor:[UIColor colorWithRed:0.18f green:0.18f blue:0.18f alpha:0.0f] forRow:3];

        [self.view bringSubviewToFront:self.noteView];
        [self.noteBody becomeFirstResponder];
    }else if (sender.tag - 10 == 4)
    {
        if (self.avPlay.playing) {
            [self.avPlay stop];
            return;
        }
        //初始化AVAudioPlayer 对象
        AVAudioPlayer * player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recorder.url error:nil];
        self.avPlay = player;
        [self.avPlay play];
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


-(void)closeVC
{
    if (isNewRecord && [[NSFileManager defaultManager] fileExistsAtPath:self.recorder.url.path]) {
        if (![self.recorder deleteRecording])
            NSLog(@"Failed to delete %@", self.recorder.url);
    }
    if (![self isBeingDismissed]) {
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }
}


#pragma mark alert delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==1) {
        NSUInteger index =  [self.photosArray indexOfObject:self.bigPhoto.image];
        [self.photosArray removeObject:self.bigPhoto.image];
        [self.photoTable reloadData];
        
        NSArray *names = [self.photoNames componentsSeparatedByString:@";"];
        self.photoNames = @"";
        for (int i = 0; i<names.count; i++) {
            if (i == index) {
                continue;
            }else
            {
                if ([self.photoNames isEqualToString:@""]) {
                    self.photoNames = names[i];
                }else
                {
                    self.photoNames = [self.photoNames stringByAppendingString:[NSString stringWithFormat:@";%@",names[i]]];
                }
            }
        }
        
        [self dismissDimView];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}
@end
