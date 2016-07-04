//
//  categoryManagementViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 5/1/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "categoryManagementViewController.h"
#import "topBarView.h"
#import "global.h"
#import "BottomView.h"
#import "CommonUtility.h"
#import "categoryObject.h"
#import "categoryTableViewCell.h"

@interface categoryManagementViewController ()<UITableViewDataSource,UITableViewDelegate,categoryTapDelegate,UITextFieldDelegate>
{
    CGFloat bottomHeight;
    BOOL willShowDeleteBtn;
}
@property (nonatomic ,strong) UISegmentedControl *moneyTypeSeg;
@property (nonatomic ,strong) UITableView *categoryTableView;
@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) NSMutableArray *workCategoryArray;
@property (nonatomic,strong) NSMutableArray *lifeCategoryArray;
@property (nonatomic,strong) UITextField *inputField;
@property (nonatomic,strong) UIView *inputView;
@property (nonatomic,strong) UIView *mySortView;
@property (nonatomic,strong) UIButton *myDeleteButton;
@property (nonatomic,strong) UIButton *deletingButton;

@end

@implementation categoryManagementViewController
@synthesize db;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    willShowDeleteBtn = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    NSString*sortType = [[NSUserDefaults standardUserDefaults] objectForKey:@"sortType"];
    if (sortType) {
        [self prepareCategoryDataBy:sortType];
    }else
    {
        [self prepareCategoryDataBy:@"category_id"];
    }
    
    [self configBottomView];
    [self configCategoryPad];
    [self configInputField];
//    [self configSortView];
    [self configTopbar];
    
//    [[CommonUtility sharedCommonUtility] addADWithY:bottomHeight InView:self.view OfRootVC:self];

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"categoryManage"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"categoryManage"];
}

-(void)dismissKeyboard {
    [self hideSortView];
    [self textFieldShouldReturn:self.inputField];
}

-(void)prepareCategoryDataBy:(NSString *)key
{
    if(self.lifeCategoryArray)
    {
        [self.lifeCategoryArray removeAllObjects];
    }else
    {
        self.lifeCategoryArray = [[NSMutableArray alloc] init];
        
    }
    if(self.workCategoryArray)
    {
        [self.workCategoryArray removeAllObjects];
    }else
    {
        self.workCategoryArray = [[NSMutableArray alloc] init];
        
    }
    
    
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"addNewItem/Could not open db.");
        return;
    }
    NSString *sqlCommand;
    if ([key isEqualToString:@"category_id"]) {
        sqlCommand = [NSString stringWithFormat:@"select * from CATEGORYINFO where is_deleted = 0 order by category_id"];
        
    }else if([key isEqualToString:@"recently create"])
    {
        sqlCommand = [NSString stringWithFormat:@"select * from CATEGORYINFO where is_deleted = 0 order by category_id desc"];
    }else
    {
        sqlCommand = [NSString stringWithFormat:@"select * from CATEGORYINFO where is_deleted = 0 order by category_id"];
        
    }
    
    FMResultSet *rs = [db executeQuery:sqlCommand];
    while ([rs next]) {
        categoryObject *oneCategory = [[categoryObject alloc] init];
        
        oneCategory.categoryName = [rs stringForColumn:@"category_name"];
        oneCategory.color_R  = [rs doubleForColumn:@"color_R"];
        oneCategory.color_G = [rs doubleForColumn:@"color_G"];
        oneCategory.color_B = [rs doubleForColumn:@"color_B"];
        
        if ([rs intForColumn:@"category_type"] == 0) {
            [self.lifeCategoryArray addObject:oneCategory];
        }else
        {
            [self.workCategoryArray addObject:oneCategory];
        }
    }
    
    
    if ([key isEqualToString:@"usage"])
    {
        FMResultSet *rs = [db executeQuery:@"SELECT count(*),item_category FROM ITEMINFO where item_type = 0 GROUP BY item_category ORDER BY count(*) DESC"];
        int i = 0;
        while ([rs next]) {
            NSString *cateName = [rs stringForColumn:@"item_category"];
            for (categoryObject *oneCate in self.lifeCategoryArray) {
                if ([oneCate.categoryName isEqualToString:cateName]) {
                    categoryObject *oneCateTemp = oneCate;
                    [self.lifeCategoryArray removeObject:oneCate];
                    [self.lifeCategoryArray insertObject:oneCateTemp atIndex:i];
                    i++;
                    break;
                }
                
            }
        }
        
        FMResultSet *rs2 = [db executeQuery:@"SELECT count(*),item_category FROM ITEMINFO where item_type = 1 GROUP BY item_category ORDER BY count(*) DESC"];
        int j = 0;
        while ([rs2 next]) {
            NSString *cateName = [rs2 stringForColumn:@"item_category"];
            for (categoryObject *oneCate in self.workCategoryArray) {
                if ([oneCate.categoryName isEqualToString:cateName]) {
                    categoryObject *oneCateTemp = oneCate;
                    [self.workCategoryArray removeObject:oneCate];
                    [self.workCategoryArray insertObject:oneCateTemp atIndex:j];
                    j++;
                    break;
                }
                
            }
        }
    }
    
    [db close];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configTopbar
{
    topBarView *topbar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topRowHeight)];
    topbar.backgroundColor = [UIColor clearColor];

    [self.view addSubview:topbar];
    
    UIButton * closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 25, 40, 40)];
    closeViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    closeViewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [closeViewButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    closeViewButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
//    [closeViewButton setTitle:@"返回" forState:UIControlStateNormal];
    [closeViewButton setTitleColor:   normalColor forState:UIControlStateNormal];
    [closeViewButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    closeViewButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:closeViewButton];
    
//    UIButton *sortButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-69, 26, 60, 40)];
//    sortButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
//    sortButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//    [sortButton setTitle:NSLocalizedString(@"排序",nil) forState:UIControlStateNormal];
//    [sortButton setTitleColor:   self.myTextColor forState:UIControlStateNormal];
//    [sortButton addTarget:self action:@selector(showSortView) forControlEvents:UIControlEventTouchUpInside];
//    sortButton.backgroundColor = [UIColor clearColor];
//    [topbar addSubview:sortButton];
    
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:NSLocalizedString(@"工作",nil),NSLocalizedString(@"生活",nil),nil];
    self.moneyTypeSeg = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    self.moneyTypeSeg.frame = CGRectMake(SCREEN_WIDTH*2/7, 28, SCREEN_WIDTH*3/7, 30);
    self.moneyTypeSeg.tintColor =  TextColor2;
    self.moneyTypeSeg.selectedSegmentIndex = 0;
    [self.moneyTypeSeg addTarget:self action:@selector(segmentAction:)forControlEvents:UIControlEventValueChanged];  //添加委托方法
    [topbar addSubview:self.moneyTypeSeg];
    
}
-(void)configSortView
{
    UIView *sortView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, topRowHeight, 150, 150)];
    sortView.layer.cornerRadius = 8;
    sortView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.9 alpha:1.0];
    [self.view addSubview:sortView];
    self.mySortView = sortView;
    NSArray *buttonTitle = @[NSLocalizedString(@"系统推荐",nil),NSLocalizedString(@"最新添加",nil),NSLocalizedString(@"使用最多",nil)];
    
    
    for (int i = 0; i<3; i++) {
        UIButton *sortBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0 + i*sortView.frame.size.height/3, sortView.frame.size.width-10, sortView.frame.size.height/3)];
        sortBtn.backgroundColor = [UIColor clearColor];
        [sortBtn setTitle:buttonTitle[i] forState:UIControlStateNormal];
        sortBtn.titleLabel.font =[UIFont fontWithName:@"HelveticaNeue" size:13.0f];
        sortBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 40);
        [sortBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        sortBtn.tag = i+1;
        [sortBtn addTarget:self action:@selector(sortTypeChange:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *selectedImage = [[UIImageView alloc] initWithFrame:CGRectMake(sortBtn.frame.size.width-35, sortBtn.frame.size.height/2 - 12.5 + i*sortView.frame.size.height/3, 25, 25)];
        selectedImage.tag = i+1+10;
        NSArray *sortKeys = @[@"category_id",@"recently create",@"usage"];
        NSString*sortType = [[NSUserDefaults standardUserDefaults] objectForKey:@"sortType"];
        
        
        if  ([sortKeys[i] isEqualToString:sortType])
        {
            [selectedImage setImage:[UIImage imageNamed:@"doneBig"]];
        }else
        {
            [selectedImage setImage:nil];
            
        }
        
        [sortView addSubview:sortBtn];
        [sortView addSubview:selectedImage];
    }
    
}
-(void)sortTypeChange:(UIButton *)sender
{
    NSArray *sortKeys = @[@"category_id",@"recently create",@"usage"];
    
    for (int i = 0; i<3; i++) {
        UIImageView *selected =(UIImageView *) [self.mySortView viewWithTag:(i+1+10)];
        [selected setImage:nil];
    }
    UIImageView *selected =(UIImageView *) [self.mySortView viewWithTag:(sender.tag + 10)];
    [selected setImage:[UIImage imageNamed:@"doneBig.png"]];
    
    [[NSUserDefaults standardUserDefaults] setObject:sortKeys[sender.tag -1] forKey:@"sortType"];
    
    [self prepareCategoryDataBy:sortKeys[sender.tag -1]];
    [self.categoryTableView reloadData];
    [self hideSortView];
    
    
}
-(void)showSortView
{
    [self hideDelete:self.myDeleteButton];
    
    if (self.mySortView.frame.origin.x>SCREEN_WIDTH-1)
    {
        [UIView animateWithDuration:0.31f animations:^{
            [self.mySortView setFrame:CGRectMake(SCREEN_WIDTH - self.mySortView.frame.size.width + 10, topRowHeight, self.mySortView.frame.size.width, self.mySortView.frame.size.height)];
        }];
    }else
    {
        [self hideSortView];
    }
    
}
-(void)hideSortView
{
    [UIView animateWithDuration:0.31f animations:^{
        [self.mySortView setFrame:CGRectMake(SCREEN_WIDTH, topRowHeight, self.mySortView.frame.size.width, self.mySortView.frame.size.height)];
    }];
}

-(void)configBottomView
{
    if (IS_IPHONE_6P) {
        bottomHeight = 65;
    }else
    {
        bottomHeight = bottomBar;
    }
    
    
    BottomView *bottomView = [[BottomView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-bottomHeight, SCREEN_WIDTH, bottomHeight)];
    bottomView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bottomView];
    
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2-1, bottomHeight)];
    self.myDeleteButton = deleteButton;
    [deleteButton setTitle:NSLocalizedString(@"删减",nil) forState:UIControlStateNormal];
    [deleteButton setTitleColor:self.myTextColor forState:UIControlStateNormal];
    deleteButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    deleteButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    UIButton *addNewButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2, bottomHeight)];
    [addNewButton setTitle:NSLocalizedString(@"添加",nil) forState:UIControlStateNormal];
    addNewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    addNewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [addNewButton setTitleColor:self.myTextColor forState:UIControlStateNormal];
    
    [deleteButton addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
    [addNewButton addTarget:self action:@selector(addItem:) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomView addSubview:deleteButton];
    [bottomView addSubview:addNewButton];
    
    UIView *midLine = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 1, 8, 1, bottomHeight-16)];
    midLine.backgroundColor = [UIColor whiteColor];
    [bottomView addSubview:midLine];
    
}


-(void) configCategoryPad
{
    
    
    UITableView *categoryTable = [[UITableView alloc] initWithFrame:CGRectMake(0, topRowHeight +10, SCREEN_WIDTH, SCREEN_HEIGHT - (topRowHeight) - bottomHeight)];
    
    categoryTable.showsVerticalScrollIndicator = YES;
    categoryTable.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    categoryTable.backgroundColor = [UIColor clearColor];
    categoryTable.delegate = self;
    categoryTable.dataSource = self;
    categoryTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    categoryTable.canCancelContentTouches = YES;
    categoryTable.delaysContentTouches = YES;
    self.categoryTableView = categoryTable;
    [self.view addSubview:categoryTable];
}

-(void)configInputField
{
    UIView *inputCategoryView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_WIDTH/6)];
    self.inputView = inputCategoryView;
    inputCategoryView.backgroundColor = [UIColor colorWithRed:173/255.0f  green:181/255.0f blue:190/255.0f alpha:1.0f];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,5, 80, inputCategoryView.frame.size.height-12)];
    [titleLabel setText:NSLocalizedString(@"主 题 :",nil)];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.inputField = [[UITextField alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x + titleLabel.frame.size.width+8 , 6, inputCategoryView.frame.size.width-(titleLabel.frame.origin.x + titleLabel.frame.size.width) - 60, inputCategoryView.frame.size.height-12)];
    self.inputField.returnKeyType = UIReturnKeyDefault;
    self.inputField.delegate = self;
    self.inputField.tintColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.9];
    self.inputField.font =  [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
    self.inputField.textColor = [UIColor colorWithRed:0.1 green:0.12 blue:0.1 alpha:0.98];
    self.inputField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:NSLocalizedString(@"请输入(限5字以内)",nil)
                                    attributes:@{
                                                 NSForegroundColorAttributeName: [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.9],
                                                 NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:13.5f]
                                                 }
     ];
    
    [self.view addSubview:inputCategoryView];
    [inputCategoryView addSubview:titleLabel];
    [inputCategoryView addSubview:self.inputField];
    
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(self.inputView.frame.size.width-60, (self.inputView.frame.size.height -40)/2, 40, 40)];
    [doneButton setImage:[UIImage imageNamed:@"doneBig"] forState:UIControlStateNormal];
    [doneButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
//    [doneButton setTitle:@"OK" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(addNewCategory) forControlEvents:UIControlEventTouchUpInside];
    
    [inputCategoryView addSubview:doneButton];
    
}


#pragma mark table delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ((int)(SCREEN_WIDTH/8));
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.moneyTypeSeg.selectedSegmentIndex == 0) {
        return (self.lifeCategoryArray.count/4) + 1;
    }else
    {
        return (self.workCategoryArray.count/4) + 1;
    }
}
- (categoryTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"categoryCell";
    
    categoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[categoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier andWidth:SCREEN_WIDTH];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.categoryDelegate = self;

    }
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    if (self.moneyTypeSeg.selectedSegmentIndex == 0) {
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
    }else
    {
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
    }
    [cell contentWithCategories:tempArray];
    if (willShowDeleteBtn)
    {
        [cell showDeleteButton];
    }else
    {
        [cell removeDeleteButton];
    }
    
    return cell;
}

-(void)categoryDeleteTap:(UIButton *)sender
{
    NSLog(@"delete..........");
    UIButton *categoryButton;
    UIView *parentView = [sender.superview viewWithTag:(sender.tag - 10)]
    
    ;
    if ([parentView isKindOfClass:[UIButton class]]) {
        categoryButton = (UIButton *)parentView;
    }
    NSLog(@"categoryButton.text:%@",categoryButton.titleLabel.text);
    self.deletingButton = categoryButton;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"永久删除该类别?",nil)  delegate:self cancelButtonTitle:NSLocalizedString(@"不",nil) otherButtonTitles:NSLocalizedString(@"是的",nil) , nil];
    [alert show];

    
}
-(void)categoryTap:(UIButton *)sender
{
    NSLog(@"do nothing....");
}


-(void)closeVC
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        db = [[CommonUtility sharedCommonUtility] db];
        if (![db open]) {
            NSLog(@"mainVC/Could not open db.");
            return;
        }
        
        BOOL sql = [db executeUpdate:@"update CATEGORYINFO set is_deleted = 1 where category_name=? and category_type = ?",self.deletingButton.titleLabel.text,[NSNumber numberWithInteger:self.moneyTypeSeg.selectedSegmentIndex]];
        if (!sql) {
            NSLog(@"ERROR: %d - %@", db.lastErrorCode, db.lastErrorMessage);
        }else
        {
            
            categoryObject *categoryDeleted;
            if (self.moneyTypeSeg.selectedSegmentIndex == 0) {
                for (categoryObject *oneCategory in self.lifeCategoryArray) {
                    if( [oneCategory.categoryName isEqualToString:self.deletingButton.currentTitle])
                    {
                        categoryDeleted = oneCategory;
                        break;
                    }
                }
                [self.lifeCategoryArray removeObject:categoryDeleted];
            }else
            {
                for (categoryObject *oneCategory in self.workCategoryArray) {
                    if( [categoryDeleted.categoryName isEqualToString:self.deletingButton.titleLabel.text])
                    {
                        categoryDeleted = oneCategory;
                        break;
                    }
                }
                [self.workCategoryArray addObject:categoryDeleted];
            }
            [self.categoryTableView reloadData];
        }
        [db close];

    }
}

-(void)deleteItem:(UIButton *)sender
{
    [self hideSortView];
    
    NSLog(@"show delete button");
    if (willShowDeleteBtn) {
        [self hideDelete:sender];
    }else
    {
        
        [self showDelete:sender];
    }
    
}
-(void)showDelete:(UIButton *)sender
{
    [sender setTitle:NSLocalizedString(@"取消",nil) forState:UIControlStateNormal];
    [sender setTitleColor:[UIColor colorWithRed:253/255.0f green:197/255.0f blue:65/255.0f alpha:1.0f] forState:UIControlStateNormal];
    willShowDeleteBtn = YES;
    [self.categoryTableView reloadData];
    
}
-(void)hideDelete:(UIButton *)sender
{
    [sender setTitle:NSLocalizedString(@"删减",nil) forState:UIControlStateNormal];
//    sender.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 130);
//    [sender setImage:[UIImage imageNamed:@"trush"] forState:UIControlStateNormal];
    [sender setTitleColor:self.myTextColor forState:UIControlStateNormal];

    willShowDeleteBtn = NO;
    [self.categoryTableView reloadData];
    
}

-(void)addItem:(UIButton *)sender
{
    NSLog(@"add Item....");
    [self clearScreen];
    
    
    [self.inputField becomeFirstResponder];
    
}
-(void)addNewCategory
{
    [self clearScreen];
    NSString *newCategory = self.inputField.text;

    CGFloat width =  [self.inputField.text sizeWithAttributes:@{NSFontAttributeName:self.inputField.font}].width;
    NSLog(@"%f",width);
//    if (width>  74)
        if (width>  89)

    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.animationType = MBProgressHUDAnimationZoom;
        hud.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"您输入的类名过长",nil);
        [hud hide:YES afterDelay:1.5];
        
        return;
    }else if ([[newCategory stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:NSLocalizedString(@"+ 新分类",nil)] || [[newCategory stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.animationType = MBProgressHUDAnimationZoom;
        hud.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"非法输入",nil);
        [hud hide:YES afterDelay:1.2];
        return;
    }
    
    // to fix.....category OBJ
    //    NSInteger randomColor = arc4random()%255;
    
    
    if (![db open]) {
        NSLog(@"Could not open db.");
        return;
    }
    
    FMResultSet *rs = [db executeQuery:@"select * from CATEGORYINFO where is_deleted = 0 AND category_name = ? AND category_type = ?",[newCategory stringByReplacingOccurrencesOfString:@" " withString:@""],[NSNumber numberWithInteger: self.moneyTypeSeg.selectedSegmentIndex]];
    if ([rs next]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"您输入的类别已经存在",nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        [db close];
        return;
    }
    


    
    FMResultSet *rsColor = [db executeQuery:@"select * from COLORINFO order by used_count LIMIT 1"];
    if ([rsColor next]) {
        int colorID = [rsColor intForColumn:@"color_id"];
        int usedCount = [rsColor doubleForColumn:@"used_count"];

        double colorR = [rsColor doubleForColumn:@"color_R"];
        double colorG = [rsColor doubleForColumn:@"color_G"];
        double colorB = [rsColor doubleForColumn:@"color_B"];
        
        NSNumber * colorRed = [NSNumber numberWithDouble:colorR];
        NSNumber *colorGreen = [NSNumber numberWithDouble:colorG];
        NSNumber *colorBlue = [NSNumber numberWithDouble:colorB];
        
        
        
        BOOL sql = [db executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values (?,?,?,?,?)" ,[newCategory stringByReplacingOccurrencesOfString:@" " withString:@""],[NSNumber numberWithInteger: self.moneyTypeSeg.selectedSegmentIndex],colorRed,colorGreen,colorBlue];
        
        categoryObject *oneCategory = [[categoryObject alloc] init];
        
        oneCategory.categoryName = newCategory;
        oneCategory.color_R  = colorR;
        oneCategory.color_G = colorG;
        oneCategory.color_B = colorB;
        if (!sql) {
            NSLog(@"ERROR: %d - %@", db.lastErrorCode, db.lastErrorMessage);
        }else
        {
             [db executeUpdate:@"update  COLORINFO set used_count = ? where color_id = ?" ,[NSNumber numberWithInt:usedCount+1],[NSNumber numberWithInt:colorID]];
            
            if (self.moneyTypeSeg.selectedSegmentIndex == 0) {
                [self.lifeCategoryArray addObject:oneCategory];
            }else
            {
                [self.workCategoryArray addObject:oneCategory];
            }
            self.inputField.text = @"";
            [UIView animateWithDuration:0.25f animations:^{
                [self.inputView setFrame:CGRectMake(0, SCREEN_HEIGHT, self.inputView.frame.size.width, self.inputView.frame.size.height)];
            }];
            [self.view layoutIfNeeded];
            [self.inputField resignFirstResponder];
            
            [self.categoryTableView reloadData];
            
            [MobClick event:@"addCategory"];
        }
    }
    [db close];
}

-(void)dismissAlertMessage:(UIAlertController *)alert
{
    [alert dismissViewControllerAnimated:YES completion:nil];
}

-(void)keyboardWasShown:(NSNotification*)notification
{
    if ([[UIApplication sharedApplication] applicationState] !=UIApplicationStateActive) {
        return;
    }
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.inputView setFrame:CGRectMake(0,SCREEN_HEIGHT - keyboardSize.height - self.inputView.frame.size.height, self.inputView.frame.size.width, self.inputView.frame.size.height)];
    }];
    
    [self.view layoutIfNeeded];
}

#pragma mark UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIView animateWithDuration:0.25f animations:^{
        [self.inputView setFrame:CGRectMake(0, SCREEN_HEIGHT, self.inputView.frame.size.width, self.inputView.frame.size.height)];
    }];
    [self.view layoutIfNeeded];
    [textField resignFirstResponder];
    return YES;
}


-(void)segmentAction:(UISegmentedControl *)Seg{
    NSInteger Index = Seg.selectedSegmentIndex;
    NSLog(@"Index %ld", (long)Index);
    [self clearScreen];
    [self.categoryTableView reloadData];
    
}

-(void)clearScreen
{
    [self hideDelete:self.myDeleteButton];
    [self hideSortView];
}
@end
