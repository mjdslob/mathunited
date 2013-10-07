<?php
// generates overview files:
// - components.xml to contain all components and subcomponents. Used for WiskundeMenu
// - for each component, a file index.xml, containing all numbered items

define('COMPONENTS_FILE', '/data/content-overview/components.xml');
define('MAX_TIME_LIMIT',60);
define('TEMP_OVERVIEW_FILE', 'tmp/comps-assembled.xml');
define('BASEPATH','/data/');
require_once("Logger.php");
require_once("EntityConverter.php");


class Overview {
    var $loglevel = LEVEL_INFO;
    var $logger;
    var $callback;      //not null if dynamic scripting callback is used
    var $comm;          //request data $_POST or $_GET

    private $paths_ma = array(
          'content-ma/concept/ha/',
          'content-ma/concept/hb/',
          'content-ma/concept/hv/',
          'content-ma/concept/h3/',
          'content-ma/concept/v3/',
          'content-ma/concept/vb/vb-bb1/',
          'content-ma/concept/vb/vb-bb2/'
        );
    private $paths_wm = array(
          'content-wm/concept/lj1-hv/',
          'content-wm/concept/lj2-h/',
          'content-wm/concept/lj2-v/',
          'content-wm/concept/lj3-h/',
          'content-wm/concept/lj3-v/'
        );
    private $paths_studiovo = array(
          'content-studiovo/concept/ak-water/',
        );

    private $index_xsl = array(
          'ma'=>'xslt/generate-index-ma.xslt',
          'wm'=>'xslt/generate-index-wm.xslt'
        );
    
    function Overview() {
        header('Content-type: text/html');
        //post or get?
        if ( !empty($_POST) ){
            $this->comm = $_POST;
            $this->callback = null;
        } else {
            $this->comm = $_GET;
            if(isset($_GET['callback'])){
               $this->callback = $_GET['callback'];
            }
        }
        if( isset($this->comm['cmd']) ) {
            $cmd = $this->comm['cmd'];
        } else $cmd = false;

        $this->logger = new Logger($this->loglevel, false);
try{
        //scan for components
        $comps = array();
        for($kk=0; $kk<count($this->paths_ma); $kk++) {
           $cc=$this->findComponents('/data/', $this->paths_ma[$kk], "ma", 0);
           $comps = array_merge($comps, $cc);
        }

        $this->search($comps);

        echo "<html><head></head><body><h1>Geslaagd</h1></body></html>";
} catch(Exception $e) {
   echo "<html><head></head><body><h1>Fout opgetreden</h1></body></html>";
   $this->logger->trace(LEVEL_ERROR, $e->getMessage());
}        
    }


    //specific task implementation. Return false on failure, some string on success
    function executeImpl() {
        die("not implemented");
    }

    
    function search($comps) {
        $error = false;
        foreach($comps as $cc) {
             $fullName = $cc["fullname"];
            echo "Investigating ".$fullName."<br/>";
             //create base path
             $ind = strrpos($fullName, '/');
             $base = '';
             if($ind > 0) {
                 $base = substr($fullName, 0, $ind+1);
             }
             $txt = file_get_contents($fullName);
             $txt = EntityConverter::convert_entities($txt);
             try{
                $main = new SimpleXMLElement($txt);

                $sc = $main->xpath("//subcomponent");
                foreach($sc as $elm) {
                    $elmId = (string)($elm->file);
                    $fname = $base.$elmId;
                    $txt = file_get_contents($fname);
                    if($txt===false) {
                        echo "File $fname does not exist";
                        $error = true;
                    } else {
                        $txt = EntityConverter::convert_entities($txt);
                        $doc = new SimpleXMLElement($txt);

                        
//=========SEARCH                        
                        $node = $doc->xpath("//extra[count(include)>1]");
                        if(count($node)>0) {
                            echo "Matching file: ".$fname." count=".count($node)."<br/>";
                        }
//=========SEARCH                        
                        
                        
                    }
                    if($error) break;
                }
                 
                 
             } catch(Exception $e) {
                echo "ERROR: When analyzing $fullName: ".$e->getMessage();
             }
        }
    }

    function addComponent($cc, $parent) {
         $conts = file_get_contents($cc["fullname"]);
         $conts = html_entity_decode($conts, ENT_QUOTES, "utf-8");
         $compDoc = new SimpleXMLElement($conts);
         $metaDoc = $compDoc->metadata;
         $componentNode = $parent->addChild('component');
         $componentNode->addAttribute('id', $compDoc['id']);
         $componentNode->addAttribute('basePath', '/data/');
         $componentNode->addAttribute('relativePath', $cc["relativePath"]);
         $componentNode->addChild('year',$metaDoc->year);
         if(strlen($compDoc->description->title)>0){
            $componentNode->addChild('title',$compDoc->description->title);
         } else {
            $componentNode->addChild('title',$compDoc->metadata->title);
         }
         $componentNode->addChild('schooltype',$metaDoc->schooltype);
         $stateNode = $componentNode->addChild('state');
         $stateNode->addAttribute('type',(string)$metaDoc->state['type']);
         $subNode = $componentNode->addChild('subcomponents');
         $subDoc = $compDoc->subcomponents;
         for($kk=0; $kk<count($subDoc->subcomponent);$kk++) {
             $s = $subDoc->subcomponent[$kk];
             $sc = $subNode->addChild('subcomponent');
             $sc->addAttribute('number', $s['number']);
             $sc->addAttribute('id', $s['id']);
             $sc->addChild('title', $s->title);
             $sc->addChild('file', $cc["relativePath"].(string)$s->file);
         }
    }
    function isAcceptedComponent($cc, $repoFilter, $yearFilter) {
        $isAccepted = count($repoFilter)==0;
        for($kk=0;$kk<count($repoFilter); $kk++) {
            if(strcmp($cc["repo"], $repoFilter[$kk])==0) {
                $isAccepted = true;
                break;
            }
        }
        if(!$isAccepted) return false;

        $isAccepted = count($yearFilter)==0;
        for($kk=0;$kk<count($yearFilter); $kk++) {
            if(strpos($cc["year"], $yearFilter[$kk])!==false) {
                $isAccepted = true;
                break;
            }
        }
        return $isAccepted;
    }

    function findComponents($basePath, $subFolder, $repo, $iter){
       $comps = array();
       $xmlFound = false;
       $this->logger->trace(LEVEL_INFO, "scanning: ".$basePath.$subFolder);
       $path = $basePath.$subFolder;
       $folderArr = scandir($path);
       for($jj=0; $jj<count($folderArr);$jj++) {
          $file = $folderArr[$jj];
          $ii = strpos($file,".xml");
          if($ii>0 && $ii==strlen($file)-4 && $file!='index.xml'&& $file!='entities.xml') {
             $xmlFound = true;
             $fullName = $path.$file;

             $txt = file_get_contents($fullName);
             $txt = EntityConverter::convert_entities($txt);
             try{
                 $doc = new SimpleXMLElement($txt);

                 $id = $doc->xpath("/component/@id");
                 $schooltype = $doc->xpath("/component/metadata/schooltype");
                 $year = $doc->xpath("/component/metadata/year");
                 $state = $doc->xpath("/component/metadata/state/@type");
                 $isValid = true;
                 //check if this is a component file
                 if(count($id)!=1) {
                     $isValid = false;
                     $this->logger->trace(LEVEL_ERROR, "Invalid component: Missing id attribute for $fullName");
                 } else {
                     $id = (string)($id[0]);
                 }
                 if(count($schooltype)!=1) {
                     $isValid = false;
                     $this->logger->trace(LEVEL_ERROR, "Invalid component: Missing schooltype in for $fullName");
                 } else {
                     $schooltype = (string)($schooltype[0]);
                 }
                 if(count($year)!=1) {
                     $isValid = false;
                     $this->logger->trace(LEVEL_ERROR, "Invalid component: Missing year tag in $fullName");
                 } else {
                     $year = (string)($year[0]);
                 }
                 if(count($state)!=1) {
                     $isValid = false;
                     $this->logger->trace(LEVEL_ERROR, "Invalid component: Missing state attribute in $fullName");
                 } else {
                     $state = (string)($state[0]);
                 }
                 
                 $ii = strrpos($fullName,'/');
                 $parent = substr($fullName, 0, $ii);
                 
                 if($isValid) {
                     if(strcmp($state,"live")==0) {
                         $cc = array(
                             "id"=>$id,
                             "fullname"=>$fullName,
                             "absolutePath"=>$parent,
                             "relativePath"=>$subFolder,
                             "schooltype"=>$schooltype,
                             "year"=>$year,
                             "repo"=>$repo
                         );
                         array_push($comps,$cc);
                         $this->logger->trace(LEVEL_INFO, "found component ".print_r($cc, true));
                     } else {
                         $this->logger->trace(LEVEL_INFO, "skipping $fullName because state is not 'live', but set to $state");
                     }
                 }
             } catch(Exception $e) {
                $this->logger->trace(LEVEL_ERROR, "When analyzing $fullName: ".$e->getMessage());
             }
          }
       }
       //no xml-file found, recurse into subdirectories
       if(!$xmlFound && $iter<3) {
            for($jj=0; $jj<count($folderArr);$jj++) {
                $file = $folderArr[$jj];
                if($file[0]!='.' && $file[0]!='_') {
                    $fullName = $path.$file;
                    if(is_dir($fullName)){
                        $cc = $this->findComponents($basePath, $subFolder.$file.'/', $repo, $iter+1);
                        $comps = array_merge($comps, $cc);
                    }
                }
            }
       }
       return $comps;
    }
}


$pub = new Overview();

?>