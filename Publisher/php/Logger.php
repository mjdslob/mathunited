<?php
// Usage:
// http://www.mathunited.nl/testcontent/publisher/Publisher.php?user=mslob&passwd=test&cmd=publishThread&thread=ma-havovwo-1
define('LEVEL_ERROR', 100);
define('LEVEL_INFO', 50);
define('LEVEL_TRACE', 10);


class Logger {
   var $fp;            //logging file pointer
   var $level;
   
   function Logger($level, $repoID, $doClear) {
        date_default_timezone_set('Europe/Amsterdam');
        $this->level = $level;
        if($doClear){
            $this->fp = fopen("../logs/log_$repoID.txt","w");
        } else {
            if(!file_exists("../logs/log_$repoID.txt")) {
                $this->fp = fopen("../logs/log_$repoID.txt","w");
            }  else 
               $this->fp = fopen("../logs/log_$repoID.txt","a");
                    
        }
    }


    function log($msg) {
       if($this->fp) {
          fwrite($this->fp, $msg."\n");
       }
    }

    function trace($level, $msg) {
        if($level>=$this->level && $this->fp!=null) {
            switch($level) {
               case LEVEL_ERROR: 
                   $logline = '<div class="log-entry error">';
                   $logline = $logline.date('l jS \of F Y h:i:s A',$_SERVER["REQUEST_TIME"])." ERROR: $msg </div>";
                   fwrite($this->fp,$logline); 
                   error_log($logline." ERROR: ".$msg."\n",0);
                   break;
               case LEVEL_INFO:  
                   $logline = '<div class="log-entry info">';
                   $logline = $logline.date('l jS \of F Y h:i:s A',$_SERVER["REQUEST_TIME"])." INFO: $msg </div>";
                   fwrite($this->fp,$logline); 
                   error_log($logline." INFO: ".$msg."\n",0);
                   break;
               case LEVEL_TRACE: 
                   $logline = '<div class="log-entry trace">';
                   $logline = $logline.date('l jS \of F Y h:i:s A',$_SERVER["REQUEST_TIME"])." TRACE: $msg </div>";
                   fwrite($this->fp,$logline); 
                   error_log($logline." TRACE: ".$msg."\n",0);
                   break;
               default: fwrite($this->fp,$logline.": Unknown loglevel in function Server::trace. Message: $msg\n");
            }
        }
    }
}


?>