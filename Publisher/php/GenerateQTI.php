<?php
// generates overview files:
// - components.xml to contain all components and subcomponents. Used for WiskundeMenu
// - for each component, a file index.xml, containing all numbered items

define('MAX_TIME_LIMIT',60);
require_once("Logger.php");
require_once("EntityConverter.php");


class QTIGenerator {
    var $loglevel = LEVEL_INFO;
    var $logger;
    var $comm;          //request data $_POST or $_GET
    var $config_contentRoot;
    
    function QTIGenerator() {
        header('Content-type: text/html');
        include("Config.php");
        $this->contentRoot = $config_contentRoot;
        
        //post or get?
        $this->comm = $_GET;
        if( isset($this->comm['repo']) ) {
            $repoId = $this->comm['repo'];
            $this->repo = $config_repos[$repoId];
            $this->logger = new Logger($this->loglevel, $repoId, false);
        } else {
            throw new Exception('QTIGenerator called without repo identifier');
        }
try{
        if( isset($this->comm['component']) ) {
            $componentId = $this->comm['component'];
        } else {
            throw new Exception('QTIGenerator called without component identifier');
        }

        $conts = file_get_contents($config_contentRoot.$this->repo['basePath'].'leerlijnen/components.xml');
        $conts = html_entity_decode($conts, ENT_QUOTES, "utf-8");
        $doc = new SimpleXMLElement($conts);
        $comp = $doc->xpath("/mathunited/methods/method/components/component[@id='$componentId']");
        if(count($comp)!=1) {
            throw new Exception("Id $componentId does not correspond to a single component");
        } else {
            $comp = $comp[0];
        }
        $this->transformComponent($comp);
        echo "<html><head></head><body><h1>Geslaagd</h1></body></html>";
} catch(Exception $e) {
   echo "<html><head></head><body><h1>Fout opgetreden</h1></body></html>";
   $this->logger->trace(LEVEL_ERROR, $e->getMessage());
}        
    }

    function transformComponent($comp) {
        $this->qtifolder = $comp['basePath'].$comp['relativePath'].'qti';
        if(!file_exists($this->qtifolder)) mkdir($this->qtifolder);
        if(!is_writable($this->qtifolder)) {
            $this->logger->trace(LEVEL_ERROR, "folder ".$this->qtifolder." must be writable!");
            throw new Exception("folder ".$this->qtifolder." must be writable!");
        }

        $subcomplist = $comp->xpath('subcomponents/subcomponent');
        foreach($subcomplist as $subcomp) {
            $this->transformSubcomponent($subcomp, $comp);
        }

    }
    function transformSubcomponent($subcomp, $comp) {
        error_reporting(~0);
        ini_set('display_errors', 1);
        $this->logger->trace(LEVEL_INFO, "Generating QTI for  subcomponent".$subcomp['id']) ;

        $tempfolder = $this->qtifolder.'/temp/';
        if(!file_exists($tempfolder)) mkdir($tempfolder);
        
        $url = str_replace(array('{#COMP}','{#SUBCOMP}'), array($comp['id'], $subcomp['id']), $this->repo['get_QTI_url']);
        $xml = file_get_contents($url);
//      $xml = html_entity_decode($xml, ENT_QUOTES, "utf-8");
//      $xml = str_replace('&','&amp;',$xml);
        try{
            $doc = new SimpleXMLElement($xml);
            $doc->registerXPathNamespace('qti', 'http://www.imsglobal.org/xsd/imsqti_v2p1');
//          $doc->registerXPathNamespace('imscp', 'http://www.imsglobal.org/xsd/imscp_v1p1');
            $doc->registerXPathNamespace('mslob', 'http://math4all.nl');

            $this->getMedia($doc, $tempfolder);
        } catch(Exception $e) {
            $msg = "<h3>Error when reading file $url</h3>";
            echo $msg;
            $this->logger->trace(LEVEL_ERROR, $msg);
            $this->logger->trace(LEVEL_ERROR, $e->getMessage());
            throw $e;
        }        
        
        $fileList = $doc->xpath('//mslob:file');
        foreach($fileList as $file) {
            $fname = $file['name'];
            $childlist = $file->xpath('*[1]');
            foreach($childlist as $child){
                $str = $child->asXML();
                $str = '<?xml version="1.0" encoding="UTF-8"?>'.$str;
                $str = str_replace('xmlns:xsi=', 'xmlns:m="http://www.w3.org/1998/Math/MathML" xmlns:imscp="http://www.imsglobal.org/xsd/imscp_v1p1" xmlns:imsmd="http://www.imsglobal.org/xsd/imsmd_v1p2p2" xmlns:qti="http://www.imsglobal.org/xsd/imsqti_v2p1" xmlns:xsi=',$str);
                file_put_contents($tempfolder.$fname, $str);
                break;
            }
        }

        $zip = new ZipArchive();
        $filename = $this->qtifolder.'/qti-'.$subcomp['id'].'.zip';
        if(file_exists($filename)) unlink($filename);
        if ($zip->open($filename, ZipArchive::CREATE)!==TRUE) {
            $this->logger->trace(LEVEL_ERROR, "cannot open $filename");
            throw new Exception("cannot open <$filename>");
        }
        //add standard .xsd files to temp folder
        $fileArr = scandir('/data/Publisher/qti');
        foreach($fileArr as $fname) {
            if(strpos($fname,'.xsd')!==FALSE) {
                $zip->addFile('/data/Publisher/qti/'.$fname, $fname);
            }
        }
        $fileArr = scandir($tempfolder);
        foreach($fileArr as $fname) {
            if ($fname != '.' && $fname != '..') { 
                 $f = $tempfolder.'/'.$fname;
                if(is_file($f)) {
                    $zip->addFile($f, $fname);
                } else if(is_dir($f)) {
                    if($fname=='media') {
                        $zip->addEmptyDir($fname);
                        $fileArr2 = scandir($f);
                        foreach($fileArr2 as $fname2) {
                            if ($fname2 != '.' && $fname2 != '..') { 
                                $f2 = $tempfolder.'/media/'.$fname2;
                                if(is_file($f2)) {
                                    $zip->addFile($f2, 'media/'.$fname2);
                                }
                            }
                        }
                    }
                }
            }
        }
        $res = $zip->close();  
        if($res==FALSE) {
            $this->logger->trace(LEVEL_ERROR, "cannot create archive $filename");
        }
        $this->deleteDir($tempfolder);
        
    }
    
    function getMedia($doc, $tempfolder) {
        $mediafolder = $tempfolder.'media/';
        if(!file_exists($mediafolder)) mkdir($mediafolder);

        //images
        $imglist = $doc->xpath('//img');
        foreach($imglist as $img) {
            $ref_org = $img['src'];
            if(!file_exists($ref_org)) {
                $this->logger->trace(LEVEL_ERROR, "media $ref_org does not exist");
            }
            $ind = strrpos($ref_org,'/');
            $fname = substr($ref_org,$ind+1);
            $ref_dest = $mediafolder.$fname;
            copy($ref_org, $ref_dest);
            $img['src'] = str_replace($tempfolder, '', $ref_dest);
        }

        //images
        $doxlist = $doc->xpath('//a[@class="dox"]');
        foreach($doxlist as $dox) {
            $ref_org = $dox['href'];
            if(!file_exists($ref_org)) {
                $this->logger->trace(LEVEL_ERROR, "media $ref_org does not exist");
            }
            $ind = strrpos($ref_org,'/');
            $fname = substr($ref_org,$ind+1);
            $ref_dest = $mediafolder.$fname;
            copy($ref_org, $ref_dest);
            $dox['href'] = str_replace($tempfolder, '', $ref_dest);
        }
 
 
        //geogebra
        /*
        $ggblist = $doc->xpath('//iframe[@_type="ggb"]');
        foreach($ggblist as $ggb) {
            $ref_org = $ggb['src'];
            $ind = strpos($ref_org,'file=');
            $prefix = substr($ref_org, 0, $ind);
            $ref_org = substr($ref_org,$ind+7); //not +5, also loose the ..
            $ind = strrpos($ref_org,'/');
            $fname = substr($ref_org,$ind+1);
            $ref_dest = $mediafolder.$fname;
            copy($ref_org, $ref_dest);
            $ggb['src'] = $prefix.str_replace($tempfolder, '', $ref_dest);
        }
        */
        //same for manifest file
        $filelist = $doc->xpath('//imscp:manifest/imscp:resources/imscp:resource/imscp:file');
        foreach($filelist as $file) {
            $ref_org = $file['href'];
            $ind = strrpos($ref_org,'/');
            if($ind!==FALSE) {
                $ref_org = substr($ref_org,$ind+1);
            } 
            if(strrpos($ref_org,'.xml')===FALSE) {
               $ref_dest = $mediafolder.$ref_org;
            } else {
               $ref_dest = $tempfolder.$ref_org;
            }
                
            $file['href'] = str_replace($tempfolder, '', $ref_dest);
        }
    }
    
    function transformUnit($unitDoc, $comp, $subcomp, $qtifolder, $sectionDoc) {
        $exlist = $unitDoc->xpath('//exercise');
        $ii = 1;
        foreach($exlist as $ex) {
            $this->transformExercise($ex, $comp, $subcomp, $unitDoc, $qtifolder, $sectionDoc, $ii);
            $ii++;
        }
    }
    
    function transformExercise($ex, $comp, $subcomp, $unitDoc, $qtifolder, $sectionDoc, $index) {
        $xslt_string = file_get_contents('qti/exercise_to_qti.xslt');
        $xsltDoc = new SimpleXMLElement(html_entity_decode($xslt_string, ENT_QUOTES, "utf-8"));
        $xslt = new XSLTProcessor();
        $xslt->importStylesheet($xsltDoc);
        $id = $unitDoc['id'].'-'.$index;
        $fname = $comp['id'].'-'.$subcomp['id'].'-'.$unitDoc['id'].'-'.$index.'.xml';

        $assRefDoc = $sectionDoc->addChild('assessmentItemRef');
        $assRefDoc['identifier'] = $id;
        $assRefDoc['href'] = $fname.'.xml';
        
        $xslt->setParameter('', 'ex-id', $id);
        $xslt->setParameter('', 'title', (string)$comp->title.' - '.(string)$subcomp->title.' - Opgave '.$index);
        
        $destName = $qtifolder.'/'.$fname;
        $xslt->transformToURI($ex,'file://'.$destName);  
    }
    //specific task implementation. Return false on failure, some string on success
    function executeImpl() {
        die("not implemented");
    }
    
    public static function deleteDir($dirPath) {
        if (! is_dir($dirPath)) {
            throw new InvalidArgumentException("$dirPath must be a directory");
        }
        if (substr($dirPath, strlen($dirPath) - 1, 1) != '/') {
            $dirPath .= '/';
        }
        $files = glob($dirPath . '*', GLOB_MARK);
        foreach ($files as $file) {
            if (is_dir($file)) {
                self::deleteDir($file);
            } else {
                unlink($file);
            }
        }
        rmdir($dirPath);
    }    

}


$pub = new QTIGenerator();

?>