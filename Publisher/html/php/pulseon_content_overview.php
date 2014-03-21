<?php
// generates overview files:
// - components.xml to contain all components and subcomponents. Used for WiskundeMenu
// - for each component, a file index.xml, containing all numbered items

define('MAX_TIME_LIMIT',60);
define('TEMP_OVERVIEW_FILE', 'tmp/comps-assembled.xml');
require_once("Logger.php");
require_once("EntityConverter.php");

function handleError($errno, $errstr, $errfile, $errline, array $errcontext)
{
    // error was suppressed with the @-operator
    if (0 === error_reporting()) {
        return false;
    }

    throw new ErrorException($errstr, 0, $errno, $errfile, $errline);
}

set_error_handler('handleError');

class Overview {
    var $loglevel = LEVEL_INFO;
    var $logger;
    var $callback;      //not null if dynamic scripting callback is used
    var $comm;          //request data $_POST or $_GET
    var $config_contentRoot;
    
    function Overview() {
        header('Content-type: text/html');
        echo "<html><head><style>.component-div{margin:10px 0px;} .component-div a{display:block; margin-left:10px;}</style></head><body>";
try{
        include("Config.php");
        $this->config_contentRoot = $config_contentRoot;
        
        //post or get?
        $repoId = 'generic';
        $this->comm = $_GET;
        if( isset($this->comm['repo']) ) {
            $repoId = $this->comm['repo'];
            $this->repo = $config_repos[$repoId];
            $this->logger = new Logger($this->loglevel, $repoId, false);
        } else {
            throw new Exception('missing repo identifier');
        }

        $comps = array();
        $repo = $config_repos[$repoId];
        if(!$repo) {
            throw new Exception("Generate Index called with unknown repository $repoId".print_r($config_repos,true));
        }
        
        //read components
        $conts = file_get_contents($config_contentRoot.$this->repo['basePath'].'leerlijnen/components.xml');
        $conts = html_entity_decode($conts, ENT_QUOTES, "utf-8");
        $overview = new SimpleXMLElement($conts);
        
        
        //read thread
        $conts = file_get_contents($config_contentRoot.$this->repo['basePath'].'leerlijnen/threads.xml');
        $conts = html_entity_decode($conts, ENT_QUOTES, "utf-8");
        $doc = new SimpleXMLElement($conts);

        if( isset($this->comm['thread']) ) {
            $threadId = $this->comm['thread'];
        } else {
            echo "<h1>Leerlijnen</h1>";
            $threads = $doc->xpath("/threads/thread");
            foreach($threads as $thread) {
                echo "<a href='http://ontwikkel.scalamedia.nl/Publisher/php/pulseon_content_overview.php?repo=studiovo&thread=".$thread['id']."'>".$thread->title."</a></br/>";
            }
            return;
        }
        
        
        $refs = $doc->xpath("/threads/thread[@id='$threadId']/threadsequence/contentref");
        foreach($refs as $ref) {
            $compId = $ref['ref'];
            $comp = $overview->xpath("//component[@id='$compId']");
            $comp = $comp[0];
            echo "<div class='component-div'>".$comp->title."<br/>";
            $subcomplist = $comp->xpath('subcomponents/subcomponent');
            foreach($subcomplist as $subcomp) {
                $subcompId = $subcomp['id'];
                echo "<a href='http://ontwikkel.scalamedia.nl/MathUnited/view?repo=studiovo&variant=studiovo_pulseon&comp=$compId&subcomp=$subcompId'>".(string)$subcomp->title."</a>";
            }
            echo "</div>";
        }
        
        echo "</body></html>";
} catch(Exception $e) {
   echo "<div id='error-div'><h1>Failed</h1><p>A problem occurred while scanning the content. Please resolve this problem and retry.</p></p>".$e->getMessage()."</div></body></html>";
   $this->logger->trace(LEVEL_ERROR, $e->getMessage());
}        
    }


    //specific task implementation. Return false on failure, some string on success
    function executeImpl() {
        die("not implemented");
    }

}


$pub = new Overview();

?>