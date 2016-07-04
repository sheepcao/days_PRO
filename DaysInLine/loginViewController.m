//
//  loginViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 5/9/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "loginViewController.h"
#import "global.h"
#import "gradientButton.h"
#import "CommonUtility.h"
#import "MBProgressHUD.h"
#import "registerViewController.h"
#import "backupViewController.h"
#import "forgotPasswordViewController.h"


@interface loginViewController ()<UITextFieldDelegate>
@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) UITextField *userField;
@property (nonatomic,strong) UITextField *pswdField;
@property (nonatomic,strong) gradientButton *myLoginBtn;

@end

@implementation loginViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    

    
    [self configInputArea];
    UIButton * closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 32, 42, 42)];
    closeViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    closeViewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [closeViewButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    closeViewButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
//    [closeViewButton setTitle:@"返回" forState:UIControlStateNormal];
    [closeViewButton setTitleColor:   normalColor forState:UIControlStateNormal];
    [closeViewButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    closeViewButton.backgroundColor = [UIColor clearColor];
    [self.view addSubview:closeViewButton];
}
-(void)closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[CommonUtility sharedCommonUtility] shimmerRegisterButton:self.myLoginBtn];
    [MobClick beginLogPageView:@"login"];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"login"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)configInputArea
{
    CGFloat space =20;
    if (IS_IPHONE_4_OR_LESS)
    {
        space = 10;
    }
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_HEIGHT)];
    content.backgroundColor = [UIColor clearColor];
    [self.view addSubview:content];
    
//    UIImageView *logoView =[[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/3, SCREEN_HEIGHT/5.5, SCREEN_WIDTH/3, SCREEN_WIDTH/3)];
//    [logoView setImage:[UIImage imageNamed: @"logo.png"]];
//    [content addSubview:logoView];
//    self.contentView = content;
    
//    UILabel *logoView =[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/6, SCREEN_HEIGHT/6.6, SCREEN_WIDTH*2/3, SCREEN_WIDTH/6)];
//    [logoView setText:NSLocalizedString(@"Days In Line",nil)];
//    logoView.font =  [UIFont fontWithName:@"HelveticaNeue-Light" size:48.5f];
//    if (logoView.text.length>6) {
//        logoView.font =  [UIFont fontWithName:@"HelveticaNeue" size:32.5f];
//    }
//    [logoView setTextColor:normalColor];
//    logoView.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
//    logoView.shadowOffset =  CGSizeMake(0.66, 1.66);
//    
//    logoView.textAlignment = NSTextAlignmentCenter;
//    
//    logoView.layer.cornerRadius = logoView.frame.size.width/6.4;
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/3, topBarHeight+ 10, SCREEN_WIDTH/3, SCREEN_WIDTH/3)];
    [logoView setImage:[UIImage imageNamed:@"logo.png"]];
    [content addSubview:logoView];
    self.contentView = content;
    
    UITextField *usernameField = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8, logoView.frame.origin.y + logoView.frame.size.height + 30, SCREEN_WIDTH*3/4, SCREEN_WIDTH/8)];
    usernameField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:NSLocalizedString(@"邮箱",nil)
                                    attributes:@{
                                                 NSForegroundColorAttributeName: [UIColor colorWithRed:0.41 green:0.41 blue:0.41 alpha:0.9],
                                                 NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:SCREEN_WIDTH/19]
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

    NSString *defaultUser = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULT_USER];
    if (defaultUser) {
        [usernameField setText:defaultUser];
    }
    
    UITextField *passwordField = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8, usernameField.frame.origin.y + usernameField.frame.size.height + space, SCREEN_WIDTH*3/4, SCREEN_WIDTH/8)];
    passwordField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:NSLocalizedString(@"密码",nil)
                                    attributes:@{
                                                 NSForegroundColorAttributeName: [UIColor colorWithRed:0.41 green:0.41 blue:0.41 alpha:0.9],
                                                 NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:SCREEN_WIDTH/20]
                                                 }
     ];
    passwordField.textAlignment = NSTextAlignmentCenter;
    passwordField.returnKeyType = UIReturnKeyDefault;
    passwordField.delegate = self;
    passwordField.tintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.9];
    passwordField.font =  [UIFont fontWithName:@"HelveticaNeue-Light" size:SCREEN_WIDTH/21];
    passwordField.textColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.9];
    [passwordField.layer setCornerRadius:passwordField.frame.size.height/2];
    [passwordField setBackgroundColor:[UIColor whiteColor]];
    [passwordField.layer setBorderColor:[UIColor grayColor].CGColor];
    [passwordField.layer setBorderWidth:0.4];
    [content addSubview:passwordField];
    passwordField.secureTextEntry = YES;
    self.pswdField = passwordField;
    
     gradientButton *loginButton = [[gradientButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8, passwordField.frame.origin.y + passwordField.frame.size.height + space+5, SCREEN_WIDTH*3/4, SCREEN_WIDTH/7.5)];
    loginButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Light" size:23.0f];
    [loginButton setTitle:NSLocalizedString(@"登  录",nil) forState:UIControlStateNormal];
    [content addSubview:loginButton];
    self.myLoginBtn = loginButton;
    [loginButton addTarget:self action:@selector(userLogin) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 65, loginButton.frame.origin.y + loginButton.frame.size.height + space+5, 130, 30)];
    [registerButton setBackgroundColor:[UIColor clearColor]];
    [registerButton setTitle:NSLocalizedString(@"创建新的用户",nil) forState:UIControlStateNormal];
    registerButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Light" size:15.5f];
    [registerButton setTitleColor:self.myTextColor forState:UIControlStateNormal];
    [registerButton addTarget:self action:@selector(goRegister) forControlEvents:UIControlEventTouchUpInside];
    [content addSubview:registerButton];
    
    UIView *leftGradient = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/14, registerButton.frame.origin.y + registerButton.frame.size.height/2-1, SCREEN_WIDTH/2 - SCREEN_WIDTH/14 - registerButton.frame.size.width/2, 2)];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = leftGradient.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0.96 alpha:0.0f].CGColor, (id)[UIColor colorWithWhite:0.96 alpha:1.0f].CGColor, nil];
    gradientLayer.startPoint = CGPointMake(0.0f, 0.5f);
    gradientLayer.endPoint = CGPointMake(1.0f, 0.5f);
    gradientLayer.cornerRadius = leftGradient.frame.size.height/2;
    leftGradient.layer.mask = gradientLayer;
    [leftGradient.layer insertSublayer:gradientLayer atIndex:0];
    
    UIView *rightGradient = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 + registerButton.frame.size.width/2, registerButton.frame.origin.y + registerButton.frame.size.height/2-1, leftGradient.frame.size.width, 2)];
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
    
    NSString *forgotText = NSLocalizedString(@"忘记密码?",nil);
    NSDictionary *attrDict = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0f],
                                                        NSForegroundColorAttributeName : self.myTextColor};
    NSMutableAttributedString *title =[[NSMutableAttributedString alloc] initWithString:forgotText attributes: attrDict];
    
    [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0,[forgotText length])];
    UIButton *forgotButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 150, SCREEN_HEIGHT-60, 140, 30)];
    if (IS_IPHONE_4_OR_LESS)
    {
        [forgotButton setFrame:CGRectMake(SCREEN_WIDTH - 120, SCREEN_HEIGHT-35, 100, 20)];
    }
    [forgotButton setBackgroundColor:[UIColor clearColor]];
    [forgotButton setAttributedTitle:title forState:UIControlStateNormal];
    [content addSubview:forgotButton];
    [forgotButton addTarget:self action:@selector(goFindPassword) forControlEvents:UIControlEventTouchUpInside];
    
}
-(void)goFindPassword
{
    forgotPasswordViewController *forgotVC = [[forgotPasswordViewController alloc] initWithNibName:@"forgotPasswordViewController" bundle:nil];
    [self.navigationController pushViewController:forgotVC animated:YES];
}

-(void)keyboardWasShown:(NSNotification*)notification
{
    if ([[UIApplication sharedApplication] applicationState] !=UIApplicationStateActive) {
        return;
    }
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.contentView setFrame:CGRectMake(0,0 - (keyboardSize.height-(SCREEN_HEIGHT - self.myLoginBtn.frame.origin.y - self.myLoginBtn.frame.size.height-5)) , self.contentView.frame.size.width, self.contentView.frame.size.height)];
    }];
    
}
-(void)dismissKeyboard {
    if ([self.userField isFirstResponder]) {
        [self textFieldShouldReturn:self.userField];
    }else if([self.pswdField isFirstResponder])
    {
        [self textFieldShouldReturn:self.pswdField];
    }
}

#pragma mark UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIView animateWithDuration:0.25f animations:^{
        [self.contentView setFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    }];
    [textField resignFirstResponder];

    [self validateInfo];

    return NO;
}

-(BOOL)validateInfo
{
    BOOL isValidEmail = [[CommonUtility sharedCommonUtility] validateEmail:self.userField.text];
    if (!isValidEmail) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.animationType = MBProgressHUDAnimationZoom;
        hud.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"请输入正确的邮箱格式",nil);
        [hud hide:YES afterDelay:2.0];
        [self.userField becomeFirstResponder];
        return  NO;
    }
    
    BOOL isValidPswd = [[CommonUtility sharedCommonUtility] validatePassword:self.pswdField.text];
    if (!isValidPswd) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.animationType = MBProgressHUDAnimationZoom;
        hud.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"密码格式不正确",nil);
        hud.detailsLabelText = NSLocalizedString(@"密码长度6-20位并由大小写字母和数字组成",nil);
        [hud hide:YES afterDelay:2.0];
        [self.pswdField becomeFirstResponder];
        return NO;
    }
    
    return YES;
}

-(void)userLogin
{

    
    if ([[self.userField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""] ) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.animationType = MBProgressHUDAnimationZoom;
        hud.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"请输入您的邮箱",nil);
        [hud hide:YES afterDelay:1.5];
        [self.userField becomeFirstResponder];
        return;
    }
    
    if ([[self.pswdField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""] ) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.animationType = MBProgressHUDAnimationZoom;
        hud.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"请输入密码",nil);
        [hud hide:YES afterDelay:1.5];
        [self.userField becomeFirstResponder];
        return;
    }
    
    if (![self validateInfo]) {
        return;
    }

    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    hud.dimBackground = YES;
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];


    NSDictionary *parameters = @{@"tag": @"login",@"name":self.userField.text,@"password":self.pswdField.text};
    [[CommonUtility sharedCommonUtility] httpGetUrlNoToken:backupURL params:parameters success:^(NSDictionary *success){
//
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"登录成功",nil);
        [hud hide:YES afterDelay:2.0];

        NSString *name = [success objectForKey:@"username"];
        NSString *backupDevice = [success objectForKey:@"backup_device"];
        NSString *backupDay = [success objectForKey:@"backup_day"];
        
        backupViewController *backupVC = [[backupViewController alloc] initWithNibName:@"backupViewController" bundle:nil];
        backupVC.username = name;
        backupVC.backupDevice = backupDevice;
        backupVC.backupDay = backupDay;
        
        [[NSUserDefaults standardUserDefaults] setObject:name forKey:DEFAULT_USER];

        NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
        if ([viewControllers.lastObject isKindOfClass:[loginViewController class]]) {
            [viewControllers removeObject:viewControllers.lastObject];
        }
        [viewControllers addObject:backupVC];
        [self.navigationController setViewControllers:viewControllers animated:YES];
        
        NSLog(@"%@",success);

    } failure:^(NSError * failure){
        NSLog(@"%ld--------%@",(long)failure.code,failure.localizedDescription);
        if([CommonUtility myContainsStringFrom:failure.localizedDescription forSubstring:@"417"] )
        {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = NSLocalizedString(@"邮箱地址或密码错误",nil);
            [hud hide:YES afterDelay:1.5];
        }else
        {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = NSLocalizedString(@"提交失败，请检查您的网络并重试",nil);
            [hud hide:YES afterDelay:1.5];
        }

    }];

}

-(void)goRegister
{
    registerViewController *registVC = [[registerViewController alloc] initWithNibName:@"registerViewController" bundle:nil];
    [self.navigationController pushViewController:registVC animated:YES];
}

-(void)dealloc
{
    NSLog(@"login dealloc!!!");


}


@end
