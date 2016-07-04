//
//  registerViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 5/11/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "registerViewController.h"
#import "loginViewController.h"
#import "global.h"
#import "gradientButton.h"
#import "CommonUtility.h"
#import "MBProgressHUD.h"
#import "backupViewController.h"
#import "TermUseViewController.h"

@interface registerViewController ()<UITextFieldDelegate>
@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) UITextField *userField;
@property (nonatomic,strong) UITextField *pswdField;
@property (nonatomic,strong) gradientButton *myLoginBtn;

@end

@implementation registerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"register"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"register"];
}
-(void)configInputArea
{
    CGFloat space =20;
    if (IS_IPHONE_4_OR_LESS)
    {
        space = 10;
    }
    
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    content.backgroundColor = [UIColor clearColor];
    [self.view addSubview:content];
    
//    UIImageView *logoView =[[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/3, SCREEN_HEIGHT/5.5, SCREEN_WIDTH/3, SCREEN_WIDTH/3)];
//    [logoView setImage:[UIImage imageNamed: @"logo.png"]];
//    [content addSubview:logoView];
//    self.contentView = content;
    
//    UILabel *logoView =[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/6, SCREEN_HEIGHT/6.6, SCREEN_WIDTH*2/3, SCREEN_WIDTH/6)];
//    [logoView setText:NSLocalizedString(@"Days In Line",nil)];
//    logoView.font =  [UIFont fontWithName:@"HelveticaNeue-Light" size:43.5f];
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
//    [content addSubview:logoView];
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/3, topBarHeight+ 10, SCREEN_WIDTH/3, SCREEN_WIDTH/3)];
    [logoView setImage:[UIImage imageNamed:@"logo.png"]];
    [content addSubview:logoView];
    self.contentView = content;
    
    
    UITextField *usernameField = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8, logoView.frame.origin.y + logoView.frame.size.height + 30, SCREEN_WIDTH*3/4, SCREEN_WIDTH/9)];
    usernameField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:NSLocalizedString(@"邮箱(用户名)",nil)
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
    
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 80 , usernameField.frame.origin.y + usernameField.frame.size.height + 2, 160, 20)];
    hintLabel.textAlignment = NSTextAlignmentCenter;
    hintLabel.font =  [UIFont fontWithName:@"HelveticaNeue" size:11.5f];
    hintLabel.textColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:0.9];
    [hintLabel setText:NSLocalizedString(@"*重要 : 用于登录及密码找回",nil)];
    [content addSubview:hintLabel];
    
    UIView *leftGradient = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/9, hintLabel.frame.origin.y + hintLabel.frame.size.height/2-1, SCREEN_WIDTH/2 - SCREEN_WIDTH/9 - hintLabel.frame.size.width/2, 2)];
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
    


    UITextField *passwordField = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8, usernameField.frame.origin.y + usernameField.frame.size.height + 24, SCREEN_WIDTH*3/4, SCREEN_WIDTH/9)];
    passwordField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:NSLocalizedString(@"设置密码(大小写字母或数字,6-20位)",nil)
                                    attributes:@{
                                                 NSForegroundColorAttributeName: [UIColor colorWithRed:0.41 green:0.41 blue:0.41 alpha:0.9],
                                                 NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:SCREEN_WIDTH/27]
                                                 }
     ];
    passwordField.textAlignment = NSTextAlignmentCenter;
    passwordField.returnKeyType = UIReturnKeyDefault;
    passwordField.delegate = self;
    passwordField.textColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.9];
    [passwordField.layer setCornerRadius:passwordField.frame.size.height/2];
    [passwordField setBackgroundColor:[UIColor whiteColor]];
    [passwordField.layer setBorderColor:[UIColor grayColor].CGColor];
    [passwordField.layer setBorderWidth:0.4];
    [content addSubview:passwordField];
    passwordField.secureTextEntry = YES;
    self.pswdField = passwordField;
    
    gradientButton *loginButton = [[gradientButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8, passwordField.frame.origin.y + passwordField.frame.size.height + space+5, SCREEN_WIDTH*3/4, SCREEN_WIDTH/8.5)];
    loginButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Light" size:23.0f];
    [loginButton setTitle:NSLocalizedString(@"注  册",nil) forState:UIControlStateNormal];
    [content addSubview:loginButton];
    [loginButton addTarget:self action:@selector(userRegister) forControlEvents:UIControlEventTouchUpInside];
    self.myLoginBtn = loginButton;
    
    UIButton *termsLabel = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 100 , SCREEN_HEIGHT - 40, 200, 20)];
    termsLabel.titleLabel.textAlignment = NSTextAlignmentCenter;
    termsLabel.titleLabel.numberOfLines = 2;
    termsLabel.titleLabel.font =  [UIFont fontWithName:@"Avenir-Medium" size:11.0f];
    termsLabel.titleLabel.textColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:0.88];
    [termsLabel setTitle:NSLocalizedString(@"点击提交，您将同意并遵守历历在目的用户使用协议。点击阅读 >",nil) forState:UIControlStateNormal];
    [termsLabel addTarget: self action:@selector(userTerms) forControlEvents:UIControlEventTouchUpInside];
    [content addSubview:termsLabel];
    
    [[CommonUtility sharedCommonUtility] shimmerRegisterButton:loginButton];
    
}

-(void)userTerms
{
    TermUseViewController *termsVC = [[TermUseViewController alloc] initWithNibName:@"TermUseViewController" bundle:nil];
    [self.navigationController pushViewController:termsVC animated:YES];
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

-(void)userRegister
{
    if (![self validateInfo]) {
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.dimBackground = YES;

    NSDictionary *parameters = @{@"tag": @"register",@"name":self.userField.text,@"password":self.pswdField.text};
    
    [[CommonUtility sharedCommonUtility] httpGetUrlNoToken:backupURL params:parameters success:^(NSDictionary *success){
        //
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"注册成功",nil);
        [hud hide:YES afterDelay:2.0];

        NSString *name = [success objectForKey:@"username"];
        
        [[NSUserDefaults standardUserDefaults] setObject:name forKey:DEFAULT_USER];
        
        [self performSelector:@selector(goBackupFor:) withObject:name afterDelay:0.21];

        NSLog(@"%@",success);
        
    } failure:^(NSError * failure){
        NSLog(@"%@",failure);
        hud.mode = MBProgressHUDModeText;
        [hud hide:YES afterDelay:2.0];
        
        NSString *error = [NSString stringWithFormat:@"Error: ***** %@", failure];
        if ([CommonUtility myContainsStringFrom:error forSubstring:@"416"]) {
            hud.labelText = NSLocalizedString(@"您输入的注册邮箱已存在，换一个吧",nil);
        }else
        {
            hud.labelText = NSLocalizedString(@"注册失败，请重试",nil);
        }
    }];
}

-(void)goBackupFor:(NSString *)name
{
    backupViewController *backupVC = [[backupViewController alloc] initWithNibName:@"backupViewController" bundle:nil];
    backupVC.username = name;
    
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    if ([viewControllers.lastObject isKindOfClass:[registerViewController class]]) {
        [viewControllers removeObject:viewControllers.lastObject];
    }
    if ([viewControllers.lastObject isKindOfClass:[loginViewController class]]) {
        [viewControllers removeObject:viewControllers.lastObject];
    }
    [viewControllers addObject:backupVC];
    [self.navigationController setViewControllers:viewControllers animated:YES];
    
}
@end
