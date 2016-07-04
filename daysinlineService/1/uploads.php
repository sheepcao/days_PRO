<?php
    
    /**
     * File to handle all API requests
     * Accepts GET and POST
     *
     * Each request will be identified by TAG
     * Response will be JSON data
     
     /**
     * check for POST request
     */
    
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
        //        header('Accept' = 'image/jpeg');
        
        echo $body;
    }
    
    //    sendResponse(200,json_encode($_POST));
    //
    //    sendResponse(2300,json_encode($_FILES));
    
    if (isset($_POST['tag']) && $_POST['tag'] != '') {
        // get tag
        $tag = $_POST['tag'];
        
        
        // include db handler
        require_once 'include/DB_Functions.php';
        $db = new DB_Functions();
        
        // response Array
        $response = array("tag" => $tag, "success" => 0, "error" => 0);
        
        // check for tag type
        if ($tag == 'login') {
            // Request type is check Login
            $name = $_POST['name'];
            $password = $_POST['password'];
            
            //            sendResponse(200,json_encode($_POST));
            
            // check for user
            $user = $db->getUserByNameAndPassword($name, $password);
            if ($user != false) {
                // user found
                // echo json with success = 1
                $response["success"] = 1;
                $response["username"] = $user["unique_id"];
                $response["backup_device"] = $user["backup_device"];
                $response["backup_day"] = $user["backup_day"];
                
                $response["created"] = $user["created_at"];
                
                
                
                sendResponse(200,json_encode($response));
            } else {
                // user not found
                // echo json with error = 1
                $response["name"] = $name;
                $response["password"] = $password;
                
                $response["error"] = 1;
                $response["error_msg"] = "Incorrect username or password!";
                sendResponse(417,json_encode($response));
            }
        
        } else if ($tag == 'register') {
            // Request type is Register new user
            $name = $_POST['name'];
            $password = $_POST['password'];
            
//            sendResponse(200,json_encode($_POST));
            
            // check if user is already existed
            if ($db->isUserExisted($name)) {
                // user is already existed - error response
                $responseError =array("error_msg" => "User already existed");
                //			$response["error"] = 2;
                //			$response["error_msg"] = "User already existed";
                sendResponse(417,json_encode($responseError));
            } else {
                // store user
                $user = $db->storeUser($name,$password);
                if ($user) {
                    // user stored successfully
                    $response["success"] = 1;
                    $response["username"] = $user["unique_id"];
                    $response["password"] = $user["password"];
                    $response["created_at"] = $user["created_at"];
                    
                    
                    sendResponse(200,json_encode($response));
                } else {
                    // user failed to store
                    $response["error"] = 1;
                    $response["error_msg"] = "Error occurred in Registration";
                    sendResponse(417,json_encode($response));
                }
            }
            
            
        }else if ($tag == 'changePassword') {
            // Request type is check Login
            $name = $_POST['name'];
            $password = $_POST['password'];


            // check for user
            $user = $db->changePassword($name, $password);
            if ($user != false) {
                // user found
                // echo json with success = 1
                $response["success"] = 1;
                
                
                
                sendResponse(200,json_encode($response));
            } else {
                // user not found
                // echo json with error = 1
                $response["name"] = $name;
                $response["password"] = $password;
                
                $response["error"] = 1;
                $response["error_msg"] = "change password failed!";
                sendResponse(417,json_encode($response));
            }
        }else if ($tag == 'uploadSQLs') {
            
            $name = $_POST['name'];
            $device = $_POST['backup_device'];
            
            
            
            
            
            if ((($_FILES["file"]["type"] == "application/octet-stream")||($_FILES["file"]["type"] == "text/plain"))
                && ($_FILES["file"]["size"] < 2000000))
            {
                if ($_FILES["file"]["error"] > 0)
                {
                    $response["error"] = 1;
                    $response["error_msg"] = "Return Code: " . $_FILES["file"]["error"];
                    
                    sendResponse(417,json_encode($response));
                    
                    
                }
                else
                {
                    $response["Upload"] = $_FILES["file"]["name"];
                    $response["Type"] = $_FILES["file"]["type"];
                    $response["Size"]= ($_FILES["file"]["size"] / 1024);
                    $response["Temp file"] = $_FILES["file"]["tmp_name"];
                    
                }
                
                if(!is_writable(getcwd() ."/upload/") )
                {
                    $response["errorPath"] = "upload  is not writable.";
                    chmod(getcwd() ."/upload/",777);
                    
                }
                
                if (file_exists(getcwd() ."/upload/" . $_FILES["file"]["name"]))
                {
                    chmod(getcwd() ."/upload/" . $_FILES["file"]["name"],777); //Change the file permissions if allowed
                    unlink(getcwd() ."/upload/" . $_FILES["file"]["name"]);
                    
                    
                    $moved = move_uploaded_file($_FILES["file"]["tmp_name"],
                                                getcwd() ."/upload/" . $_FILES["file"]["name"]);
                    if($moved)
                    {
                        $response["NoError"] = "Stored in: " . getcwd() . "/upload/" . $_FILES["file"]["name"];
                        
                        
                        $user = $db->updateBackup($name,$device);
                        if ($user != false) {
                            // user found
                            // echo json with success = 1
                            $response["success"] = 1;
                            $response["backup_day"] = $user["backup_day"];
                            $response["backup_device"] = $user["backup_device"];

                            sendResponse(200,json_encode($response));
                            
                            
                        } else {
                            // user not found
                            
                            $response["error"] = 1;
                            $response["error_msg"] = "backup failed!";
                            sendResponse(417,json_encode($response));
                       
                        }
                        
                        
                        
                        
                    }
                    else
                    {
                        
                        $response["errorUploading"] = "Return Code: " . $_FILES["file"]["error"];
                        sendResponse(417,json_encode($response));
                        
                        
                    }
                    
                    
                    
                }
                else
                {
                    $moved = move_uploaded_file($_FILES["file"]["tmp_name"],
                                                getcwd() ."/upload/" . $_FILES["file"]["name"]);
                    if($moved)
                    {
                        $response["NoError"] = "Stored in: " . getcwd() . "/upload/" . $_FILES["file"]["name"];
                        
                        
                        $user = $db->updateBackup($name,$device);
                        if ($user != false) {
                            // user found
                            // echo json with success = 1
                            $response["success"] = 1;
                            $response["backup_day"] = $user["backup_day"];
                            $response["backup_device"] = $user["backup_device"];
                            sendResponse(200,json_encode($response));
                            
                            
                        } else {
                            // user not found
                            
                            $response["error"] = 1;
                            $response["error_msg"] = "backup failed!";
                            sendResponse(417,json_encode($response));
                        }
                        
                        
                        
                    }
                    else
                    {
                        
                        $response["errorUploading"] = "Return Code: " . $_FILES["file"]["error"];
                        sendResponse(417,json_encode($response));
                        
                        
                    }
                    
                    
                }
                
            }else
            {
                $response["error"] = 1;
                $response["error_msg"] = "not success!!!!!!";
                
                sendResponse(2004,json_encode($response));
                
            }
        
//
            
        }else if ($tag == 'uploadSounds') {
            //
            $name = $_POST['name'];
            $count = $_POST['soundCount'];
            
            
//                        sendResponse(200,json_encode($_FILES));
            
            
            for($num = 0; $num<(int)$count;$num++)
            {
                if (($_FILES["file".$num]["type"] == "audio/x-caf")
                    && ($_FILES["file".$num]["size"] < 2000000))
                {
                

                    
                    if ($_FILES["file".$num]["error"] > 0)
                    {
                        $response["file".$num]["error"] = 1;
                        $response["file".$num]["error_msg"] = "Return Code: " . $_FILES["file".$num]["error"];
                        
                        sendResponse(417,json_encode($response));

                        return;
                        
                        
                    }else
                    {
                        $response["file".$num]["Upload"] = $_FILES["file".$num]["name"];
                        $response["file".$num]["Type"] = $_FILES["file".$num]["type"];
                        $response["file".$num]["Size"]= ($_FILES["file".$num]["size"] / 1024);
                        $response["file".$num]["Temp file"] = $_FILES["file".$num]["tmp_name"];

                        
                    }
                    
                    
                    if(!is_writable(getcwd() ."/upload/") )
                    {
                        $response["file".$num]["errorPath"] = "upload  is not writable.";
                        chmod(getcwd() ."/upload/",777);
                        
                    }
                    

                    
                    if (file_exists(getcwd() ."/upload/" . $_FILES["file".$num]["name"]))
                    {
                        chmod(getcwd() ."/upload/" . $_FILES["file".$num]["name"],777); //Change the file permissions if allowed
                        unlink(getcwd() ."/upload/" . $_FILES["file".$num]["name"]);
                        
                        
                        $moved = move_uploaded_file($_FILES["file".$num]["tmp_name"],
                                                    getcwd() ."/upload/" . $_FILES["file".$num]["name"]);
                        
//                        sendResponse(200,json_encode($response));

                        if($moved)
                        {
                            $response["file".$num]["NoError"] = "Stored in: " . getcwd() . "/upload/" . $_FILES["file".$num]["name"];
                            
                            
//                            sendResponse(200,json_encode($response));
                            
                            
                            
                        }
                        else
                        {
                            
                            $response["file".$num]["errorUploading"] = "Return Code: " . $_FILES["file".$num]["error"];
//                            sendResponse(417,json_encode($response));
                            
                            
                        }
                        
                        
                        
                    }
                    else
                    {
                        $moved = move_uploaded_file($_FILES["file".$num]["tmp_name"],
                                                    getcwd() ."/upload/" . $_FILES["file".$num]["name"]);
                        if($moved)
                        {
                            $response["file".$num]["NoError"] = "Stored in: " . getcwd() . "/upload/" . $_FILES["file".$num]["name"];
                            
                            
//                            sendResponse(200,json_encode($response));
                            
                            
                        }
                        else
                        {
                            
                            $response["file".$num]["errorUploading"] = "Return Code: " . $_FILES["file".$num]["error"];
//                            sendResponse(417,json_encode($response));
                            
                            
                        }
                        
                        
                    }
                    
                }else
                {
                    $response["file".$num]["error"] = 1;
                    $response["file".$num]["error_msg"] = "not success!!!!!!";
                    
//                    sendResponse(2004,json_encode($response));
                    
                }
                
                
                
            }
        
            
                    sendResponse(200,json_encode($response));

        
                
                
                
                
//            }
            
        }else if ($tag == 'uploadImages') {
            //
            $name = $_POST['name'];
            $count = $_POST['imageCount'];
            
            
            //                        sendResponse(200,json_encode($_FILES));
            
            
            for($num = 0; $num<(int)$count;$num++)
            {
                if (($_FILES["file".$num]["type"] == "image/png")
                    && ($_FILES["file".$num]["size"] < 2000000))
                {
                    
                    
                    
                    if ($_FILES["file".$num]["error"] > 0)
                    {
                        $response["file".$num]["error"] = 1;
                        $response["file".$num]["error_msg"] = "Return Code: " . $_FILES["file".$num]["error"];
                        
                        sendResponse(417,json_encode($response));
                        
                        return;
                        
                        
                    }else
                    {
                        $response["file".$num]["Upload"] = $_FILES["file".$num]["name"];
                        $response["file".$num]["Type"] = $_FILES["file".$num]["type"];
                        $response["file".$num]["Size"]= ($_FILES["file".$num]["size"] / 1024);
                        $response["file".$num]["Temp file"] = $_FILES["file".$num]["tmp_name"];
                        
                        
                    }
                    
                    
                    if(!is_writable(getcwd() ."/upload/") )
                    {
                        $response["file".$num]["errorPath"] = "upload  is not writable.";
                        chmod(getcwd() ."/upload/",777);
                        
                    }
                    
                    
                    
                    if (file_exists(getcwd() ."/upload/" . $_FILES["file".$num]["name"]))
                    {
                        chmod(getcwd() ."/upload/" . $_FILES["file".$num]["name"],777); //Change the file permissions if allowed
                        unlink(getcwd() ."/upload/" . $_FILES["file".$num]["name"]);
                        
                        
                        $moved = move_uploaded_file($_FILES["file".$num]["tmp_name"],
                                                    getcwd() ."/upload/" . $_FILES["file".$num]["name"]);
                        
                        //                        sendResponse(200,json_encode($response));
                        
                        if($moved)
                        {
                            $response["file".$num]["NoError"] = "Stored in: " . getcwd() . "/upload/" . $_FILES["file".$num]["name"];
                            
                            
                            //                            sendResponse(200,json_encode($response));
                            
                            
                            
                        }
                        else
                        {
                            
                            $response["file".$num]["errorUploading"] = "Return Code: " . $_FILES["file".$num]["error"];
                            //                            sendResponse(417,json_encode($response));
                            
                            
                        }
                        
                        
                        
                    }
                    else
                    {
                        $moved = move_uploaded_file($_FILES["file".$num]["tmp_name"],
                                                    getcwd() ."/upload/" . $_FILES["file".$num]["name"]);
                        if($moved)
                        {
                            $response["file".$num]["NoError"] = "Stored in: " . getcwd() . "/upload/" . $_FILES["file".$num]["name"];
                            
                            
                            //                            sendResponse(200,json_encode($response));
                            
                            
                        }
                        else
                        {
                            
                            $response["file".$num]["errorUploading"] = "Return Code: " . $_FILES["file".$num]["error"];
                            //                            sendResponse(417,json_encode($response));
                            
                            
                        }
                        
                        
                    }
                    
                }else
                {
                    $response["file".$num]["error"] = 1;
                    $response["file".$num]["error_msg"] = "not success!!!!!!";
                    
                    //                    sendResponse(2004,json_encode($response));
                    
                }
                
                
                
            }
            
            
            sendResponse(200,json_encode($response));
            
            
            
            
            
            
            //            }
            
        }else if ($tag == 'download') {
            //
            $name = $_POST['name'];
            

            
            
            if ($handle = opendir(getcwd() ."/upload/")) {
                
                while (false !== ($entry = readdir($handle))) {
                    
                    
                    $pieces = explode("_", $entry);
                    
                    if ($pieces[0] == $name)
                    {
                        $response["files"][] = $entry;
                        
                    }
                    
                    
                }
                
                closedir($handle);
            }
            
            sendResponse(200,json_encode($response));
            
            
//
//                    if ($_FILES["file".$num]["error"] > 0)
//                    {
//                        $response["file".$num]["error"] = 1;
//                        $response["file".$num]["error_msg"] = "Return Code: " . $_FILES["file".$num]["error"];
//                        
//                        sendResponse(417,json_encode($response));
//                        
//                        return;
//                        
//                        
//                    }else
//                    {
//                        $response["file".$num]["Upload"] = $_FILES["file".$num]["name"];
//                        $response["file".$num]["Type"] = $_FILES["file".$num]["type"];
//                        $response["file".$num]["Size"]= ($_FILES["file".$num]["size"] / 1024);
//                        $response["file".$num]["Temp file"] = $_FILES["file".$num]["tmp_name"];
//                        
//                        
//                    }
//                    
//                    
//                    if(!is_writable(getcwd() ."/upload/") )
//                    {
//                        $response["file".$num]["errorPath"] = "upload  is not writable.";
//                        chmod(getcwd() ."/upload/",777);
//                        
//                    }
//                    
//                    
//                    
//                    if (file_exists(getcwd() ."/upload/" . $_FILES["file".$num]["name"]))
//                    {
//                        chmod(getcwd() ."/upload/" . $_FILES["file".$num]["name"],777); //Change the file permissions if allowed
//                        unlink(getcwd() ."/upload/" . $_FILES["file".$num]["name"]);
//                        
//                        
//                        $moved = move_uploaded_file($_FILES["file".$num]["tmp_name"],
//                                                    getcwd() ."/upload/" . $_FILES["file".$num]["name"]);
//                        
//                        //                        sendResponse(200,json_encode($response));
//                        
//                        if($moved)
//                        {
//                            $response["file".$num]["NoError"] = "Stored in: " . getcwd() . "/upload/" . $_FILES["file".$num]["name"];
//                            
//                            
//                            //                            sendResponse(200,json_encode($response));
//                            
//                            
//                            
//                        }
//                        else
//                        {
//                            
//                            $response["file".$num]["errorUploading"] = "Return Code: " . $_FILES["file".$num]["error"];
//                            //                            sendResponse(417,json_encode($response));
//                            
//                            
//                        }
//                        
//                        
//                        
//                    }
//                    else
//                    {
//                        $moved = move_uploaded_file($_FILES["file".$num]["tmp_name"],
//                                                    getcwd() ."/upload/" . $_FILES["file".$num]["name"]);
//                        if($moved)
//                        {
//                            $response["file".$num]["NoError"] = "Stored in: " . getcwd() . "/upload/" . $_FILES["file".$num]["name"];
//                            
//                            
//                            //                            sendResponse(200,json_encode($response));
//                            
//                            
//                        }
//                        else
//                        {
//                            
//                            $response["file".$num]["errorUploading"] = "Return Code: " . $_FILES["file".$num]["error"];
//                            //                            sendResponse(417,json_encode($response));
//                            
//                            
//                        }
//                        
//                        
//                    }
//                    
//                }else
//                {
//                    $response["file".$num]["error"] = 1;
//                    $response["file".$num]["error_msg"] = "not success!!!!!!";
//                    
//                    //                    sendResponse(2004,json_encode($response));
//                    
//                }
//                
//                
//                
//            }
//            
        
            
            
            
            
        }else {
            echo "Invalid Request";
        }
        
        
    
    
    }else {
        echo "Access Denied!!";
    }
    
    
?>
