<?php

define('LEVEL_ERROR', 100);
define('LEVEL_INFO', 50);
define('LEVEL_TRACE', 10);
require("dbaseConfig.php");

class Server {
   var $loglevel = LEVEL_ERROR;
   var $mysql;         //mysqli object
   var $fp;            //logging file pointer
   var $comm;          //request data $_POST or $_GET

   function Server() {
        $this->fp = fopen("../log/log.txt","a");
        $this->mysql = connect_to_db($this->fp);
        if(!$this->mysql) $error=true;

        //post or get?
        if ( !empty($_POST) ){
            $this->comm = $_POST;
        } else {
            $this->comm = $_GET;
        }
    }

    //execute task. For specific tasks, override executeImpl()
    function execute() {
        $error = false;
        $res = $this->executeImpl(); //perform actual task (overridden in subclasses)
        if(!$res) $error = true;

        if($this->mysql) $this->mysql->close();

        if($error) {
           $res = '({"success":"false","total":"0", "results":""})';
        }
        if($res!=null) echo $res;
        fclose($this->fp);
    }

    //specific task implementation. Return false on failure, some string on success
    function executeImpl() {
        die("not implemented");
    }

    //check login credentials.
    //returns: true is login succeeded, false otherwise
    function login() {
       if($this->loglevel<=LEVEL_TRACE) {
          $this->trace(LEVEL_TRACE, "Entering login");
       }
       if( isset($this->comm['username']) && isset($this->comm['passwd']) ) {
           $username = $this->comm['username'];
           $passwd = $this->comm['passwd'];

           $sql = $this->mysql->query("SELECT password FROM user WHERE name='$username'");
           if (!$sql) {
               $this->trace(LEVEL_ERROR,"Could not successfully run query ($sql) from DB: " . $this->mysql->error);
               return false;
           }

           $nbrows = $sql->num_rows;
           $valid = false;
           if($nbrows==1){
               $rec = $sql->fetch_assoc();
               if($rec['password']==$passwd) {
                  $valid = true;
               } else {
                  if($this->loglevel<=LEVEL_INFO) $this->trace(LEVEL_INFO, "Invalid login with username $username");
               }
           }

           if($sql) $sql->free();

           if($this->loglevel<=LEVEL_TRACE) {
              if($valid)
                 $this->trace(LEVEL_TRACE, " -- success");
              else
                 $this->trace(LEVEL_TRACE, " -- FAILED");
           }

           return $valid;
       } else {
           $this->trace(LEVEL_ERROR, "no username and/or password supplied");
           return false;
       }
    }

    function log($msg) {
       if($this->fp) {
          fwrite($this->fp, $msg."\n");
       }
    }

    function trace($level, $msg) {
        if($level>=$this->loglevel && $this->fp!=null) {
            $logline = date('l jS \of F Y h:i:s A',$_SERVER["REQUEST_TIME"]);
            switch($level) {
               case LEVEL_ERROR: fwrite($this->fp,$logline." ERROR: ".$msg."\n"); break;
               case LEVEL_INFO:  fwrite($this->fp,$logline." INFO:  ".$msg."\n"); break;
               case LEVEL_TRACE: fwrite($this->fp,$logline." TRACE: ".$msg."\n"); break;
               default: fwrite($this->fp,$logline.": Unknown loglevel in function Server::trace. Message: $msg\n");
            }
        }
    }
}



?>