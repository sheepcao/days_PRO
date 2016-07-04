<?php
    header('Content-type:text/html;charset=utf-8');
    
    
    //配置您申请的appkey
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
    
    public function getLuckInfo($name,$week) {
        $appkey = "91611110023647e3d0d736a8709c1729";

        
        $url = "http://web.juhe.cn:8080/constellation/getAll";
        $params = array(
                        "key" => $appkey,//应用APPKEY(应用详细页查询)
                        "consName" => $name,//星座名称，如:白羊座
                        "type" => $week,//运势类型：today,tomorrow,week,nextweek,month,year
                        );
        $paramstring = http_build_query($params);
        $opts = array('http'=>array('header' => "User-Agent:MyAgent/1.0\r\n"));
        $context = stream_context_create($opts);
        $jsonData = file_get_contents($url.'?'.$paramstring,false,$context);
        $json_result = json_decode($jsonData,true);

        $startTime = explode('-', $json_result['date'])[0];
        $endTime = explode('-', $json_result['date'])[1];
        
        
        $response["start_date"] = $startTime;
        $response["end_date"] = $endTime;
        $response["week"] = $json_result['weekth'];
        $tempLife = explode('健康：', $json_result['health'])[1];
        $response["life"] = str_replace("作者：马子晴","",$tempLife);
        $tempLife = explode('工作：', $json_result['work'])[1];
        $response["work"] = str_replace("作者：马子晴","",$tempLife);
        $response["name"] = $json_result['name'];
        
       $result = $this->saveDB($response["name"],$response["life"],$response["work"] ,$response["week"],$response["start_date"],$response["end_date"]);
        
//        $file_contents = file_get_content($url.'?'.$paramstring);
//        return($jsonData);

//        $content = juhecurl($url,$paramstring);

//        $json_result = json_decode($jsonData,true);
        if($result === "exsit")
        {
            return "exsit";
        }else
            if($result)
        {
            return $response;
        }else
        {
            return false;
        }

    }
    
    //**************************************************
    
    /**
     * 请求接口返回内容
     * @param  string $url [请求的URL地址]
     * @param  string $params [请求的参数]
     * @param  int $ipost [是否采用POST形式]
     * @return  string
     */
    function juhecurl($url,$params=false,$ispost=0){
        $httpInfo = array();
        $ch = curl_init();

        curl_setopt( $ch, CURLOPT_HTTP_VERSION , CURL_HTTP_VERSION_1_1 );
        curl_setopt( $ch, CURLOPT_USERAGENT , 'JuheData' );
        curl_setopt( $ch, CURLOPT_CONNECTTIMEOUT , 60 );
        curl_setopt( $ch, CURLOPT_TIMEOUT , 60);
        curl_setopt( $ch, CURLOPT_RETURNTRANSFER , true );
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
       

        if( $ispost )
        {
            curl_setopt( $ch , CURLOPT_POST , true );
            curl_setopt( $ch , CURLOPT_POSTFIELDS , $params );
            curl_setopt( $ch , CURLOPT_URL , $url );
        }
        else
        {
            if($params){
                curl_setopt( $ch , CURLOPT_URL , $url.'?'.$params );
            }else{
                curl_setopt( $ch , CURLOPT_URL , $url);
            }
        }
        $response = curl_exec( $ch );

        if ($response === FALSE) {
            //echo "cURL Error: " . curl_error($ch);
            return false;
        }
        $httpCode = curl_getinfo( $ch , CURLINFO_HTTP_CODE );
        $httpInfo = array_merge( $httpInfo , curl_getinfo( $ch ) );
        curl_close( $ch );
        return $response;
    }
    

    public function getTest($name) {
        $appkey = "91611110023647e3d0d736a8709c1729";

        return $appkey;

    }
    

    
    public function fetchConstellation($start_date) {
        $result = mysql_query("SELECT * FROM luckInfo WHERE start_date = '$start_date'") or die(mysql_error());
        // check for result
        $no_of_rows = mysql_num_rows($result);
        if ($no_of_rows > 0) {
//            $result = mysql_fetch_array($result);
            return $result;
        }else {
            
           $allConstellation = $this->latestConstellation();
            return $allConstellation;
        }
    }
    public function latestConstellation() {
        $result = mysql_query("SELECT * FROM luckInfo order by start_date desc LIMIT 12") or die(mysql_error());
        // check for result
        $no_of_rows = mysql_num_rows($result);
        if ($no_of_rows > 0) {
            //            $result = mysql_fetch_array($result);
            return $result;
        }else {
            // signature not found
            return false;
        }
    }

    /**
     * Get product info
     */
    public function saveDB($name,$life,$work,$week,$startDate,$endDate) {
        
        $result = mysql_query("SELECT * FROM luckInfo WHERE start_date = '$startDate' and name = '$name'") or die(mysql_error());
        $no_of_rows = mysql_num_rows($result);
        if ($no_of_rows > 0) {
            return "exist";
        }else {
            // user not found
            $updateUserinfo = mysql_query("INSERT INTO luckInfo(name,start_date,end_date,week,life,work) VALUES ('$name', '$startDate', '$endDate','$week', '$life','$work')") or die(mysql_error());
            if($updateUserinfo)
            {
                return true;
            }else
            {
                return false;
            }
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    /**
     * Storing new user
     * returns user details
     */
    public function storeUser($name,$password) {
        
        $result = mysql_query("INSERT INTO userinfo(unique_id, password,created_at) VALUES('$name', '$password', NOW())");
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
    /**
     * Get user by email and password
     */
    public function getUserByNameAndPassword($name, $password) {
        $result = mysql_query("SELECT * FROM userinfo u left join backupinfo b on backup_user = u.unique_id WHERE unique_id = '$name'") or die(mysql_error());
        // check for result
        $no_of_rows = mysql_num_rows($result);
        if ($no_of_rows > 0) {
            $result = mysql_fetch_array($result);
            $passwordInDB = $result['password'];
            
            // check for password equality
            if ($passwordInDB == $password) {
                // user authentication details are correct
                return $result;
            }else
            {
                return false;
            }
        } else {
            // user not found
            return false;
        }
    }
    
    public function getPassword($name)
    {
        $result = mysql_query("SELECT * FROM userinfo WHERE unique_id = '$name'") or die(mysql_error());
        $no_of_rows = mysql_num_rows($result);
        if ($no_of_rows > 0) {
            $result = mysql_fetch_array($result);
            $passwordInDB = $result['password'];
            return $passwordInDB;
        }else
        {
            return false;
        }
    }
    
    public function updateBackup($name,$device,$backupTime) {
        
        $select = mysql_query("SELECT * FROM backupinfo where backup_user = '$name'") or die(mysql_error());
        $no_of_rows = mysql_num_rows($select);
        if ($no_of_rows > 0) {
            //  existed
            
            $result = mysql_query("update backupinfo set backup_device = '$device',backup_day = '$backupTime' where backup_user = '$name'");
            // check for successful store
            if ($result) {
                // get user details
                $result = mysql_query("SELECT * FROM backupinfo where backup_user = '$name'") or die(mysql_error());
                // return user details
                return mysql_fetch_array($result);
            } else {
                return false;
            }
            
            
        } else {
            //  not existed
            $result = mysql_query("INSERT INTO backupinfo(backup_user,backup_device, backup_day) VALUES('$name','$device','$backupTime')");
            // check for successful store
            if ($result) {
                // get user details
                $result = mysql_query("SELECT * FROM backupinfo where backup_user = '$name'") or die(mysql_error());
                // return user details
                return mysql_fetch_array($result);
            } else {
                return false;
            }
            
        }
        
        
    }


    
    
}

?>
