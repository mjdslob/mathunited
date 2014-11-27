<?php
require_once("Logger.php");
require_once("EntityConverter.php");
class PulseOnPlatform extends Platform {
    
    //constructor 
    public function PulseOnPlatform($publishId) {
        $this->publishId = $publishId;
	$this->uploadURL = "http://qt-studiovo.pulseon.nl/rest/testIndex";
	$this->indexURL = "http://qt-studiovo.pulseon.nl/rest/testIndexAdmin";
    }
    
    //Upload QTI of a single component
    public function uploadQTIComponent($comp, $threadID, $logger) {
        $this->stderr = fopen('logs/stderr.log','a');
        $logger->trace(LEVEL_INFO, 'uploading QTI of subcomponent '.$comp['id']);        
        
        $repo = $comp['method'];
        $compFile = $comp['fname'];
        $compRef = $comp['ref'];
        $compId = $comp['compId'];
        $subcompId = $comp['id'];

        //create base path
        $ind = strrpos($compFile, '/');
        $base = '';
        if($ind > 0) {
            $base = substr($compFile, 0, $ind+1);
			$qtibase = $base.'../../QTI/';
        }
        
        $txt = file_get_contents($compFile);
        if($txt===false) throw new Exception("Component $compFile does not exist");

        $txt = EntityConverter::convert_entities($txt);
        $doc = new SimpleXMLElement($txt);

	$this->uploadAssessments($doc, $logger, $qtibase, $base);
		
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

            $this->uploadAssessments($doc, $logger, $qtibase, $base);
        }
        fclose($this->stderr);
    }

    private function uploadAssessments($doc, $logger, $qtibase, $base){
        //find references to resources in this document
        $asms = $doc->xpath("//assessment");
        foreach($asms as $asm){
            $id = (string)$asm['src'];
	    $player = (string)$asm['player'];
            $ind = strpos($id, ' ');
            if($ind!==FALSE) {
                throw new Exception("Assignment name '$id' contains spaces. This is not allowed.");
            }
            $fileExists = false;
            if(file_exists($qtibase.$id)) {
                $qtifname = $qtibase.$id;
                $fileExists = true;
            } else {
                $fileExists = false;
            }
            if($fileExists){
		if ($player == 'vo') {
	                $logger->trace(LEVEL_INFO, 'uploading assessment (src='.$id.') to StudioVO QTI system'); 
                	$getUrl = $this->sendAssessmentVo($qtifname, $logger);

		}
		else {
	                $logger->trace(LEVEL_INFO, 'uploading assessment (src='.$id.') to PulseOn QTI system'); 
	                $getUrl = $this->sendAssessment($qtifname, $logger);
		}
            } else {
                $logger->trace(LEVEL_ERROR, "Missing QTI assessment: File ".$qtibase.$id." does not exist.");
            }
        }
    }
     

    private function sendAssessment($fname, $logger) {
        $curdir = getcwd();                //store current working directory
        $ind = strrpos($fname, '/');       //and change working directory to location of qti-file
        $path = substr($fname, 0, $ind);   //this is necessary as PulseOn does not want to see any path info
        $name = substr($fname, $ind+1);    //in the filename
        chdir($path);
        $fields = array(
            'file'=>"@$name",
        );
        $ch = curl_init($this->uploadURL); 
        curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $response = curl_exec($ch);
        if($response!=null && strncmp($response, 'error', 5)==0){
            throw new Exception($response);
        }
        $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        switch($code) {
            case "204":
                $logger->trace(LEVEL_INFO, "Code 204: Assignment already exists, deleting existing version");
                $this->removeAssessment($fname, $logger);
//Dave test
        $ch = curl_init($this->uploadURL); 
        curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $response = curl_exec($ch);
        if($response!=null && strncmp($response, 'error', 5)==0){
            throw new Exception($response);
        }
        $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
	if ($code == "204") {
	        $logger->trace(LEVEL_INFO, "Code 204: Failed to deleting existing version");
		break;
	}
	else {
//Dave test

                $ch = curl_init($this->uploadURL); 
                curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);
                curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                $response = curl_exec($ch);
                if($response!=null && strncmp($response, 'error', 5)==0){
                    throw new Exception($response);
                }
                $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
                curl_close($ch);
	}
                break;
            case "200":
                break;
            default:
                $logger->trace(LEVEL_INFO, "Not OK: return code: $code");
                break;
        }
        chdir($curdir);
        return $response;
    }
    
    private function removeAssessment($fname, $logger) {
//                curl http://qt-studiovo.pulseon.nl/rest/testIndex/
//                curl -v -X DELETE http://qt-studiovo.pulseon.nl/rest/testIndex/_dMu1nLuuB__wuJ-TJB-XMSoTaFmkCcVScSL38NmW28
        $ind = strrpos($fname, '/');
        $name = substr($fname, $ind+1);

        //retrieve assessment id
        $ch = curl_init($this->indexURL);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $response = curl_exec($ch);
        $ind = strpos($response, $name);
        while($ind!==FALSE){
            $ind = strrpos($response, '{', -(strlen($response)-$ind));
            $ind = strpos($response,'identifier', $ind);
            $ind = strpos($response,':', $ind);
            $ind += 2;
            $indEnd = strpos($response,'"', $ind);
            $id = substr($response, $ind, $indEnd-$ind);

            $ch = curl_init($this->uploadURL.'/'.$id); 
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "DELETE");
            $response = curl_exec($ch);
            $logger->trace(LEVEL_INFO, "Delete: name=$name, id=$id, response=$response");

            //retrieve assessment id
            $ch = curl_init($this->indexURL);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            $response = curl_exec($ch);
            $ind = strpos($response, $name);
        }
    }

    private function sendAssessmentVo($fname, $logger) {
        $curdir = getcwd();                //store current working directory
        $ind = strrpos($fname, '/');       //and change working directory to location of qti-file
        $name = substr($fname, $ind+1);    //in the filename
        $ch = curl_init(); 
	$fp = fopen($fname, 'r');
	curl_setopt($ch, CURLOPT_URL, 'http://qti-player.appspot.com/services/putfile?repo=ster&id='.$name);
	curl_setopt($ch, CURLOPT_HTTPHEADER, array(
	    'Content-Length: '.filesize($fname),
	    'Content-Type: application/octet-stream'
	));
	curl_setopt($ch, CURLOPT_POST, 1);
	curl_setopt($ch, CURLOPT_TIMEOUT, 86400); // 1 Day Timeout
	curl_setopt($ch, CURLOPT_INFILE, $fp);
	curl_setopt($ch, CURLOPT_BUFFERSIZE, 128);
	curl_setopt($ch, CURLOPT_INFILESIZE, filesize($fname));

        $response = curl_exec($ch);

        if($response!=null && strncmp($response, 'error', 5)==0){
            throw new Exception($response);
        }
        $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
	$errormsg = curl_error($ch);
        curl_close($ch);
        switch($code) {
            case "200":
                $logger->trace(LEVEL_INFO, "OK: return code: $code");
                break;
            default:
                $logger->trace(LEVEL_INFO, "Not OK: return code: $code, message: $response");
                break;
        }
        return $response;
    }

}
?>

