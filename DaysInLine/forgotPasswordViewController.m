//
//  forgotPasswordViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 5/13/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "forgotPasswordViewController.h"
#import "global.h"
#import "topBarView.h"
#import "CommonUtility.h"
#import "gradientButton.h"
#import "MBProgressHUD.h"

@interface forgotPasswordViewController ()<UITextFieldDelegate>
@property (nonatomic,strong) topBarView *topBar;
@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) UITextField *userField;
@end

@implementation forgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    [self configTopbar];
    [self configInputArea];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"forgotPassword"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"forgotPassword"];
}

-(void)configTopbar
{
    self.topBar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topBarHeight)];
    self.topBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.topBar];
    [self.topBar.titleLabel  setText:NSLocalizedString(@"密码找回",nil)];
//    UILabel *titileLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 80, 22, 160, 50)];
//    [titileLabel setText:@"密码找回"];
//    titileLabel.font = [UIFont fontWithName:@"SourceHanSansCN-Normal" size:titleSize];
//    titileLabel.textAlignment = NSTextAlignmentCenter;
//    [titileLabel setTextColor:normalColor];
//    [self.topBar addSubview:titileLabel];
    UIButton *changeButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 32, 40, 40)];
    changeButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    changeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [changeButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    changeButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
//    [changeButton setTitle:@"返回" forState:UIControlStateNormal];
    [changeButton setTitleColor:   normalColor forState:UIControlStateNormal];
    [changeButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    changeButton.backgroundColor = [UIColor clearColor];
    [self.topBar addSubview:changeButton];

}
-(void)closeVC
{
    CATransition* transition = [CATransition animation];
    transition.duration = 0.21;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    transition.type = kCATransitionMoveIn;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [[self navigationController] popViewControllerAnimated:NO];
    
}


-(void)configInputArea
{
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, self.topBar.frame.size.height + 30,self.view.frame.size.width , self.view.frame.size.height)];
    content.backgroundColor = [UIColor clearColor];
    [self.view addSubview:content];
    
//    UIImageView *logoView =[[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/3, SCREEN_HEIGHT/5.5, SCREEN_WIDTH/3, SCREEN_WIDTH/3)];
//    [logoView setImage:[UIImage imageNamed: @"logo.png"]];
//    [content addSubview:logoView];
    self.contentView = content;
    
    
    UITextField *usernameField = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8, 0, SCREEN_WIDTH*3/4, SCREEN_WIDTH/8)];
    usernameField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:NSLocalizedString(@"请输入您的注册邮箱",nil)
                                    attributes:@{
                                                 NSForegroundColorAttributeName: [UIColor colorWithRed:0.41 green:0.41 blue:0.41 alpha:0.9],
                                                 NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:SCREEN_WIDTH/22]
                                                 }
     ];
    usernameField.textAlignment = NSTextAlignmentCenter;
    usernameField.returnKeyType = UIReturnKeyDefault;
    usernameField.delegate = self;
    usernameField.tintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.9];
    usernameField.font =  [UIFont fontWithName:@"HelveticaNeue-Light" size:SCREEN_WIDTH/21];
    usernameField.textColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.9];
    [usernameField.layer setCornerRadius:usernameField.frame.size.height/2];
    [usernameField setBackgroundColor:[UIColor whiteColor]];
    [usernameField.layer setBorderColor:[UIColor grayColor].CGColor];
    [usernameField.layer setBorderWidth:0.4];
    [content addSubview:usernameField];
    self.userField = usernameField;

    
    gradientButton *loginButton = [[gradientButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8, usernameField.frame.origin.y + usernameField.frame.size.height + 30, SCREEN_WIDTH*3/4, SCREEN_WIDTH/7.5)];
    loginButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Light" size:23.0f];
    [loginButton setTitle:NSLocalizedString(@"提  交",nil) forState:UIControlStateNormal];
    [content addSubview:loginButton];
    [loginButton addTarget:self action:@selector(findPassword) forControlEvents:UIControlEventTouchUpInside];
    
    
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 100 , loginButton.frame.origin.y + loginButton.frame.size.height + 12, 200, 25)];
    hintLabel.textAlignment = NSTextAlignmentCenter;
    hintLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Medium" size:11.0f];
    hintLabel.textColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:0.9];
    [hintLabel setText:NSLocalizedString(@"您的密码将会发送到您的注册邮箱",nil)];
    hintLabel.numberOfLines = 2;
    [content addSubview:hintLabel];
    
    UIView *leftGradient = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/12, hintLabel.frame.origin.y + hintLabel.frame.size.height/2-1, SCREEN_WIDTH/2 - SCREEN_WIDTH/12 - hintLabel.frame.size.width/2, 2)];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = leftGradient.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0.96 alpha:0.0f].CGColor, (id)[UIColor colorWithWhite:0.96 alpha:1.0f].CGColor, nil];
    gradientLayer.startPoint = CGPointMake(0.0f, 0.5f);
    gradientLayer.endPoint = CGPointMake(1.0f, 0.5f);
    gradientLayer.cornerRadius = leftGradient.frame.size.height/2;
    leftGradient.layer.mask = gradientLayer;
    [leftGradient.layer insertSublayer:gradientLayer atIndex:0];
    
    UIView *rightGradient = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 + hintLabel.frame.size.width/2, hintLabel.frame.origin.y + hintLabel.frame.size.height/2-1, leftGradient.frame.size.width, 2)];
    CAGradientLayer *gradientLayerR = [CAGradientLayer layer];
    gradientLayerR.frame = rightGradient.bounds;
    gradientLayerR.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0.96 alpha:1.0f].CGColor, (id)[UIColor colorWithWhite:0.96 alpha:0.0f].CGColor, nil];
    gradientLayerR.startPoint = CGPointMake(0.0f, 0.5f);
    gradientLayerR.endPoint = CGPointMake(1.0f, 0.5f);
    gradientLayerR.cornerRadius = rightGradient.frame.size.height/2;
    rightGradient.layer.mask = gradientLayerR;
    [rightGradient.layer insertSublayer:gradientLayerR atIndex:0];
    
    [content addSubview:leftGradient];
    [content addSubview:rightGradient];
    

    
    [[CommonUtility sharedCommonUtility] shimmerRegisterButton:loginButton];
    
}

-(void)findPassword
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.dimBackground = YES;
    NSString *lang;
    if ([CommonUtility isSystemLangChinese])
    {
        lang = @"cn";
    }else
    {
        lang = @"en";
    }
    
    NSDictionary *parameters = @{@"tag": @"sendEmail",@"name":self.userField.text,@"Lang":lang};
    
    
    
    [[CommonUtility sharedCommonUtility] httpGetUrlTEXT:emailService params:parameters success:^(id success){
        //
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"请前往您的邮箱查看您的密码",nil);
        [hud hide:YES afterDelay:3.0];

        NSString *string = [[NSString alloc] initWithData:success encoding:NSUTF8StringEncoding];
        
        
        [self performSelector:@selector(closeVC) withObject:nil afterDelay:3.1];
        
        NSLog(@"string：%@",string);
        
    } failure:^(NSError * failure){
        NSLog(@"failure:%@",failure);
        hud.mode = MBProgressHUDModeText;
        [hud hide:YES afterDelay:2.0];
        
        NSString *error = [NSString stringWithFormat:@"Error: ***** %@", failure];
        if ([CommonUtility myContainsStringFrom:error forSubstring:@"416"]) {
            hud.labelText = NSLocalizedString(@"您输入的注册邮箱不存在，请重新输入",nil);
        }else
        {
            hud.labelText = NSLocalizedString(@"提交失败，请检查您的网络并重试",nil);
        }
    }];

}


#pragma mark UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{

    [textField resignFirstResponder];
    
    BOOL isValidEmail = [[CommonUtility sharedCommonUtility] validateEmail:self.userField.text];
    if (!isValidEmail) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.animationType = MBProgressHUDAnimationZoom;
        hud.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"请输入正确的邮箱格式",nil);
        [hud hide:YES afterDelay:1.5];
        [self.userField becomeFirstResponder];
    }
    
    
    
    return NO;
}


-(void)dismissKeyboard {
    if ([self.userField isFirstResponder]) {
        [self textFieldShouldReturn:self.userField];
   }
}


@end
