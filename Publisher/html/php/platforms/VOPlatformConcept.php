<?php
require_once("Logger.php");
require_once("EntityConverter.php");
class VOPlatformConcept extends Platform {
    private $baseURL = "http://stercollecties-concept.appspot.com";
    private $putTextURL = "http://stercollecties-concept.appspot.com/puttextfile";
    private $putResultXmlURL = "http://stercollecties-concept.appspot.com/putxmlfile";
    private $resourceGetBlobUrl = "http://stercollecties-concept.appspot.com/getbloburl";
    private $getResourceUrl= "http://stercollecties-concept.appspot.com/getresourceurl";
    
    //constructor 
    public function VOPlatformConcept($publishId) {
        $this->publishId = $publishId;
    }

    public function publishOverview($repoID, $repo, $logger, $threadsXML, $componentsXML) {
        $logger->trace(LEVEL_INFO, 'send components.xml for repo '.$repoID);        
        $error = !$this->sendFile('components.xml', '', $repoID, $componentsXML, $logger);
        $logger->trace(LEVEL_INFO, 'send threads.xml for repo '.$repoID);        
        $error = !$this->sendFile('threads.xml', '', $repoID, $threadsXML, $logger);
        
        $files = scandir($repo['basePath'].'resultxml/');
        foreach($files as $file) {
            if (!is_dir($file) && strtolower(substr($file, -4)) == '.xml') {
                $logger->trace(LEVEL_INFO, 'sending '.$file.'...');
                $this->sendXmlFile(basename($file, ".xml"), $repoID, file_get_contents($repo['basePath'].'resultxml/'.$file), $logger, "result-structure");
            }
        }
    }
    
    public function publishComponentFile($compId, $compRef, $basePath, $repo, $logger) {
        $logger->trace(LEVEL_INFO, 'publishing component file for '.$compId.' repo='.$repo);
        $compFile = $basePath.$compRef;
        $txt = file_get_contents($compFile);
        if($txt===false) throw new Exception("Component $compFile does not exist");

        $txt = EntityConverter::convert_entities($txt);
        $doc = new SimpleXMLElement($txt);
        $this->sendFile($compRef, "", $repo, $doc->asXML(), $logger);
        
    }
    
    //Upload a single subcomponent
    public function publishSubcomponent($comp, $threadID, $logger) {
        $logger->trace(LEVEL_INFO, 'publishing subcomponent '.$comp['subcompId']);        
        
        $repo = $comp['method'];
        $subcompRef = $comp['subcompRef'];
        $subcompId = $comp['subcompId'];
        $compId = $comp['compId'];
        $compRef = $comp['compRef'];
        $pathbase = $comp['pathbase'];

        //create base path
        $subcompFile = $pathbase.$subcompRef;
        
        $ind = strrpos($subcompFile, '/');
        $base = '';
        if($ind > 0) {
            $base = substr($subcompFile, 0, $ind+1);
        }
        
        //read index file containing numbering information
        $txt = file_get_contents($base.'../index.xml');
        if($txt===false) {
            $logger->trace(LEVEL_ERROR, "index.xml for Component $compRef does not exist");
            $indexDoc = null;
        } else {
            $txt = EntityConverter::convert_entities($txt);
            $indexDoc = new SimpleXMLElement($txt);
        }

        $txt = file_get_contents($subcompFile);
        if($txt===false) throw new Exception("Subcomponent $subcompFile does not exist");

        $txt = EntityConverter::convert_entities($txt);
        $doc = new SimpleXMLElement($txt);

        if($indexDoc!=null) {
            $elm = $indexDoc->xpath("//component[@id='$compId']/subcomponent[@id='$subcompId']");
            if(count($elm)>0) {
                $indexBase = $elm[0];
                $indexBase = (string)$indexBase['_base'];
                $doc->addAttribute('_base',$indexBase);
            }
            //add list of subcomponents to the xml
            $elm1 = $doc->addChild('internal-meta');
            $elm2 = $elm1->addChild('subcomponents');
            $comps = $indexDoc->xpath("//component[@id='$compId']/subcomponent");
            foreach($comps as $comp) {
                $ref = $elm2->addChild('subcomponent');
                $ref['_nr']=$comp['_nr'];
                $ref['id']=$comp['id'];
            }
        }
        $this->setTextrefs($compId, $doc, $indexDoc, $logger);
        $this->sendResourcesFromFile($doc, $subcompId, $repo, $logger, $base);
        $this->sendFile($subcompRef, "", $repo, $doc->asXML(), $logger);

        //also post containing includes
        $main = new SimpleXMLElement($txt);
        $incs = $main->xpath("//include");
        foreach($incs as $inc) {
            $incId = (string)$inc['filename'];
            $fname = $base.$incId;
            $txt = file_get_contents($fname);
            if($txt===false) throw new Exception("File $fname does not exist");
            $txt = EntityConverter::convert_entities($txt);

            //find references to resources in this document
            $doc = new SimpleXMLElement($txt);

            $this->setTextrefs($compId, $doc, $indexDoc, $logger);
            $this->sendResourcesFromFile($doc, $subcompId, $repo, $logger, $base);
            //send the updated xml file
            $this->sendFile($incId, $subcompRef, $repo, $doc->asXML(), $logger);
        }
    }

    private function setTextrefs($compId, $doc, $indexDoc, $logger) {
        if($indexDoc==null) return;
        
        $textrefs = $doc->xpath("//textref");
        foreach($textrefs as $textref) {
            $ref = $textref['ref'];
            if(strlen($ref)==0) $ref = $textref['item'];
            $indexElm = $indexDoc->xpath("/index//*[@id='$ref']");  
            if(count($indexElm)>0){
                $indexElm = $indexElm[0];
                $nr = (string)$indexElm['_nr'];
                $str = (string)$textref;                
                $textref->{0}=$str.' '.$nr;
            } else {
                $logger->trace(LEVEL_ERROR, "textref: item with id='$ref' does not exist");                
            }
        }
        
    }
    
    private function sendFile($id, $parentId, $repo, $text, $logger) {
        $srcItems = array('+','%');
        $rplcItems = array('&#43;','&#37;');
        $text = str_replace($srcItems,$rplcItems,$text);
        //remove entities reference, as entities will be dealt with in the publisher already
        $ii_start = strpos($text, "<!DOCTYPE");
        $ii_end = strpos($text, ">", $ii_start);
        $text = substr_replace($text, '', $ii_start, $ii_end-$ii_start+1);

        $fields = array(
            'id'=>rawurlencode($id),
            'parentid'=>rawurlencode($parentId),
            'text'=>rawurlencode($text),
            'repo'=>$repo
        );

        //url-ify the data for the POST
        $fields_string = '';
        foreach($fields as $key=>$value) { $fields_string .= $key.'='.$value.'&'; }
        rtrim($fields_string,'&');
            
        $ch = curl_init($this->putTextURL);
 
        curl_setopt($ch, CURLOPT_POST, 1);
        curl_setopt($ch, CURLOPT_POST,count($fields));
        curl_setopt($ch, CURLOPT_POSTFIELDS,$fields_string);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
 
        $response = curl_exec($ch);
        if($response!=null) {
            if (strncmp($response, 'error', 5)==0) 
                throw new Exception($response);
            else if (strncmp($response, 'info: ', 6)==0) 
                $logger->trace(LEVEL_INFO, 'TextFile '.$id.' stored ('.$response.')');      
            else
                $logger->trace(LEVEL_INFO, 'TextFile '.$id.' transfer response = '.$response);      
        }
        
        curl_close($ch);
    }

    private function sendXmlFile($id, $repo, $text, $logger, $type) {
        $srcItems = array('+','%');
        $rplcItems = array('&#43;','&#37;');
        $text = str_replace($srcItems,$rplcItems,$text);
        //remove entities reference, as entities will be dealt with in the publisher already
        $ii_start = strpos($text, "<!DOCTYPE");
        $ii_end = strpos($text, ">", $ii_start);
        $text = substr_replace($text, '', $ii_start, $ii_end-$ii_start+1);

        $fields = array(
            'id'=>rawurlencode($type . "/" . $id),
            'text'=>rawurlencode($text),
            'repo'=>$repo
        );

        //url-ify the data for the POST
        $fields_string = '';
        foreach($fields as $key=>$value) { $fields_string .= $key.'='.$value.'&'; }
        rtrim($fields_string,'&');
            
        $ch = curl_init($this->putResultXmlURL);
 
        curl_setopt($ch, CURLOPT_POST, 1);
        curl_setopt($ch, CURLOPT_POST,count($fields));
        curl_setopt($ch, CURLOPT_POSTFIELDS,$fields_string);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
 
        $response = curl_exec($ch);
        if($response!=null) {
            if (strncmp($response, 'error', 5)==0) 
                throw new Exception($response);
            else if (strncmp($response, 'info: ', 6)==0) 
                $logger->trace(LEVEL_INFO, 'XmlFile '.$id.' stored ('.$response.')');      
            else
                $logger->trace(LEVEL_INFO, 'XmlFile '.$id.' transfer response = '.$response);      
        }
        
        curl_close($ch);
    }

    private function sendResourcesFromFile($doc, $compId, $repo, $logger, $base){
        //find references to resources in this document
        //...images...
        $imgs = $doc->xpath("//resource");
        foreach($imgs as $imgId){
            $id = (string)$imgId->name;
            $type = "image";
            //$imagefname = $this->URLBASE[$repo].$id;
            $correctedId = str_replace('Images/','',$id);
            $fileExists = false;
            if(file_exists($base.$correctedId)) { 
                $imagefname = $base.$correctedId;
                $fileExists = true;
            } else if(file_exists($base.'../images/highres/'.$correctedId)){
                $imagefname = $base.'../images/highres/'.$correctedId;
                $fileExists = true;
            } else {
                $fileExists = false;
            }
            
            if($fileExists){
                $exif_type = exif_imagetype($imagefname);
                if($exif_type){
                    $mimetype = image_type_to_mime_type($exif_type);
                } else {
                    $mimetype = "application/octet-stream";
                }
                try
                {
                    $getUrl = $this->sendResource($imagefname, $compId, $correctedId, $repo, $type, $mimetype, $logger);
                    $imgId->name = $getUrl; //put the direct URL in the xml
                }
                catch(Exception $e)
                {
        	        $logger->trace(LEVEL_ERROR, $e->getMessage());
                }
            } else {
                  $logger->trace(LEVEL_ERROR, "Missing image: File $correctedId does not exist in subcomponent $compId."); 
//                throw new Exception("Missing image: File $correctedId does not exist in subcomponent $compId.");
            }
        }
        //...Geogebra applets...
        //<applet filename='GeoGebra/Me01U01.ggb' width="290" height="210" type='ggb' location='right'>
        $ggbs = $doc->xpath("//applet[@type='ggb']");
        foreach($ggbs as $ggbId){
            $id = (string)$ggbId['filename'];
            $type = "ggb";
            //$ggbfname = $this->URLBASE[$repo].$id;
            $correctedId = str_replace('GeoGebra/','',$id);
            $ggbfname = $base.'../geogebra/'.$correctedId;
            if(file_exists($ggbfname)){
                $mimetype = "application/octet-stream";
                try
                {
                    $getUrl = $this->sendResource($ggbfname, $compId, $correctedId, $repo, $type, $mimetype, $logger);
                    $ggbId['filename'] = $getUrl; //put the direct URL in the xml
                }
                catch(Exception $e)
                {
        	        $logger->trace(LEVEL_ERROR, $e->getMessage());
                }
            } else {
                  $logger->trace(LEVEL_ERROR, "Invalid Geogebra applet: File $ggbfname does not exist in subcomponent $compId."); 
//                throw new Exception("Invalid Geogebra applet: File $ggbfname does not exist in subcomponent $compId.");
            }
        }

        //...movies & audio binaries... added by DdJ, 07-01-2014
        $resrcs = $doc->xpath("//movie | //audio");
        foreach($resrcs as $rsrcId){
            $id = (string)$rsrcId['href'];
            $id = urldecode($id);
            $type = "movie";
            $fname = $base.$id;
            if(file_exists($fname)){
        		$mimetype = $this->getMIMEtype($fname);
                try
                {
                    $getUrl = $this->sendResource($fname, $compId, $id, $repo, $type, $mimetype, $logger);
                    $rsrcId['href'] = trim($getUrl)."&attachment=true"; //put the direct URL in the xml
                }
                catch(Exception $e)
                {
        	        $logger->trace(LEVEL_ERROR, $e->getMessage());
                }
            } else {
                  $logger->trace(LEVEL_ERROR, "Broken resourcelink: File $id does not exist in subcomponent $compId."); 
            }
            
            $idx = strrpos($id,'.');
            if ($idx != FALSE) {
                $id = substr($id,0,$idx).'.webm';
	            $fname = $base.$id;
	            if(file_exists($fname)){
	        		$mimetype = $this->getMIMEtype($fname);
	                try
	                {
	                    $getUrl = $this->sendResource($fname, $compId, $id, $repo, $type, $mimetype, $logger);
	                    $rsrcId['href2'] = trim($getUrl)."&attachment=true"; //put the direct URL in the xml
	                }
	                catch(Exception $e)
	                {
	        	        $logger->trace(LEVEL_ERROR, $e->getMessage());
	                }
	            }
            }
        }

        //...other resources...
        $resrcs = $doc->xpath("//resourcelink");
        foreach($resrcs as $rsrcId){
            $id = (string)$rsrcId['href'];
            $id = urldecode($id);
            $type = "dox";
            $fileExists = false;
            if(file_exists($base.$id)) { 
                $fname = $base.$id;
                $fileExists = true;
            } else if(file_exists($base.'../dox/'.$id)){
                $fname = $base.'../dox/'.$id;
                $fileExists = true;
            } else {
                $fileExists = false;
            }
            if($fileExists){
                $mimetype = $this->getMIMEtype($fname);
                //$mimetype = "application/octet-stream";
                try
                {
                    $getUrl = $this->sendResource($fname, $compId, $id, $repo, $type, $mimetype, $logger);
                    $rsrcId['href'] = trim($getUrl)."&attachment=true"; //put the direct URL in the xml
                }
                catch(Exception $e)
                {
        	        $logger->trace(LEVEL_ERROR, $e->getMessage());
                }
            } else {
                  $logger->trace(LEVEL_ERROR, "Broken resourcelink: File $id does not exist in subcomponent $compId."); 
//                throw new Exception("Broken resourcelink: File $fname does not exist in subcomponent $compId.");
            }
        }

     }
     

    private function sendResource($fname, $parentId, $id, $repo, $type, $mimetype, $logger) {

        $localChecksum = md5_file($fname);

        $ch = curl_init(
            $this->getResourceUrl. 
            "?id=".urlencode($id). 
            "&parentid=".urlencode($parentId). 
            "&repo=".$repo. 
            "&type=".$type. 
            "&checksum=".$localChecksum 
            ); 
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $response = curl_exec($ch);
        if($response!=null && strncmp($response, 'error', 5)==0){
            throw new Exception($response);
        }
        $logger->trace(LEVEL_TRACE, $response);
        curl_close($ch);

        $url = trim($response);
        if ($url != "")
        {
            $logger->trace(LEVEL_INFO, 'Skipped resource upload ('.$type.') (id='.$id.', repo='.$repo.', fname='.$fname.', mimetype='.$mimetype.' <a href="'.$this->baseURL.$url.'">open</a>)');       
            return $url;
        }
        
        //get upload url to reach the blobstore (see https://developers.google.com/appengine/docs/java/blobstore/overview)
        $ch = curl_init($this->resourceGetBlobUrl); 
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $putURL = curl_exec($ch);
        if($putURL!=null && strncmp($putURL, 'error', 5)==0){
            throw new Exception($putURL);
        }
        curl_close($ch);
        
        $fields = array(
            'id'=>urlencode($id),
            'parentid'=>urlencode($parentId),
            'repo'=>$repo,
            'type'=>$type,
            'bin'=>"@$fname;type=$mimetype",
            'publishid'=>urlencode($this->publishId),
    	    'checksum'=>$localChecksum
        );
        $ch = curl_init($putURL); 
        curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

        $response = curl_exec($ch);
        if($response!=null && strncmp($response, 'error', 5)==0){
            throw new Exception($response);
        }
        $logger->trace(LEVEL_INFO, 'Uploaded resource ('.$type.') (id='.$id.', repo='.$repo.', fname='.$fname.', mimetype='.$mimetype.' <a href="'.$this->baseURL.$response.'">open</a>)');       
        curl_close($ch);
        return $response;
    }
}
?>

