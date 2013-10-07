<?php
require_once("Logger.php");
class ThreeShipsPlatform extends Platform {
    private $WSDLURL = "/Services/Security.asmx?wsdl";
    private $passwd = "";
    private $SERVER = "";
    private $SERVER_DEMO = "http://content.demo.threeships.nl";
    private $SERVER_PUBLISH = "http://content.threeships.nl";
    
    private $loginID = "WSA_MathUnited";
    private $passwd_DEMO = "906D00B3-2E39-4893-BC1F-F6354995B096";
    private $passwd_PUBLISH = "097540BF-0E99-48B9-868E-C358D2F76814";
    private $webMethod = array(
        'ma' => "ConvertMath4All",
        'wm' => "ConvertWagMethode"
    );
    private $folderPath = array(
        'ma' => "/CDS/MathUnited/Published content/Math4All/",
        'wm' => "/CDS/MathUnited/Published content/Wageningse Methode/"
    );
    
    private $leerlijnPath = array(
        'ma-havovwo-12' => "LJ1",
        'ma-havo-2' => "LJ2",
        'ma-vwo-2' => "LJ2",
        'ma-test' => "LJ1",
        'wm-havovwo-1' => "LJ1",
        'wm-havo-2' => "LJ2",
        'wm-vwo-2' => "LJ2",
        'wm-test' => "LJ1"
    );
    
    private $MUContentURL = "http://mathunited.pragma-ade.nl:41080";
    private $settings = "";
    private $cookie;
    
    //constructor 
    public function ThreeShipsPlatform($publishId, $demo) {
        $this->publishId = $publishId;
        ini_set('default_socket_timeout', 600);
        if($demo){
            $this->SERVER = $this->SERVER_DEMO;
            $this->passwd = $this->passwd_DEMO;
        } else {
            $this->SERVER = $this->SERVER_PUBLISH;
            $this->passwd = $this->passwd_PUBLISH;
        }
        
    }
    
    //Log in to ThreeShips digitale schooltas
    //Return true on success, false otherwise
    public function prePublish($logger) {
        $error = false;
        $soapclient = new SoapClient($this->SERVER.$this->WSDLURL);
        //Enter the loginid of the webservice account (a user that exists in the CDS, and has permissions to execute the webservice)
        $arguments = array("loginid" => $this->loginID); 

        //Send login request
        try {
            $challengeObject = $soapclient->__soapCall("initializeLogin", array('parameters' => $arguments) );
        } catch(SoapFault $ex) {
            $error = true;
            echo $ex;
        }

        //If OK, recieve challenge
        if(!$error) {
            $challenge = $challengeObject->InitializeLoginResult;

            //combine challenge and password, and encrypty
            //Enter the passwords of the webservice account
            $challengeCompose = $this->passwd.$challenge; 
            $challengeCrypt = sha1($challengeCompose);

            //return challenge
            $arguments = array("response" => $challengeCrypt);
            $cookieResponse = $soapclient->__soapCall("Login", array('parameters' => $arguments) );
            //If OK, recieve response 1. Cookie is now set
            $this->cookie = $soapclient->_cookies["N%40TCookie"][0];
            $logger->trace(LEVEL_ERROR, "Response of login : ".print_r($cookieResponse,true).", cookie=".print_r($this->cookie,true));
        }
        return !$error;
    }


    //Upload a single component
    public function publishComponent($compDescr, $threadID, $logger) {
        $error = false;
        //Set up a soapclient to the Webservice
        $soapclient2 = new SoapClient($this->SERVER."/services/MU2SPService.asmx?WSDL",
                                      array('trace', TRUE));
        $soapclient2->__setCookie("N%40TCookie",urldecode($this->cookie)); //re-use cookie from login-sequence
        $soapclient2->_cookies["N%40TCookie"][1]="/";
        $soapclient2->_cookies["N%40TCookie"][2]=str_replace('http://','',$this->SERVER);
        $soapclient2->__setCookie("version","1");

        $repo = $compDescr['method'];
        $compRef = $compDescr['ref'];
        $compFile = $compDescr['fname'];
        $title = $compDescr['title'];

        //construeer pad binnen de repository van ThreeShips
        $path = $this->folderPath[$repo];          
        if(isset($this->leerlijnPath[$threadID])){
            $path = $path.$this->leerlijnPath[$threadID];
        } else {
            $logger->trace(LEVEL_ERROR, "Thread $threadID is not known to the publisher");
            $error = true;
        }

        //construeer pad binnen Mathunited repository
        if(!$error){
            $ind = strrpos($compFile,'/');
            if($ind===False) {
                $error = true;
                $logger->trace(LEVEL_ERROR, "Invalid pathname of component : $compFile");
            }
        }
        if(!$error) {
            $str = substr($compFile, 0, $ind-1);
            $ind = strrpos($str, '/');
            if($ind===False) {
                $error = true;
                $logger->trace(LEVEL_ERROR, "Invalid pathname of component : $compFile");
            }
        }
        if(!$error) {
            $MUpath = $this->MUContentURL.substr($compFile,0, $ind);
            $MUcomp = substr($compFile,$ind+1);
        }
        
        if(!$error){
            //Fill in any arguments / parameters that need to be pushed to the webmethod
            $arguments = array(
    //            "FOLDERPATH"       => $path,
                "FOLDERPATH"       => $path,
                "PACKAGENAME"      => $title,                   //Naam van ded Silverpoint
                "MUCONTENTURL"     => $MUpath,                  //de url van de root van het MathUnited hoofdstuk
                "MUENTITIESURL"    => "http://mathunited.pragma-ade.nl:41080/data/content-overview/entities.xml",                  //de url naar entities.xml
                "MUCONVERTFILEURL" => $MUcomp,                //relatieve pad naar de component
                "SETTINGS"         => $this->settings           //not used yet
            );     
            $logger->trace(LEVEL_TRACE, print_r($arguments,true));
//            echo "<p>".$MUcomp."</p>";
            $method = $compDescr['method']; //'ma' or 'wm' 
            echo "$path; $title; $MUpath; $MUcomp; ".$this->webMethod[$method].";\n";
/*            
            try  {
                //call the webservice
                $soap_result = $soapclient2->__soapCall($this->webMethod[$method], array('parameters' => $arguments));
                $responseXML = $soapclient2->__getLastResponse();
                $logger->trace(LEVEL_ERROR, "return value: ".var_dump($soap_result));
                $logger->trace(LEVEL_ERROR, "lastResponse: ".var_dump($responseXML));
                if (is_soap_fault($soap_result)) {
                    $logger->trace(LEVEL_ERROR, "SOAP Fault: (faultcode: {$soap_result->faultcode}, faultstring: {$soap_result->faultstring})");
                }
            } catch(SoapFault $ex)  {
                $logger->trace(LEVEL_ERROR, var_dump($ex));
                $error = true;
            }
 * 
 */
        }
        return !$error;
    }

    //Upload a single subcomponent
    public function publishSubcomponent($comp, $threadID, $logger) {
        
    }

}
?>

