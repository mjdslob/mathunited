<?php
// Usage:
//
// http://mathunited.pragma-ade.nl:41080/Publisher/Publisher.php?user=mslob&passwd=test&cmd=publishThread&repo=ma&target=mathunited&thread=ma-test

//http://www.mathunited.nl/testcontent/publisher/Publisher.php?user=mslob&passwd=test&cmd=publishThread&target=threeships&thread=wm-havovwo-1
//// http://www.mathunited.nl/testcontent/publisher/Publisher.php?user=mslob&passwd=test&cmd=publishThread&target=mathunited&thread=ts_test
// http://www.mathunited.nl/testcontent/publisher/Publisher.php?user=mslob&passwd=test&cmd=publishThread&target=threeships&thread=ma-havovwo-12
// http://www.mathunited.nl/testcontent/publisher/logs/log.txt
//define('COMPONENTS_FILE', '/data/content-overview/components.xml');
define('MAX_TIME_LIMIT',60);
require_once("platforms/Platform.php");
require_once("platforms/ThreeShipsPlatform.php");
require_once("platforms/GAEPlatform.php");
require_once("platforms/PulseOnPlatform.php");
require_once("Logger.php");


class Publisher {
   var $loglevel = LEVEL_INFO;
   var $repoID;
   var $logger;
   var $callback;      //not null if dynamic scripting callback is used
   var $comm;          //request data $_POST or $_GET
   function Publisher() {
//       header('Content-type: text/html');
        //post or get?
        $curdir = getcwd();
        $clear_busy_file = false; //whether to set the status of Publisher to 'idle' after this call
        $statusFile = 'not_set_yet';
        $this->comm = $_POST;
        $this->repoID = 'generic';
        if( isset($this->comm['repo']) ) {
            $this->repoID = $this->comm['repo'];
        }

        include("Config.php");
        $this->logger = new Logger($this->loglevel, $this->repoID, false);
        try{

            if( isset($this->comm['cmd']) ) {
                $cmd = $this->comm['cmd'];
            } else throw new Exception('No command supplied');

            if(!$this->login()) throw new Exception('Login failed');

            if( isset($this->comm['target']) ) {
                $targetID = $this->comm['target'];
            } else {
                $targetID = "all";
            }

            $baseURL = false;
            if( isset($this->comm['repo']) ) {
                $this->repoID = $this->comm['repo'];
            } else throw new Exception('repo attribute is missing');

            $this->repo = Config::getRepoConfig($this->repoID);
            $baseURL = $this->repo['basePath'];;
            if(!$baseURL) throw new Exception('repo attribute is invalid');

            //check if Publisher is not busy already
            $statusFile = "../logs/status_".$this->repoID.".xml";
            $statusDoc = file_get_contents($statusFile);
            if($statusDoc!==false) {
                $xml = new SimpleXMLElement($statusDoc);
                $statusElm = $xml->xpath("//status");
                if($statusElm && count($statusElm)>0) {
                    $status = (string)$statusElm[0];
                    if(strcmp($status,'busy')==0) throw new Exception('Publisher is busy');
                }
            }
            $statusFp = fopen($statusFile,"w");
            fwrite($statusFp,"<publisher><status>busy</status></publisher>"); 
            fclose($statusFp);
            $clear_busy_file = true;

            $result="{success:true, msg:\"Nothing done\"}";
            switch($cmd) {
                case "publishOverview":
                    $result = $this->publishOverview();
                    $this->logger->trace(LEVEL_INFO, "Finished publishing overview");
                    break;
                    
                case "publishComponentFile":
                    if( isset($this->comm['compId']) ) {
                        $compId = $this->comm['compId'];
                    } else throw new Exception('No component id given');
                    if( isset($this->comm['compRef']) ) {
                        $compRef = $this->comm['compRef'];
                    } else throw new Exception('No component filename given');

                    $this->publishComponentFile($targetID, $compId, $compRef, $this->repoID);
                    $this->logger->trace(LEVEL_INFO, "Finished publishing component file $compId");
                    break;
                    
                case "publishSubcomponent":
                    if( isset($this->comm['subcompId']) ) {
                        $subcompId = $this->comm['subcompId'];
                    } else throw new Exception('No subcomponent id given');
                    if( isset($this->comm['compId']) ) {
                        $compId = $this->comm['compId'];
                    } else throw new Exception('No component id given');
                    if( isset($this->comm['compRef']) ) {
                        $compRef = $this->comm['compRef'];
                    } else throw new Exception('No component filename given');
                    if( isset($this->comm['subcompRef']) ) {
                        $subCompRef = $this->comm['subcompRef'];
                    } else throw new Exception('No subcomponent filename given');

                    $this->publishSubcomponent($targetID, $subcompId, $compId, $subCompRef, $compRef, $this->repoID);
                    $this->logger->trace(LEVEL_INFO, "Finished publishing subcomponent $subcompId");
                    break;
                    
                case "publishThread":
                    if( isset($this->comm['thread']) ) {
                        $threadID = $this->comm['thread'];
                    } else throw new Exception('No thread id given');

                    $this->publishThread($threadID, $targetID, $this->repo, false);
                    $this->logger->trace(LEVEL_INFO, "Finished publishing thread $threadID");
                    break;
                case "uploadQTISubcomponent":
                    if( isset($this->comm['id']) ) {
                        $subcompId = $this->comm['id'];
                    } else throw new Exception('No subcomponent id given');
                    if( isset($this->comm['compId']) ) {
                        $compId = $this->comm['compId'];
                    } else throw new Exception('No component id given');
                    if( isset($this->comm['ref']) ) {
                        $compRef = $this->comm['ref'];
                    } else throw new Exception('No component ref given');

                    $this->uploadQTIComponent($targetID, $subcompId, $compId, $compRef, $this->repoID);
                    $this->logger->trace(LEVEL_INFO, "Finished uploading QTI subcomponent $subcompId");
                    break;
            }  
            $statusFp = fopen($statusFile,"w");
            fwrite($statusFp,"<publisher><status>idle</status></publisher>"); 
            fclose($statusFp);
            return "{success: true, msg:\"succeeded\"}";;
        } catch(Exception $e) {
            $msg = $e->getMessage();
            $this->logger->trace(LEVEL_ERROR, $msg);
            if($clear_busy_file){
                chdir($curdir);
                $statusFp = fopen($statusFile,"w");
                fwrite($statusFp,"<publisher><status>idle</status></publisher>"); 
                fclose($statusFp);
            }
            return "{success: false, msg:\"$msg\"}";
        }
    }
    
    function publishOverview(){ 
        //generate an id for this publish
        $publishId = date(DATE_RFC822);
        $pf = new GAEPlatform($publishId, false);
        $pf->publishOverview($this->repoID, $this->repo, $this->logger,  $this->repo['basePath']);
        return $result;
    }

    //execute task. For specific tasks, override executeImpl()
    function uploadQTIComponent($targetID, $subcompId, $compId, $compRef, $compRepo) {
        //generate an id for this publish
        $publishId = date(DATE_RFC822);
        
        switch($targetID){
            case "pulseon": $pf = new PulseOnPlatform($publishId, false); break;
            default:
                throw new Exception("Unknown target ID: $targetID");
                break;
        }
        
        $comp = array();
        $comp['method']=$compRepo;
        $comp['compId']=$compId;
        $comp['id']=$subcompId;
        $comp['ref']=$compRef;
        $comp['fname']=$this->repo['basePath'].$compRef;
        $pf->uploadQTIComponent($comp, "", $this->logger);
    }

    function publishComponentFile($targetID, $compId, $compRef, $compRepo) {
        //generate an id for this publish
        $publishId = date(DATE_RFC822);
        
        switch($targetID){
            case "threeships":$pf = new ThreeShipsPlatform($publishId, false); break;
            case "mathunited":$pf = new GAEPlatform($publishId); break;
            default:
                throw new Exception('Unknown target ID');
                break;
        }
        $pf->publishComponentFile($compId, $compRef, $this->repo['basePath'], $compRepo, $this->logger);
    }
    
    function publishSubcomponent($targetID, $subcompId, $compId, $subcompRef, $compRef, $compRepo) {
        //generate an id for this publish
        $publishId = date(DATE_RFC822);
        
        switch($targetID){
            case "threeships":$pf = new ThreeShipsPlatform($publishId, false); break;
            case "mathunited":$pf = new GAEPlatform($publishId); break;
            default:
                throw new Exception('Unknown target ID');
                break;
        }
        
        $comp = array();
        $comp['method']=$compRepo;
        $comp['compId']=$compId;
        $comp['compRef']=$compRef;
        $comp['subcompId']=$subcompId;
        $comp['subcompRef']=$subcompRef;
        $comp['pathbase']=$this->repo['basePath'];
        $pf->publishSubcomponent($comp, "", $this->logger);
    }

    //execute task. For specific tasks, override executeImpl()
    function publishThread($threadID, $targetID, $repo, $doDemo) {
        //generate an id for this publish
        $publishId = date(DATE_RFC822);
        
        //read threads xml
        $baseURL = $repo['basePath'];
        $threadsXMLstr = file_get_contents($baseURL.'leerlijnen/threads.xml');
        $threads = new SimpleXMLElement($threadsXMLstr);
        $compids = array();
        
        foreach ($threads->xpath("/threads/thread[@id=\"$threadID\"]//contentref") as $ref) {
            $compids[] = array( 'ref' => (string)$ref['ref'],
                                'method' => (string)$ref['method']);
        }
        if(count($compids)==0)  throw new Exception("Thread $threadID does not contain any components");
        
        $compFiles = array();
        $compsXMLstr = file_get_contents($baseURL.'leerlijnen/components.xml');
        $comps = new SimpleXMLElement($compsXMLstr);

        foreach($compids as $cc) {
            $ref = $cc['ref'];
            $compDef  = $comps->xpath("/mathunited/methods/method/components/component[@id=\"$ref\"]");
            if($compDef && count($compDef)>0){
                $compDef = $compDef[0];
                $title = $compDef->title;
                $title = (string)$title[0];
                $subcomps = $compDef->xpath("subcomponents/subcomponent");
                foreach($subcomps as $sc) {
                    $subTitle = $sc->title;
                    $subTitle = (string)$subTitle[0];
                    $sref = $sc->file;
                    $sref = (string)$sref[0];
                    $sid = (string)$sc['id'];
                    $compFiles[] = array('compId'=>$ref,
                                        'fname' => $this->repo['basePath'].$sref,
                                        'ref' => $sref,
                                        'id'  => $sid,
                                        'method' => $repo['id'],
                                        'title' =>$title.' - '.$subTitle);
                }
            }
        }
        
        switch($targetID){
            case "threeships":$tspf = new ThreeShipsPlatform($publishId, $doDemo); break;
            case "mathunited":$tspf = new GAEPlatform($publishId); break;
            default:
                throw new Exception('Unknown target ID');
                break;
        }
        
        set_time_limit(0);  //prevent timeout
        foreach($compFiles as $cf) {
            $tspf->publishComponent($cf, $threadID, $this->logger);
        }

        $tspf->postPublish();
    }


    //specific task implementation. Return false on failure, some string on success
    function executeImpl() {
        die("not implemented");
    }

    //check login credentials.
    //returns: true if login succeeded, false otherwise
    function login() {
        $error = false;
        if( isset($this->comm['user'] )) {
           $username = $this->comm['user'];
           if($this->loglevel<=LEVEL_TRACE) {
              $this->logger->trace(LEVEL_TRACE, "-- user = $username");
           }
        } else {
           $error = true;
           $this->logger->trace(LEVEL_ERROR, "No user name supplied");
        }
        if( isset($this->comm['passwd'] )) {
           $passwd = $this->comm['passwd'];
        } else {
           $error = true;
           $this->logger->trace(LEVEL_ERROR, "No password supplied");
        }

        if(!$error &&
            (     (strcmp($username,'mslob')==0 && strcmp($passwd,'test')==0)
            )
          ) {
           $res = true;
        } else {
           $res = false;
        }
        return $res;
    }

}


$pub = new Publisher();

?>