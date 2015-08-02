<?php


abstract class Platform {
    //constructor 
    public function Platform() {
    }
    
    //Platform-specific operations: e.g. log in 
    //Return true on success, false otherwise
    public function prePublish($logger) {return true;}

    //Upload a single component
    public function publishComponentFile($compId, $compRef, $basePath, $logger) {return true;}
    //Upload a single subcomponent
    public function publishSubcomponent($comp, $threadID, $logger) {return true;}
    //Upload components.xml and threads.xml
    public function publishOverview($repo, $logger) {return true;}
    //clean up, log out
    public function postPublish() {return true;}
    //Upload a single component
    public function uploadQTIComponent($compFile, $path, $logger) {return true;}
    
    
    function getMIMEType($fname) {
	$mime = '';
	$ext = strrchr($fname, '.');
	if($ext) {
            $ext = substr($ext, 1);                
            switch($ext){
                case 'ppt':
                    $mime = 'application/vnd.ms-powerpoint';
                    break;
                case 'pptx':
                    $mime = 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
                    break;
                case 'xls':
                    $mime = 'application/vnd.ms-excel';
                    break;
                case 'xlsx':
                    $mime = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
                    break;
                case 'doc':
                    $mime = 'application/msword';
                    break;
                case 'docx':
                    $mime = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
                    break;
                case 'png':
                    $mime = 'image/png';
                    break;
                case 'svg':
                    $mime = 'image/svg';
                    break;
                case 'jpg':
                    $mime = 'image/jpeg';
                    break;
                case 'gif':
                    $mime = 'image/gif';
                    break;
                case 'pdf':
                    $mime = 'application/pdf';
                    break; 
                case 'cg3':
                    $mime = 'application/xml';
                    break;
                case 'mp3':
                    $mime = 'audio/mpeg'; 
                    break;
                case 'mp4':
                    $mime = 'video/mp4'; 
                    break;
                default:
                    $mime = 'application/octet-stream';
                    break;                
            }
        }
	return $mime;
    }
}
?>