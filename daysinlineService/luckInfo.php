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
        $db = new DB_Functions();
        
        // response Array
        $response = array("tag" => $tag, "success" => 0, "error" => 0);
        
        // check for tag type
        if ($tag == 'luckInfo') {
            // Request type is check Login
            $name = $_POST['name'];
            $week = $_POST['week'];

            $all_names = array("白羊座", "金牛座", "双子座","巨蟹座","狮子座","处女座","天秤座","天蝎座","射手座","摩羯座","水瓶座","双鱼座");
            
            if($name === "all" )
            {
                $num = count($all_names);
                for($i=0;$i<$num;++$i){
                    $alert = $db->getLuckInfo($all_names[$i],$week);
                }
            }else
            {
                $alert = $db->getLuckInfo($name,$week);
            }
            
            if ($alert != false) {
//                $startTime = explode('-', $alert['date'])[0];
//                $endTime = explode('-', $alert['date'])[1];

//                $response["success"] = 1;
//                $response["start_date"] = $startTime;
//                $response["end_date"] = $endTime;
//                $response["week"] = $alert['weekth'];
//                $response["content"] = $alert['money'];
//                $response["name"] = $alert['name'];


                sendResponse(200,json_encode($alert));

                
            } else {
                // user not found
                // echo json with error = 1
                $response["success"] = 0;
                $response["error_msg"] = $alert;
                sendResponse(417,json_encode($response));
            }
        }
        
    } else {
        echo "Access Denied";
    }
    
    
    
    
    ?>
