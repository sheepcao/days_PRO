<?php
    
    class DB_Functions {
        
        private $db;
        
        //put your code here
        // constructor
        function __construct() {
            require_once 'DB_Connect.php';
            // connecting to database
            $this->db = new DB_Connect();
            $this->db->connect();
        }
        
        // destructor
        function __destruct() {
            
        }
        
        /**
         * Storing new user
         * returns user details
         */
        
        public function getPermissionAlert()
        {
            $result = mysql_query("SELECT * FROM settinginfo") or die(mysql_error());
            // return user details
            return mysql_fetch_array($result);

        }
        
        public function storeUser($name, $email, $password, $age, $sex) {
            
            $isReviewed = "no";
            $result = mysql_query("INSERT INTO userinfo(unique_id, email, password, age, sex, isReviewed, created_at) VALUES('$name', '$email', '$password', '$age','$sex', '$isReviewed', NOW())");
            // check for successful store
            if ($result) {
                // get user details
                $result = mysql_query("SELECT * FROM userinfo WHERE unique_id = \"$name\"");
                // return user details
                return mysql_fetch_array($result);
            } else {
                return false;
            }
        }
        
        public function storePosition($name,$lat,$long,$invisible,$isReviewed,$age,$sex,$TTscore)
        {
            $result = mysql_query("INSERT INTO positioninfo(username, latitude, longitude, invisible, isReviewed, age, sex, TTscore, updated_at) VALUES('$name','$lat','$long','$invisible','$isReviewed','$age','$sex','$TTscore',NOW())") or die(mysql_error());
            // check for successful store
            if ($result) {
                // get user details
                $result = mysql_query("SELECT * FROM positioninfo where username = '$name'") or die(mysql_error());
                // return user details
                return mysql_fetch_array($result);
            } else {
                return false;
            }
            
        }
        
        
        public function uploadPosition($name,$lat,$long,$invisible,$isReviewed,$age,$sex,$TTscore)
        {
            $result = mysql_query("SELECT * FROM positioninfo where username = '$name'") or die(mysql_error());
            
            $no_of_rows = mysql_num_rows($result);
            
            if ($no_of_rows > 0) {
                $result = mysql_query("update positioninfo set latitude = '$lat',longitude = '$long',invisible = '$invisible',isReviewed = '$isReviewed',updated_at = NOW()  WHERE username = '$name'") or die(mysql_error());
            }else
            {
                $result = mysql_query("INSERT INTO positioninfo(username, latitude, longitude, invisible, isReviewed, age, sex, TTscore, updated_at) VALUES('$name','$lat','$long','$invisible','$isReviewed','$age','$sex','$TTscore',NOW())") or die(mysql_error());
            }
           
            // check for successful store
            if ($result) {
                // get user details
                $result = mysql_query("SELECT * FROM positioninfo where username = '$name'") or die(mysql_error());
                // return user details
                return mysql_fetch_array($result);
            } else {
                return false;
            }
            
        }
        
        
        public function populateDistance($lat,$long,$ratio,$page)
        {
            $start = 50*$page;
            
            $result = mysql_query("SELECT username,latitude,longitude,invisible, isReviewed, age, sex, TTscore,ROUND(6378.138*2*ASIN(SQRT(POW(SIN(($lat*PI()/180-latitude*PI()/180)/2),2)+COS($lat*PI()/180)*COS(latitude*PI()/180)*POW(SIN(($long*PI()/180-longitude*PI()/180)/2),2)))*1000) AS juli FROM positioninfo having juli < $ratio ORDER BY juli LIMIT $start,50") or die(mysql_error());
            
            if ($result) {
                // get user details
                return $result;
            } else {
                return false;
            }
            
        }
        
        /**
         * Get user by email and password
         */
        public function getUserByNameAndPassword($name, $password) {
            $result = mysql_query("SELECT * FROM userinfo u left join JJCinfo j on j.JJCusername = u.unique_id left join TTinfo t on t.TTusername = u.unique_id left join MJinfo m on m.MJusername = u.unique_id WHERE unique_id = '$name'") or die(mysql_error());
            // check for result
            $no_of_rows = mysql_num_rows($result);
            if ($no_of_rows > 0) {
                $result = mysql_fetch_array($result);
                $passwordInDB = $result['password'];
                
                // check for password equality
                if ($passwordInDB == $password) {
                    // user authentication details are correct
                    return $result;
                }
            } else {
                // user not found
                return false;
            }
        }
        
        public function changePassword($name, $password)
        {
            $result = mysql_query("update userinfo set password = '$password' WHERE unique_id = '$name'") or die(mysql_error());
            if ($result)
            {
                return true;
            }else
            {
                return false;
            }
        }
        
        /**
         * Check user is existed or not
         */
        public function isUserExisted($name) {
            $result = mysql_query("SELECT * from userinfo WHERE unique_id = '$name'");
            $no_of_rows = mysql_num_rows($result);
            if ($no_of_rows > 0) {
                // user existed
                return true;
            } else {
                // user not existed
                return false;
            }
        }
        
        public function storeDevice($username,$device) {
            
            $select = mysql_query("SELECT * FROM deviceinfo where device_token = '$device'") or die(mysql_error());
            $no_of_rows = mysql_num_rows($select);
            if ($no_of_rows > 0) {
                //  existed
                if ($username == "SystemAnonymous")
                {
                    return mysql_fetch_array($select);
                }
                $result = mysql_query("update deviceinfo set device_user = '$username' where device_token = '$device'");
                // check for successful store
                if ($result) {
                    // get user details
                    $result = mysql_query("SELECT * FROM deviceinfo where device_user = '$username'") or die(mysql_error());
                    // return user details
                    return mysql_fetch_array($result);
                } else {
                    return false;
                }
                
                
            } else {
                //  not existed
                $result = mysql_query("INSERT INTO deviceinfo(device_token, device_user) VALUES('$device','$username')");
                // check for successful store
                if ($result) {
                    // get user details
                    $result = mysql_query("SELECT * FROM deviceinfo where device_user = '$username'") or die(mysql_error());
                    // return user details
                    return mysql_fetch_array($result);
                } else {
                    return false;
                }
                
            }
            
            
        }
        
        public function fetchDevices()
        {
            $select = mysql_query("SELECT * FROM deviceinfo where device_token <> 'none'") or die(mysql_error());
            if ($select) {
                // get user details
                
                return $select;
            } else {
                return false;
            }
        }
        
        
        public function fetchDeviceFor($username)
        {
            $select = mysql_query("SELECT * FROM deviceinfo where device_user = '$username' AND device_token <> 'none'") or die(mysql_error());
            if ($select) {
                // get user details
                
                return $select;
            } else {
                return false;
            }
        }
        
        /**
         * Storing new topic
         * returns user topic detail
         */
        public function storeTopic($content) {
            
            $result = mysql_query("INSERT INTO topicsinfo(topic_content, topic_day) VALUES('$content',CURDATE())");
            // check for successful store
            if ($result) {
                // get user details
                $result = mysql_query("SELECT * FROM topicsinfo ORDER BY topic_day DESC LIMIT 1") or die(mysql_error());
                // return user details
                return mysql_fetch_array($result);
            } else {
                return false;
            }
        }
        
        public function todayTopic() {
            
            $result = mysql_query("SELECT * FROM topicsinfo ORDER BY topic_day DESC LIMIT 1") or die(mysql_error());
            // check for successful store
            if ($result) {
                
                return mysql_fetch_array($result);
            } else {
                return false;
            }
        }
        
        
        public function fetchTopic() {
            
            $result = mysql_query("SELECT * FROM topicsinfo ORDER BY topic_day DESC LIMIT 1,50") or die(mysql_error());
            // check for successful store
            if ($result) {
                
                return $result;
            } else {
                return false;
            }
        }
        
        
        public function fetchComments($Date) {
            
            $result = mysql_query("SELECT * FROM commentsinfo where comment_topic_day = '$Date'") or die(mysql_error());
            // check for successful store
            if ($result) {
                
                return $result;
            } else {
                return false;
            }
        }
        
        public function fetchCommentsCount($Date) {
            
            $result = mysql_query("SELECT count(*) FROM commentsinfo where comment_topic_day = '$Date'") or die(mysql_error());
            // check for successful store
            if ($result) {
                
                return mysql_fetch_array($result);
            } else {
                return false;
            }
        }
        
        
        public function addNewComment($commentContent,$commentUser,$commentDay) {
            
            $result = mysql_query("INSERT INTO commentsinfo(comment_content, comment_user,comment_topic_day,comment_time) VALUES('$commentContent','$commentUser','$commentDay',NOW())");
            //        return "11";
            // check for successful store
            if ($result) {
                $final = mysql_query("SELECT * FROM commentsinfo where comment_user = '$commentUser' order by comment_time DESC LIMIT 1") or die(mysql_error());
                return mysql_fetch_array($final);
            } else {
                return false;
            }
        }
        
        public function fetchUps($commentID) {
            
            $result = mysql_query("SELECT count(*) FROM upsinfo where up_comment_id = '$commentID'") or die(mysql_error());
            // check for successful store
            if ($result) {
                
                return mysql_fetch_array($result);
            } else {
                return false;
            }
        }
        
        
        public function addUps($commentID,$commentUser) {
            
            $isExsited = mysql_query("SELECT * FROM upsinfo where up_comment_id = '$commentID' AND up_user = '$commentUser'") or die(mysql_error());
            
            $no_of_rows = mysql_num_rows($isExsited);
            if ($no_of_rows > 0) {
                // user existed
                $exsit[] = -1;
                return $exsit;
            } else {
                // user not existed
                $insert = mysql_query("INSERT INTO upsinfo(up_user, up_comment_id) VALUES('$commentUser', '$commentID')") or die(mysql_error());
                // check for successful store
                
                if ($insert)
                {
                    $result = mysql_query("SELECT count(*) FROM upsinfo where up_comment_id = '$commentID'") or die(mysql_error());
                    if ($result)
                    {
                        return mysql_fetch_array($result);
                        
                    }else
                    {
                        return false;
                    }
                }else
                {
                    return false;
                }
                
            }
            
            
        }
        
        /**
         * Get playerInfo by name
         */
        public function getUserInfoByName($name) {
            $result = mysql_query("SELECT * FROM userinfo u left join JJCinfo j on j.JJCusername = u.unique_id left join TTinfo t on t.TTusername = u.unique_id left join MJinfo m on m.MJusername = u.unique_id left join signatureinfo s on s.username = u.unique_id WHERE unique_id = '$name'") or die(mysql_error());
            // check for result
            $no_of_rows = mysql_num_rows($result);
            if ($no_of_rows > 0) {
                $result = mysql_fetch_array($result);
                return $result;
            }else {
                // user not found
                return $result;
            }
        }
        
        /**
         * Storing signature
         * returns signature
         */
        public function storeSignature($content,$username)
        {
            
            $userResult = mysql_query("SELECT * FROM signatureinfo WHERE username = '$username'") or die(mysql_error());
            
            $no_of_rows = mysql_num_rows($userResult);
            $response["error"] = $no_of_rows;
            
            if ($no_of_rows > 0) {
                
                $update = mysql_query("update signatureinfo set content = '$content' where username = '$username'") or die(mysql_error());
                
                if($update)
                {
                    
                    $result = mysql_query("SELECT * FROM signatureinfo WHERE username = '$username'") or die(mysql_error());
                    if ($result)
                    {
                        return mysql_fetch_array($result);
                        
                    }else
                    {
                        return false;
                    }
                }else
                {
                    return false;
                }
                
                
            } else {
                
                
                $insert = mysql_query("INSERT INTO signatureinfo(username, content) VALUES('$username', '$content')") or die(mysql_error());
                if ($insert)
                {
                    $result = mysql_query("SELECT * FROM signatureinfo WHERE username = '$username'") or die(mysql_error());
                    if ($result)
                    {
                        return mysql_fetch_array($result);
                        
                    }else
                    {
                        return false;
                    }
                }else
                {
                    return false;
                }
                
            }
            
            
            
        }
        
        /**
         * get signature
         * returns signature
         */
        
        
        public function fetchSignature($username) {
            $result = mysql_query("SELECT * FROM signatureinfo WHERE username = '$username'") or die(mysql_error());
            // check for result
            $no_of_rows = mysql_num_rows($result);
            if ($no_of_rows > 0) {
                $result = mysql_fetch_array($result);
                return $result;
            }else {
                // signature not found
                return false;
            }
        }
        
        
        /**
         * Storing level
         *
         */
        //    public function registerLevel($username)
        //    {
        //        $isReviewed = "no";
        //
        //
        //        $userResult = mysql_query("SELECT * FROM levelinfo WHERE username = '$username'") or die(mysql_error());
        //
        //        $no_of_rows = mysql_num_rows($userResult);
        //
        //        if ($no_of_rows > 0) {
        //
        //
        //            $update = mysql_query("update levelinfo set isReviewed ='$isReviewed', created_Time = NOW() where username = '$username'") or die(mysql_error());
        //
        //            if($update)
        //            {
        //
        //                $result = mysql_query("SELECT * FROM levelinfo WHERE username = '$username'") or die(mysql_error());
        //                if ($result)
        //                {
        //                    return mysql_fetch_array($result);
        //
        //                }else
        //                {
        //                    return false;
        //                }
        //            }else
        //            {
        //                return false;
        //            }
        //
        //
        //        } else {
        //
        //
        //            $insert = mysql_query("INSERT INTO levelinfo(username, isReviewed,created_Time) VALUES('$username', '$isReviewed',NOW())") or die(mysql_error());
        //            if ($insert)
        //            {
        //                $result = mysql_query("SELECT * FROM levelinfo WHERE username = '$username'") or die(mysql_error());
        //                if ($result)
        //                {
        //                    return mysql_fetch_array($result);
        //
        //                }else
        //                {
        //                    return false;
        //                }
        //            }else
        //            {
        //                return false;
        //            }
        //
        //
        //        }
        //    }
        //
        /**
         * get Reviews
         * returns Reviews
         */
        
        
        public function fetchAllReviews($reviewStatus) {
            
            $result = mysql_query("SELECT * FROM userinfo WHERE isReviewed = '$reviewStatus'") or die(mysql_error());
            // check for result
            $no_of_rows = mysql_num_rows($result);
            if ($no_of_rows > 0) {
                return $result;
            }else {
                // user not found
                return false;
            }
        }
        
        
        public function storeGameAccount($gameName,$password)
        {
            
            $userResult = mysql_query("SELECT * FROM gameaccountinfo WHERE username = '$gameName'") or die(mysql_error());
            
            $no_of_rows = mysql_num_rows($userResult);
            
            if ($no_of_rows > 0) {
                
                $update = mysql_query("update gameaccountinfo set password = '$password' where username = '$gameName'") or die(mysql_error());
                
                
            } else {
                
                $insert = mysql_query("INSERT INTO gameaccountinfo(username, password) VALUES('$gameName', '$password')") or die(mysql_error());
            }
        }
        
        
        public function submitUserLevel($username,$password,$age,$gender,$isReviewed,$gameID,$gameName,$JJCinfo,$TTinfo,$MJinfo)
        {
            $email = "123@123.com";
            $updateUserinfo = mysql_query("INSERT INTO userinfo(unique_id,email, password, age, sex, isReviewed, gameID, gameName, created_at) VALUES ('$username', '$email', '$password','$age', '$gender', '$isReviewed', '$gameID' , '$gameName',NOW())") or die(mysql_error());
            
            
            
            
            if($updateUserinfo)
            {
                
                $this->updateJJCLevel($username,$JJCinfo);
                $this->updateTTLevel($username,$TTinfo);
                $this->updateMJLevel($username,$MJinfo);
                
                
                $result = mysql_query("SELECT * FROM userinfo u left join JJCinfo j on j.JJCusername = u.unique_id left join TTinfo t on t.TTusername = u.unique_id left join MJinfo m on m.MJusername = u.unique_id WHERE unique_id = '$username'") or die(mysql_error());
                // check for result
                $no_of_rows = mysql_num_rows($result);
                if ($no_of_rows > 0) {
                    $result = mysql_fetch_array($result);
                    return $result;
                }else {
                    // user not found
                    return $result;
                }
                
                
                
            }else
            {
                return false;
            }
            
            
            
        }
        
        
        public function updateUserLevel($username,$isReviewed,$gameID,$gameName,$password,$JJCinfo,$TTinfo,$MJinfo)
        {
            
            
            $updateUserinfo = mysql_query("update userinfo set isReviewed ='$isReviewed',gameID = '$gameID', gameName = '$gameName' where unique_id = '$username'") or die(mysql_error());
            
            
            $this->storeGameAccount($gameName,$password);
            
            if($updateUserinfo)
            {
                
                $this->updateJJCLevel($username,$JJCinfo);
                $this->updateTTLevel($username,$TTinfo);
                $this->updateMJLevel($username,$MJinfo);
                
                
                $result = mysql_query("SELECT * FROM userinfo u left join JJCinfo j on j.JJCusername = u.unique_id left join TTinfo t on t.TTusername = u.unique_id left join MJinfo m on m.MJusername = u.unique_id WHERE unique_id = '$username'") or die(mysql_error());
                // check for result
                $no_of_rows = mysql_num_rows($result);
                if ($no_of_rows > 0) {
                    $result = mysql_fetch_array($result);
                    return $result;
                }else {
                    // user not found
                    return $result;
                }
                
                
                
            }else
            {
                return false;
            }
            
            
            
        }
        
        
        public function updateJJCLevel($username,$JJCinfo) {
            
            $result = mysql_query("SELECT * FROM JJCinfo WHERE JJCusername = '$username'") or die(mysql_error());
            $no_of_rows = mysql_num_rows($result);
            if ($no_of_rows > 0) {
                
                $JJCHaveScore = $JJCinfo["haveScore"];
                
                
                if ($JJCHaveScore == "yes")
                {
                    $JJCscore = $JJCinfo["JJCscore"];
                    $JJCtotal = $JJCinfo["JJCtotal"];
                    $JJCoffline = $JJCinfo["JJCoffline"];
                    $JJCmvp = $JJCinfo["JJCmvp"];
                    $JJCPianJiang = $JJCinfo["JJCPianJiang"];
                    $JJCPoDi = $JJCinfo["JJCPoDi"];
                    $JJCPoJun = $JJCinfo["JJCPoJun"];
                    $JJCYingHun = $JJCinfo["JJCYingHun"];
                    $JJCBuWang = $JJCinfo["JJCBuWang"];
                    $JJCFuHao = $JJCinfo["JJCFuHao"];
                    $JJCDoubleKill = $JJCinfo["JJCDoubleKill"];
                    $JJCTripleKill = $JJCinfo["JJCTripleKill"];
                    $JJCWinRatio = $JJCinfo["JJCWinRatio"];
                    $JJCheroFirst = $JJCinfo["JJCheroFirst"];
                    $JJCheroSecond = $JJCinfo["JJCheroSecond"];
                    $JJCheroThird = $JJCinfo["JJCheroThird"];
                    
                    
                    $update = mysql_query("update JJCinfo set JJCscore = '$JJCscore', JJCtotal = '$JJCtotal', JJCoffline = '$JJCoffline',JJCmvp = '$JJCmvp', JJCPianJiang = '$JJCPianJiang', JJCPoDi = '$JJCPoDi', JJCPoJun = '$JJCPoJun' ,JJCYingHun = '$JJCYingHun',JJCBuWang = '$JJCBuWang', JJCFuHao = '$JJCFuHao', JJCDoubleKill = '$JJCDoubleKill', JJCTripleKill = '$JJCTripleKill', JJCWinRatio = '$JJCWinRatio', JJCheroFirst = '$JJCheroFirst' ,JJCheroSecond = '$JJCheroSecond', JJCheroThird = '$JJCheroThird', JJCcreated_Time = NOW() where JJCusername = '$username'") or die(mysql_error());
                    
                }
                
            }else
            {
                $JJCHaveScore = $JJCinfo["haveScore"];
                
                
                if ($JJCHaveScore == "yes")
                {
                    $JJCscore = $JJCinfo["JJCscore"];
                    $JJCtotal = $JJCinfo["JJCtotal"];
                    $JJCmvp = $JJCinfo["JJCmvp"];
                    $JJCPianJiang = $JJCinfo["JJCPianJiang"];
                    $JJCPoDi = $JJCinfo["JJCPoDi"];
                    $JJCPoJun = $JJCinfo["JJCPoJun"];
                    $JJCYingHun = $JJCinfo["JJCYingHun"];
                    $JJCBuWang = $JJCinfo["JJCBuWang"];
                    $JJCFuHao = $JJCinfo["JJCFuHao"];
                    $JJCDoubleKill = $JJCinfo["JJCDoubleKill"];
                    $JJCTripleKill = $JJCinfo["JJCTripleKill"];
                    $JJCWinRatio = $JJCinfo["JJCWinRatio"];
                    $JJCheroFirst = $JJCinfo["JJCheroFirst"];
                    $JJCheroSecond = $JJCinfo["JJCheroSecond"];
                    $JJCheroThird = $JJCinfo["JJCheroThird"];
                    
                    
                    $insert = mysql_query("INSERT INTO JJCinfo(JJCusername,JJCscore, JJCtotal, JJCmvp, JJCPianJiang, JJCPoDi, JJCPoJun, JJCYingHun, JJCBuWang, JJCFuHao, JJCDoubleKill, JJCTripleKill, JJCWinRatio, JJCheroFirst, JJCheroSecond, JJCheroThird, JJCcreated_Time) VALUES ('$username', '$JJCscore', '$JJCtotal','$JJCmvp', '$JJCPianJiang', '$JJCPoDi', '$JJCPoJun' , '$JJCYingHun', '$JJCBuWang', '$JJCFuHao', '$JJCDoubleKill', '$JJCTripleKill', '$JJCWinRatio','$JJCheroFirst' ,'$JJCheroSecond','$JJCheroThird',NOW())") or die(mysql_error());
                    
                }
                
                
            }
            
        }
        
        
        
        public function updateTTLevel($username,$TTinfo) {
            
            $result = mysql_query("SELECT * FROM TTinfo WHERE TTusername = '$username'") or die(mysql_error());
            $no_of_rows = mysql_num_rows($result);
            if ($no_of_rows > 0) {
                
                $TTHaveScore = $TTinfo["haveScore"];
                
                
                if ($TTHaveScore == "yes")
                {
                    $TTscore = $TTinfo["TTscore"];
                    $TTtotal = $TTinfo["TTtotal"];
                    $TTmvp = $TTinfo["TTmvp"];
                    $TTPianJiang = $TTinfo["TTPianJiang"];
                    $TTPoDi = $TTinfo["TTPoDi"];
                    $TTPoJun = $TTinfo["TTPoJun"];
                    $TTYingHun = $TTinfo["TTYingHun"];
                    $TTBuWang = $TTinfo["TTBuWang"];
                    $TTFuHao = $TTinfo["TTFuHao"];
                    $TTDoubleKill = $TTinfo["TTDoubleKill"];
                    $TTTripleKill = $TTinfo["TTTripleKill"];
                    $TTWinRatio = $TTinfo["TTWinRatio"];
                    $TTheroFirst = $TTinfo["TTheroFirst"];
                    $TTheroSecond = $TTinfo["TTheroSecond"];
                    $TTheroThird = $TTinfo["TTheroThird"];
                    
                    
                    $update = mysql_query("update TTinfo set TTscore = '$TTscore', TTtotal = '$TTtotal', TTmvp = '$TTmvp', TTPianJiang = '$TTPianJiang', TTPoDi = '$TTPoDi', TTPoJun = '$TTPoJun' ,TTYingHun = '$TTYingHun',TTBuWang = '$TTBuWang', TTFuHao = '$TTFuHao', TTDoubleKill = '$TTDoubleKill', TTTripleKill = '$TTTripleKill', TTWinRatio = '$TTWinRatio', TTheroFirst = '$TTheroFirst' ,TTheroSecond = '$TTheroSecond', TTheroThird = '$TTheroThird', TTcreated_Time = NOW() where TTusername = '$username'") or die(mysql_error());
                    
                }
                //
            }else
            {
                $TTHaveScore = $TTinfo["haveScore"];
                
                if ($TTHaveScore == "yes")
                {
                    $TTscore = $TTinfo["TTscore"];
                    $TTtotal = $TTinfo["TTtotal"];
                    $TTmvp = $TTinfo["TTmvp"];
                    $TTPianJiang = $TTinfo["TTPianJiang"];
                    $TTPoDi = $TTinfo["TTPoDi"];
                    $TTPoJun = $TTinfo["TTPoJun"];
                    $TTYingHun = $TTinfo["TTYingHun"];
                    $TTBuWang = $TTinfo["TTBuWang"];
                    $TTFuHao = $TTinfo["TTFuHao"];
                    $TTDoubleKill = $TTinfo["TTDoubleKill"];
                    $TTTripleKill = $TTinfo["TTTripleKill"];
                    $TTWinRatio = $TTinfo["TTWinRatio"];
                    $TTheroFirst = $TTinfo["TTheroFirst"];
                    $TTheroSecond = $TTinfo["TTheroSecond"];
                    $TTheroThird = $TTinfo["TTheroThird"];
                    //
                    
                    //
                    
                    $insert = mysql_query("INSERT INTO TTinfo(TTusername, TTscore, TTtotal, TTmvp, TTPianJiang, TTPoDi, TTPoJun, TTYingHun, TTBuWang, TTFuHao, TTDoubleKill, TTTripleKill, TTWinRatio, TTheroFirst, TTheroSecond, TTheroThird, TTcreated_Time) VALUES ('$username','$TTscore', '$TTtotal','$TTmvp', '$TTPianJiang', '$TTPoDi', '$TTPoJun' , '$TTYingHun', '$TTBuWang', '$TTFuHao', '$TTDoubleKill', '$TTTripleKill', '$TTWinRatio','$TTheroFirst' ,'$TTheroSecond','$TTheroThird',NOW())") or die(mysql_error());
                    
                }
                
                
            }
            
        }
        //
        public function updateMJLevel($username,$MJinfo) {
            
            $result = mysql_query("SELECT * FROM MJinfo WHERE MJusername = '$username'") or die(mysql_error());
            $no_of_rows = mysql_num_rows($result);
            if ($no_of_rows > 0) {
                
                $MJHaveScore = $MJinfo["haveScore"];
                
                
                if ($MJHaveScore == "yes")
                {
                    $JJCscore = $MJinfo["MJscore"];
                    $JJCtotal = $MJinfo["MJtotal"];
                    $JJCmvp = $MJinfo["MJmvp"];
                    $JJCPianJiang = $MJinfo["MJPianJiang"];
                    $JJCPoDi = $MJinfo["MJPoDi"];
                    $JJCPoJun = $MJinfo["MJPoJun"];
                    $JJCYingHun = $MJinfo["MJYingHun"];
                    $JJCBuWang = $MJinfo["MJBuWang"];
                    $JJCFuHao = $MJinfo["MJFuHao"];
                    $JJCDoubleKill = $MJinfo["MJDoubleKill"];
                    $JJCTripleKill = $MJinfo["MJTripleKill"];
                    $JJCWinRatio = $MJinfo["MJWinRatio"];
                    $JJCheroFirst = $MJinfo["MJheroFirst"];
                    $JJCheroSecond = $MJinfo["MJheroSecond"];
                    $JJCheroThird = $MJinfo["MJheroThird"];
                    
                    
                    $update = mysql_query("update MJinfo set MJscore = '$JJCscore', MJtotal = '$JJCtotal', MJmvp = '$JJCmvp', MJPianJiang = '$JJCPianJiang', MJPoDi = '$JJCPoDi', MJPoJun = '$JJCPoJun' ,MJYingHun = '$JJCYingHun',MJBuWang = '$JJCBuWang', MJFuHao = '$JJCFuHao', MJDoubleKill = '$JJCDoubleKill', MJTripleKill = '$JJCTripleKill', MJWinRatio = '$JJCWinRatio', MJheroFirst = '$JJCheroFirst' ,MJheroSecond = '$JJCheroSecond', MJheroThird = '$JJCheroThird', MJcreated_Time = NOW() where MJusername = '$username'") or die(mysql_error());
                    
                }
                
            }else
            {
                $MJHaveScore = $MJinfo["haveScore"];
                
                
                if ($MJHaveScore == "yes")
                {
                    $JJCscore = $MJinfo["MJscore"];
                    $JJCtotal = $MJinfo["MJtotal"];
                    $JJCmvp = $MJinfo["MJmvp"];
                    $JJCPianJiang = $MJinfo["MJPianJiang"];
                    $JJCPoDi = $MJinfo["MJPoDi"];
                    $JJCPoJun = $MJinfo["MJPoJun"];
                    $JJCYingHun = $MJinfo["MJYingHun"];
                    $JJCBuWang = $MJinfo["MJBuWang"];
                    $JJCFuHao = $MJinfo["MJFuHao"];
                    $JJCDoubleKill = $MJinfo["MJDoubleKill"];
                    $JJCTripleKill = $MJinfo["MJTripleKill"];
                    $JJCWinRatio = $MJinfo["MJWinRatio"];
                    $JJCheroFirst = $MJinfo["MJheroFirst"];
                    $JJCheroSecond = $MJinfo["MJheroSecond"];
                    $JJCheroThird = $MJinfo["MJheroThird"];
                    
                    
                    
                    $insert = mysql_query("INSERT INTO MJinfo(MJusername, MJscore, MJtotal, MJmvp, MJPianJiang, MJPoDi, MJPoJun, MJYingHun, MJBuWang, MJFuHao, MJDoubleKill, MJTripleKill, MJWinRatio, MJheroFirst, MJheroSecond, MJheroThird, MJcreated_Time) VALUES ('$username','$JJCscore', '$JJCtotal','$JJCmvp', '$JJCPianJiang', '$JJCPoDi', '$JJCPoJun' , '$JJCYingHun', '$JJCBuWang', '$JJCFuHao', '$JJCDoubleKill', '$JJCTripleKill', '$JJCWinRatio','$JJCheroFirst' ,'$JJCheroSecond','$JJCheroThird',NOW())") or die(mysql_error());
                    
                }
                
                
            }
            
        }
        //
        //    /**
        //     * Storing new note
        //     * returns visitor note
        //     */
        public function storeNote($content,$username,$visitor) {
            
            $result = mysql_query("INSERT INTO noteinfo(username, visitor, note_content,createdAt) VALUES('$username', '$visitor', '$content', NOW())") or die(mysql_error());
            // check for successful store
            if ($result) {
                // get user details
                $finalResult = mysql_query("SELECT * FROM noteinfo WHERE username = '$username' ORDER BY createdAt DESC");
                // return user details
                return $finalResult;
            } else {
                return $result;
            }
        }
        
        /**
         * Storing new note
         * returns visitor note
         */
        public function fetchNotes($username) {
            
            $finalResult = mysql_query("SELECT * FROM noteinfo WHERE username = '$username' ORDER BY createdAt DESC");
            // return user details
            $no_of_rows = mysql_num_rows($finalResult);
            
            if ($no_of_rows > 0) {
                return $finalResult;
            }else {
                // user not found
                return false;
            }
            
        }
        
        
        
        
        
    }
    
    ?>
