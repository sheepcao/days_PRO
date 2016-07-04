//
//  TermUseViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 5/13/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "TermUseViewController.h"
#import "global.h"
#import "topBarView.h"
#import "CommonUtility.h"

@interface TermUseViewController ()
@property (nonatomic,strong) topBarView *topBar;
@end

@implementation TermUseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configTopbar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"userTerm"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"userTerm"];
}

-(void)configTopbar
{
    self.topBar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topBarHeight)];
    self.topBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.topBar];
    [self.topBar.titleLabel setText:@"用户使用协议"];
//    UILabel *titileLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 80, 22, 160, 50)];
//    [titileLabel setText:@"用户使用协议"];
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
    UITextView *body = [[UITextView alloc] initWithFrame:CGRectMake(10, self.topBar.frame.size.height+10, SCREEN_WIDTH- 24, SCREEN_HEIGHT - self.topBar.frame.size.height - 18)];
    body.backgroundColor = [UIColor clearColor];
    
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
    @{UIFontDescriptorFamilyAttribute: @"Avenir",
 UIFontDescriptorNameAttribute:@"Avenir-Medium",
 UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: 13.5f]
 }];
    NSMutableAttributedString* attrString;
    if ([CommonUtility isSystemLangChinese]) {
   attrString = [[NSMutableAttributedString alloc] initWithString:[self CNbody]];
    }else
    {
   attrString = [[NSMutableAttributedString alloc] initWithString:[self ENbody]];
    }
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:attributeFontDescriptor.pointSize *0.43];
    [attrString addAttribute:NSParagraphStyleAttributeName
   value:style
   range:NSMakeRange(0, attrString.length)];
    [attrString addAttribute:NSForegroundColorAttributeName
   value:self.myTextColor
   range:NSMakeRange(0, attrString.length)];
    body.attributedText = attrString;
    body.indicatorStyle = UIScrollViewIndicatorStyleWhite;


    [self.view addSubview:body];
    
}

-(NSString *)CNbody
{
    return @"\n\tsheepcao工作室敬请用户认真阅读、充分理解本《服务协议》（下称《协议》）--- 用户应认真阅读、充分理解本《协议》中各条款，包括免除或者限制sheepcao工作室责任的免责条款及对用户的权利限制条款。请您审慎阅读并选择接受或不接受本《协议》（未成年人应在法定监护人陪同下阅读）。除非您接受本《协议》所有条款，否则您无权登录。您的注册、登录行为将视为对本《协议》的接受，并同意接受本《协议》各项条款的约束。本《协议》是您（下称“用户”）与sheepcao工作室之间关于使用“DaysInLine”服务所订立的协议。本《协议》描述sheepcao工作室与用户之间关于“DaysInLine”服务相关方面的权利义务。“用户”是指使用、浏览本服务的个人或组织。 本《协议》可由sheepcao工作室随时更新，更新后的协议条款一旦公布即代替原来的协议条款，恕不再另行通知。在sheepcao工作室修改《协议》条款后，如果用户不接受修改后的条款，请立即停止使用DaysInLineapp的服务，用户继续使用DaysInLineapp提供的服务将被视为已接受了修改后的协议。\n\n使用规则:\n1、用户充分了解并同意，DaysInLine仅为用户提供数据备份和同步，用户必须为自己帐号下的一切行为负责，包括您所传送的任何内容以及由此产生的任何结果。sheepcao工作室无法且不会对因用户行为而导致的任何损失或损害承担责任。\n2、用户须对在DaysInLine上的账号信息的真实性、合法性、有效性承担全部责任，用户不得冒充他人；不得利用他人的名义传播任何信息；不得恶意使用帐号导致其他用户误认；否则sheepcao工作室有权立即停止提供服务，收回DaysInLine帐号并由用户独自承担由此而产生的一切法律责任。\n3、用户须对在DaysInLine上所传送信息的真实性、合法性、无害性、有效性等全权负责，与用户所传播的信息相关的任何法律责任由用户自行承担，与sheepcao工作室无关。\n4、sheepcao工作室保留因业务发展需要，单方面对本服务的全部或部分服务内容在任何时候不经任何通知的情况下变更、暂停、限制、终止或撤销DaysInLine服务的权利，用户需承担此风险。\n5、DaysInLine提供的服务中可能包括广告，用户同意在使用过程中显示DaysInLine和第三方供应商、合作伙伴提供的广告。\n6、sheepcao工作室可依其合理判断，对违反有关法律法规或本协议约定；或侵犯、妨害、威胁任何人权利或安全的内容，或通过非正规的技术手段，多次反复注册DaysInLine账号的操作，或者假冒他人的行为，sheepcao工作室有权依法停止传输任何前述内容，并有权依其自行判断对违反本条款的任何人士采取适当的法律行动，包括但不限于，从DaysInLine服务中删除具有违法性、侵权性、不当性等内容，封禁用户所使用设备，终止违反者的成员资格，阻止其使用DaysInLine全部或部分服务，并且依据法律法规保存有关信息并向有关部门报告等。\n7、用户权利及义务：\n\n(1) DaysInLine帐号的所有权归sheepcao工作室，用户完成安装后，获得DaysInLine帐号的使用权，该使用权仅属于手机拥有人，禁止赠与、借用、租用、转让或售卖。sheepcao工作室因经营需要，有权回收用户的DaysInLine帐号。\n\n(2) 用户有权更改、删除在DaysInLine上的个人资料、信息及传送内容等，但需注意，删除有关信息的同时也会删除任何您储存在系统中的备份。用户需承担该风险。\n\n(3) 用户有责任妥善保管帐号信息的安全，用户需要对帐号下的行为承担法律责任。用户同意在任何情况下不使用其他成员的帐号。在您怀疑他人在使用您的帐号时，您同意立即通知sheepcao工作室。\n\n(4) 用户应遵守本协议的各项条款，正确、适当地使用本服务，如因用户违反本协议中的任何条款，sheepcao工作室有权依据协议终止对违约用户DaysInLine帐号提供服务。同时，sheepcao工作室保留在任何时候收回DaysInLine帐号、用户名的权利。\n\n(5) 用户拥有DaysInLine帐号后如果长期不使用该帐号，sheepcao工作室有权回收该帐号，以免造成资源浪费，由此带来问题均由用户自行承担。\n\n隐私保护:\n\n用户同意个人隐私信息是指那些能够对用户进行个人辨识或涉及个人通信的信息，包括下列信息：用户真实姓名，身份证号，手机号码，IP地址。而非个人隐私信息是指用户对本服务的操作状态以及使用习惯等一些明确且客观反映在sheepcao工作室服务器端的基本记录信息和其他一切个人隐私信息范围外的普通信息；以及用户同意公开的上述隐私信息；\n\nsheepcao工作室将会采取合理的措施保护用户的个人隐私信息，除法律或有法律赋予权限的政府部门要求或用户同意等原因外，sheepcao工作室未经用户同意不向除合作单位以外的第三方公开、 透露用户个人隐私信息。 但是，经用户同意，或用户与sheepcao工作室及合作单位之间就用户个人隐私信息公开或使用另有约定的除外，同时用户应自行承担因此可能产生的任何风险，sheepcao工作室对此不予负责。同时，为了运营和改善技术和服务，sheepcao工作室可能会自行收集使用或向第三方提供用户的非个人隐私信息，这将有助于DaysInLine的服务质量。\n\n用户同意，在使用DaysInLine服务时也同样受sheepcao工作室隐私政策的约束。当您接受本协议条款时，您同样认可并接受sheepcao工作室隐私政策的条款。\n\nDaysInLine商标信息\n\nDaysInLine服务中所涉及的图形、文字或其组成，以及其他sheepcao工作室标志及产品、服务名称，均为sheepcao工作室（以下简称“sheepcao工作室标识”）。未经sheepcao工作室事先书面同意，用户不得将sheepcao工作室标识以任何方式展示或使用或作其他处理，也不得向他人表明您有权展示、使用、或其他有权处理sheepcao工作室标识的行为。\n\n法律责任及免责\n\n1、用户违反本《协议》或相关的服务条款的规定，导致或产生的任何第三方主张的任何索赔、要求或损失，包括合理的律师费，用户同意赔偿sheepcao工作室与合作公司、关联公司，并使之免受损害。\n\n2、用户因第三方如电信部门的通讯线路故障、技术问题、网络、电脑故障、系统不稳定性及其他各种不可抗力原因而遭受的一切损失，sheepcao工作室及合作单位不承担责任。\n\n3、因技术故障等不可抗事件影响到服务的正常运行的，sheepcao工作室及合作单位承诺在第一时间内与相关单位配合，及时处理进行修复，但用户因此而遭受的一切损失，sheepcao工作室及合作单位不承担责任。\n\n4、本服务同大多数互联网服务一样，受包括但不限于用户原因、网络服务质量、社会环境等因素的差异影响，可能受到各种安全问题的侵扰，如他人利用用户的资料，造成现实生活中的骚扰；用户下载安装的其它软件或访问的其他网站中含有“特洛伊木马”等病毒，威胁到用户的计算机信息和数据的安全，继而影响本服务的正常使用等等。用户应加强信息安全及使用者资料的保护意识，要注意加强账号保护，以免遭致损失和骚扰。\n\n5、用户须明白，使用本服务因涉及Internet服务，可能会受到各个环节不稳定因素的影响。因此，本服务存在因不可抗力、计算机病毒或黑客攻击、系统不稳定、用户所在位置、用户关机以及其他任何技术、互联网络、通信线路原因等造成的服务中断或不能满足用户要求的风险。用户须承担以上风险，sheepcao工作室不作担保。对因此导致用户不能发送和接受阅读信息、或接发错信息，sheepcao工作室不承担任何责任。\n\n6、用户须明白，在使用本服务过程中存在有来自任何他人的包括威胁性的、诽谤性的、令人反感的或非法的内容或行为或对他人权利的侵犯（包括知识产权）的匿名或冒名的信息的风险，用户须承担以上风险，sheepcao工作室和合作公司对本服务不作任何类型的担保，不论是明确的或隐含的，包括所有有关信息真实性、适商性、适于某一特定用途、所有权和非侵权性的默示担保和条件，对因此导致任何因用户不正当或非法使用服务产生的直接、间接、偶然、特殊及后续的损害，不承担任何责任。\n\n7、sheepcao工作室定义的信息内容包括：文字、软件、声音、相片、录像、图表；在广告中全部内容；sheepcao工作室为用户提供的商业信息，所有这些内容受版权、商标权、和其它知识产权和所有权法律的保护。所以，用户只能在sheepcao工作室和广告商授权下才能使用这些内容，而不能擅自复制、修改、编纂这些内容、或创造与内容有关的衍生产品。\n\n";
}

-(NSString *)ENbody
{
    return @"Acceptance\n\nThese Terms regulate the legal relationship between you and the Provider. You may not use DaysInLine if you don't accept them. The Terms are always made available to you prior to the download of DaysInLine application. By downloading, installing, using or otherwise accessing DaysInLine, you are expressing your acceptance and willingness to be bound by the Terms. You must also confirm your acceptance by selecting a checkbox before signing up for DaysInLine in a case you want to use account-based features.\nYou may not accept these Terms unless you are at least 13 years of age and you have sufficient legal capacity to enter into a contract. If you are 13 or older but under 18 years of age, you must have your parent or legal guardian’s permission to accept the Terms and use DaysInLine.\n\nTerm and Termination\n\nThe Terms will remain in full force and effect while you use DaysInLine and until terminated by either you or the Provider.\n\nTermination always includes deletion of your user account and all related data and content, unless your data and content have been shared with other users, and they have not deleted them.\n\nAmendments\n\nFrom time to time, Provider may amend the Terms at its sole discretion. You will be notified about the planned changes in advance through DaysInLine application or via e-mail. By continued use of DaysInLine, you are expressing your acceptance of the changes. If you don't agree with the changes, you may terminate the Terms at any time.\n\nYour use of DaysInLine\n\nYou must use DaysInLine only in accordance with the Terms, for the purpose it was intended and obey all of the applicable laws.\n\nRegistration and User Account\n\nIn order to be able to access all features of DaysInLine you have to sign up. You agree to provide accurate, truthful and current information and keep it up to date.\n\nYou must keep your account login information confidential and secure and you may not share it with anyone. You are solely responsible for any activities that occur under your account.\n\nThe Provider reserves the right to refuse your registration or suspend your DaysInLine account at any time.\n\nUser generated content\n\nYou may enter and upload texts, numerical data or other content to DaysInLine. You retain copyright and any other rights to the content that qualifies for a legal protection. For such content you grant Provider a worldwide non-exclusive, no-charge and royalty-free license to use it in the connection with provision of the services, including without limitation, rights to copy, reproduce, modify, create derivative works of, publish, display, upload, transmit, distribute, market and sublicense. You represent that you have all necessary rights and consents to do so. The license lasts for the full term of the copyright or until a termination of the Terms.\nYou are solely responsible for any content you provide and for any consequences thereof. You may not enter or upload unlawful content or content that infringes copyright or any other third party rights. You may not upload any content describing or depicting violence or content which is pornographic, discriminatory, racist, defamatory or otherwise illegal and share it with other users of DaysInLine.\nProvider does not review the user content, but reserves the right to remove or disable access to any user content for any reason.\nProvider has no responsibility for the accuracy of the content you provided or which was created by DaysInLine based on your input.\nYou are solely responsible for backing up the content you enter or upload to DaysInLine.\n\nLicense and ownership\n\nDaysInLine application and all rights therein, including intellectual property rights, shall remain Provider's property or the property of its licensors. Nothing in the Terms shall be construed to grant you any rights, except for the limited license granted below. \nSubject to the Terms, Provider grants you a limited, non-exclusive, non-transferrable, non-sublicensable license, to access and use DaysInLine and its PRO features purchased pursuant to the Terms on any same-platform device (i.e. iOS device) that you own and control. The license is granted solely for your personal, non-commercial use. Third party services or libraries included in DaysInLine are licensed to you either under these Terms, or under the third party's license terms, if applicable.\nBased on your license, you may not access DaysInLine with other means than the mobile phone application, mine or extract any data from DaysInLine databases, modify, reverse engineer, decompile, dissasemble or create derivative works of DaysInLine application or any part thereof and circumvent any technology used to protect the paid PRO features. You also may not rent, lease, lend, sell, transfer, redistribute, or sublicense the DaysInLine application.\n\nHardware and System Requirements\n\nInformation about the current hardware and system requirements of DaysInLine, technical restrictions and and other limitations are always available on the platform-specific page of the application. \n\nMaintenance and Support\nDaysInLine is subject to a continuous development and Provider reserves the right, at it's sole discretion, to update the DaysInLine application, change the nature of DaysInLine or modify or discontinue some of the features without prior notice to you. You acknowledge that Provider has no obligation to maintain or update DaysInLine.\nProvider does not guarantee an uninterrupted provision of the services. DaysInLine may be temporary unavailable due to the maintenance, certain technical difficulties, or other events that are beyond Provider's control.\nIf you have some questions, problems or suggestions, you can reach the Provider via contacts provided hereafter. However, you acknowledge that the support to non-paying users of DaysInLine is limited due to the limited capacity of the Provider.\n\nPrivacy \n\n(a)Personal data processing\n\nYou agree that your Personal Data, including your first name, last name, date of birth, sex, e-mail address, profile photo, personal financial information (income, expenses), language preference and location (collectively referred as “Personal Data”) may be processed by the Provider.\nYou agree that you provide all your Personal Data voluntarily. However, provision of Personal Data is required for signing up and proper functioning of some of the DaysInLine features and related services. Mandatory fields in the sign up form are marked. \n\n(b)Purpose of the processing\nThe purpose of processing of your Personal Data lies mainly in setting up and keeping your DaysInLine account and ensuring features like e.g. server synchronization or sharing information with other users. However, Provider may also process your Personal Data in order to improve your experinece and further develop DaysInLine, to extract anonymous data and to communicate with you.\n\n(c)Term of the processing\n\nPersonal Data is being processed while you use the DaysInLine account and until your consent to the processing is withdrawn and the account deleted.\n\n(d)No forwarding\n\nProvider does not provide Personal Data to third parties, except as required by the applicable laws. However, Personal Data may be processed for Provider by third parties, but only for the purposes specified in this Policy, on a basis of written contract and under statutory conditions.\nSharing your data with other users of DaysInLine is completely under your control.\n\n(e)Information, correction and deletion\n\nYou hereby acknowledge that you are entitled to withdraw your consent to the processing of your Personal Data at any time, you have the right to access, correct or discard your Personal Data or remove them if misleading. Furthermore, you are entitled to contact the Provider in writing with any complaint concerning the processing of your Personal Data and, in case of dissatisfaction with the answer, consult the Office for Personal Data Protection of the Czech Republic.\nYour consent to the processing of your Personal Data may only be withdrawn by sending a written notice to the address of the Provider. If your consent to Personal Data processing is withdrawn, the DaysInLine account will be deleted by the Provider with the consequences set out in the Terms.\n\n(f)Communication and Offers\n\nYou hereby agree that the Provider may use the Personal Data provided by you to send commercial offers and communication with respect to DaysInLine, related services or services of business partners associated with the Provider.\n\n(g)Payment information\n\nProvider does not store any of your payment information. When you make purchases through DaysInLine, your credit card information and other data are collected and stored only by third party payment processors.\n\n(h)Technical and Anonymous Data\n\nYou hereby agree that Provider may collect and use technical data, including but not limited to information about your mobile device and system, internet connection or your use of DaysInLine application. The purpose of the collection of technical data is to ensure quality, increase your comfort and further analyse and develop DaysInLine and related services.\nYou also agree that Provider may anonymize and collect your age and sex data in connection with the data you enter or upload to DaysInLine and use it for the purpose of anonymous analyses and statistics.\n\nBoth, technical and anonymous data, are stored separately from the Personal Data and cannot be linked back to you in any way in order to identify you.\n\nYou agree that the anonymous data may be disclosed or sold to third parties, including outside the territory of the European Union.\n\n(i)Data security\n\nYour Personal Data is stored and processed automatically in the electronic form on the secure servers with firewall protection and physical security measures. Servers are located exclusively in the Czech Republic, so the Provider has to comply with the high data protection standards of the European Union. Provider currently does not export data to third parties outside the European Union.\n\nHowever, you agree that in the future Provider may decide to transfer your Personal Data abroad, including outside the territory of the European Union, and store it and process it with a help of cloud services provided by Amazon, Microsoft or Google.\n\nYour Personal Data is always transferred from you to the servers using secure SSL connections.\n\nYou acknowledge, that even Provider uses all standard security measures, the security of your Personal Data and other information can't be guaranteed.\n\nYou can withdraw your given consent at any time by deleting your DaysInLine account and the DaysInLine application.\n\nIndemnification\n\nYou agree to indemnify and hold Provider, its directors, officers, employees and other representatives, harmless from any and all third-party claims arising from your use of DaysInLine, including any liability or expenses arising from any claims, direct or indirect damages, lost profits, suits, judgments, litigation costs and attorneys' fees.\n\niOS Platform\n\nIf you are an iOS device user, the terms in this section also apply to you:\n\nYou acknowledge that the Terms are concluded between you and the Provider only, not with Apple, and that the Provider, not Apple, is solely responsible for the App and the content thereof, excluding user content.\n\nThe license granted to you must be limited to use DaysInLine only as permitted by the Usage Rules set forth in the App Store Terms of Service.\n\nProvider and not Apple is solely responsible for providing any maintenance and support services with respect to DaysInLine. You acknowledge that Apple has no obligation whatsoever to furnish any maintenance and support services with respect to DaysInLine.\n\nYou acknowledge that, in the event of any third party claim that DaysInLine or your possession and use of DaysInLine infringes that third party’s intellectual property rights, Provider, not Apple, will be solely responsible for the investigation, defense, settlement and discharge of any such intellectual property infringement claim.\n\nYou acknowledge and agree that Apple and Apple’s subsidiaries are third party beneficiaries of this Agreement, and that, upon your acceptance of the Terms, Apple will have the right (and will be deemed to have accepted the right) to enforce the Terms against you as a third party beneficiary thereof.\n\n";
}


@end
