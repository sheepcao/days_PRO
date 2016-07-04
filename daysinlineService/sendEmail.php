<?php
    
    function getStatusCodeMessage($status)
    {
        // these could be stored in a .ini file and loaded
        // via parse_ini_file()... however, this will suffice
        // for an example
        $codes = Array(
                       100 => 'Continue',
                       101 => 'Switching Protocols',
                       200 => 'OK',
                       201 => 'Created',
                       202 => 'Accepted',
                       203 => 'Non-Authoritative Information',
                       204 => 'No Content',
                       205 => 'Reset Content',
                       206 => 'Partial Content',
                       300 => 'Multiple Choices',
                       301 => 'Moved Permanently',
                       302 => 'Found',
                       303 => 'See Other',
                       304 => 'Not Modified',
                       305 => 'Use Proxy',
                       306 => '(Unused)',
                       307 => 'Temporary Redirect',
                       400 => 'Bad Request',
                       401 => 'Unauthorized',
                       402 => 'Payment Required',
                       403 => 'Forbidden',
                       404 => 'Not Found',
                       405 => 'Method Not Allowed',
                       406 => 'Not Acceptable',
                       407 => 'Proxy Authentication Required',
                       408 => 'Request Timeout',
                       409 => 'Conflict',
                       410 => 'Gone',
                       411 => 'Length Required',
                       412 => 'Precondition Failed',
                       413 => 'Request Entity Too Large',
                       414 => 'Request-URI Too Long',
                       415 => 'Unsupported Media Type',
                       416 => 'Requested Range Not Satisfiable',
                       417 => 'Expectation Failed',
                       500 => 'Internal Server Error66',
                       501 => 'Not Implemented',
                       502 => 'Bad Gateway',
                       503 => 'Service Unavailable',
                       504 => 'Gateway Timeout',
                       505 => 'HTTP Version Not Supported'
                       );
        
        return (isset($codes[$status])) ? $codes[$status] : '';
    }
    
    // Helper method to send a HTTP response code/message
    function sendResponse($status = 200, $body = '', $content_type = 'application/json')
    {
        $status_header = 'HTTP/1.1 ' . $status . ' ' . getStatusCodeMessage($status);
        header($status_header);
        header('Content-type: ' . $content_type);
        
        echo $body;
    }
    
    if (isset($_POST['tag']) && $_POST['tag'] != '') {
        // get tag
        $tag = $_POST['tag'];
        
        require_once 'include/DB_Functions.php';
        require_once 'email.class.php';

        $db = new DB_Functions();
        // response Array
        $response = array("tag" => $tag, "success" => 0, "error" => 0);
//        sendResponse(200,json_encode($_POST));

        // check for tag type
        if ($tag == 'sendEmail') {
            $name = $_POST['name'];
//                    sendResponse(200,json_encode($_POST));

            $password = $db->getPassword($name);
            sendResponse(416,$password);

            if ($password != false) {
                $Lang = $_POST['Lang'];
                
                if($Lang === "en")
                {
                    $subject="DaysInLine Password"; //邮件主题
                    $body="Dear user:</br>Here is your password:</br>".$password."</br></br>Please protect your password seriously!</br></br>Best Regard!";  //邮件内容
                    $user ="DaysInLine <sheepcao1986@163.com>";
                }else
                {
                    $subject="DaysInLine 密码找回"; //邮件主题
                    $body="尊敬的用户:</br>您在DaysInLine注册账号的密码为:</br>".$password."</br></br>请妥善保管</br></br>感谢您的支持!";   //邮件内容
                    $user ="DaysInLine <sheepcao1986@163.com>";
                }
                $mailto=$name;  //收件人
                $isDone = sendmailto($mailto,$subject,$body,$user);
                sendResponse(200,"done");

            }else
            {
                sendResponse(416,"not exist");
            }

        }

        
    } else {
        echo "Access Denied";
    }
    
    
    function sendmailto($mailto, $mailsub, $mailbd,$postUser)
    {
        //require_once ('email.class.php');
        //##########################################
        $smtpserver     = "smtp.163.com"; //SMTP服务器
        $smtpserverport = 25; //SMTP服务器端口
        $smtpusermail   = $postUser; //SMTP服务器的用户邮箱
        $smtpemailto    = $mailto;
        $smtpuser       = "sheepcao1986@163.com"; //SMTP服务器的用户帐号
        $smtppass       = "caoguangxu1986!"; //SMTP服务器的用户密码
        $mailsubject    = $mailsub; //邮件主题
        $mailsubject    = "=?UTF-8?B?" . base64_encode($mailsubject) . "?="; //防止乱码
        $mailbody       = $mailbd; //邮件内容
        //$mailbody = "=?UTF-8?B?".base64_encode($mailbody)."?="; //防止乱码
        $mailtype   = "HTML"; //邮件格式（HTML/TXT）,TXT为文本邮件. 139邮箱的短信提醒要设置为HTML才正常
        ##########################################
        $smtp  = new smtp($smtpserver, $smtpserverport, true, $smtpuser, $smtppass); //这里面的一个true是表示使用身份验证,否则不使用身份验证.
        $smtp->debug    = FALSE; //是否显示发送的调试信息
       
        return $smtp->sendmail($smtpemailto, $smtpusermail, $mailsubject, $mailbody, $mailtype);
        
    }
    
    
    ?>
