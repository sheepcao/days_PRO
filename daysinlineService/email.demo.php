
<?php
require 'email.class.php';

$mailto='eric.cao@activenetwork.com';  //收件人
$subject="测试邮件"; //邮件主题
$body="真的可以吗";  //邮件内容
sendmailto($mailto,$subject,$body);
echo "finish".date('时间：Y年m月d日   H:i');


function sendmailto($mailto, $mailsub, $mailbd)
{
    //require_once ('email.class.php');
    //##########################################
    $smtpserver     = "smtp.163.com"; //SMTP服务器
    $smtpserverport = 25; //SMTP服务器端口
    $smtpusermail   = "提醒 <myservice@163.com>"; //SMTP服务器的用户邮箱
    $smtpemailto    = $mailto;
    $smtpuser       = "sheepcao1986@163.com"; //SMTP服务器的用户帐号
    $smtppass       = "caoguangxu1986!"; //SMTP服务器的用户密码
    $mailsubject    = $mailsub; //邮件主题
    $mailsubject    = "=?UTF-8?B?" . base64_encode($mailsubject) . "?="; //防止乱码
    $mailbody       = $mailbd; //邮件内容
    //$mailbody = "=?UTF-8?B?".base64_encode($mailbody)."?="; //防止乱码
    $mailtype       = "HTML"; //邮件格式（HTML/TXT）,TXT为文本邮件. 139邮箱的短信提醒要设置为HTML才正常
    ##########################################
    $smtp           = new smtp($smtpserver, $smtpserverport, true, $smtpuser, $smtppass); //这里面的一个true是表示使用身份验证,否则不使用身份验证.
    $smtp->debug    = FALSE; //是否显示发送的调试信息
    $smtp->sendmail($smtpemailto, $smtpusermail, $mailsubject, $mailbody, $mailtype);
    
}