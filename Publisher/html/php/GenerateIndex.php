<?php

// generates overview files:
// - components.xml to contain all components and subcomponents. Used for WiskundeMenu
// - for each component, a file index.xml, containing all numbered items

define('MAX_TIME_LIMIT', 600);
define('TEMP_OVERVIEW_FILE', '../tmp/comps-assembled.xml');

require_once("Logger.php");
require_once("EntityConverter.php");

function handleError($errno, $errstr, $errfile, $errline, array $errcontext) {
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

    function Overview() {
        header('Content-type: text/html');
        echo "<html><head><style>#error-div {width:100%;height:300px;border:3px solid red; position:absolute;top:0px;background-color:rgb(200,200,200)}</style></head><body>";
        try {
            set_time_limit(MAX_TIME_LIMIT);
            include("Config.php");

            //post or get?
            $repoId = 'generic';
            $this->comm = $_GET;
            if (isset($this->comm['repo'])) {
                $repoId = $this->comm['repo'];
                $this->logger = new Logger($this->loglevel, $repoId, true);
            } else {
                throw new Exception('Generate index called without repo identifier');
            }
            $doTest = false;
            if (isset($this->comm['test'])) {
                $doTest = ($this->comm['test'] == 'true');
                echo '<p>Working in test mode, the index is not adapted!</p>';
            }

            $comps = array();
            $repo = Config::getRepoConfig($repoId);
            if (!$repo) {
                throw new Exception("Generate Index called with unknown repository $repoId");
            }
            $paths = $repo['paths'];
            for ($kk = 0; $kk < count($paths); $kk++) {
                echo "<p>Searching for components in folder " . $paths[$kk] . ": </p><ul>";
                $cc = $this->findComponents($repo['basePath'], $paths[$kk], 0);
                echo "</ul>";
                $comps = array_merge($comps, $cc);
            }
            $this->createComponentsFile($comps, $repo);
            $this->removeIndexFiles($comps);
            foreach ($comps as $cc) {
                //$this->addIdToItem($cc, $repo);
                $this->generateComponentIndex($cc, $repo);
            }

            if (!$doTest) {
                $this->commitChanges($comps, $repo);
            }

            echo "<h1>Success</h1></body></html>";
        } catch (Exception $e) {
            echo "<div id='error-div'><h1>Failed</h1><p>A problem occurred while scanning the content. Please resolve this problem and retry.</p></p>" . $e->getMessage() . "</div></body></html>";
            $this->logger->trace(LEVEL_ERROR, $e->getMessage());
        }
    }

    //specific task implementation. Return false on failure, some string on success
    function executeImpl() {
        die("not implemented");
    }

    function openFile($fname) {
        # Get text from file
        $txt = file_get_contents($fname);

        # Regular expression to match xml-model directive (optional space between
        # starting <? and xml-model; can appear on multiple lines.
        $pattern = "/<\?\s*xml-model.*?\?>/m";
        $limit = -1; # Keep searching for more for safety. // TODO: could be = 1 as only one model should be specified
        $count = 0; # Count number of replacements
        

        # Replace pattern with the empty string
        $filtered_txt = preg_replace($pattern, "", $txt, $limit, $count);
                
        # Log if replacement was done, and set text in that case
        if ($count > 0) {
            $msg = "DEBUG: Removed $count xml-model directives from $fname.";
            $this->logger->trace(LEVEL_ERROR, $msg);
            #error_log("GenerateIndex::openFile: " . $msg);
            $txt = $filtered_txt;
        }

        $txt = EntityConverter::convert_entities($txt);
        $doc = new SimpleXMLElement($txt);
        return $doc;
    }

    function addIdToItem($comp, $repo) {
        //read subcomponent main file
        $base = $comp['fullname'];
        $ind = strrpos($base, '/');
        $base = substr($base, 0, $ind + 1);
        $doc = $this->openFile($comp['fullname']);
        $subDoc = $doc->subcomponents;
        for ($kk = 0; $kk < count($subDoc->subcomponent); $kk++) {
            $s = $subDoc->subcomponent[$kk];
            $fname = $s->file;
            $doc = $this->openFile($base . $fname);
            $ind = strrpos($fname, '/');
            $subbase = substr($fname, 0, $ind + 1);
            $subbase = $base . $subbase;
            //get all includes
            $inclist = $doc->xpath("//include");
            foreach ($inclist as $inc) {
                $itemname = $inc['filename'];
                $itemdoc = $this->openFile($subbase . $itemname);
                if (!$itemdoc['id']) {
                    $this->logger->trace(LEVEL_INFO, "Item $itemname does not contain an id. Fixing it.");
                    //add id to text
                    $rootname = $itemdoc->getName();
                    $id = str_replace('.xml', '', $itemname);
                    $num = 1;
                    $itemtxt = str_replace('<' . $rootname, '<' . $rootname . ' id="' . $id . '"', $itemtxt, $num);
                    file_put_contents($subbase . $itemname, $itemtxt);
                }
            }
        }
    }

    //create overview of numbered items
    function generateComponentIndex($comp, $repo) {
        try {
            $this->logger->trace(LEVEL_INFO, "Create index file for " . $comp['fullname']);
            if ($repo['index_xsl']) {
                $doc = $this->openFile($comp['fullname']);
                $xslt_string = file_get_contents($repo['index_xsl']);
                $xsltDoc = new SimpleXMLElement(html_entity_decode($xslt_string, ENT_QUOTES, "utf-8"));
                $xslt = new XSLTProcessor();
                $xslt->importStylesheet($xsltDoc);
                $xslt->setParameter('', 'refbase', $comp['absolutePath']);
                $destName = $comp["absolutePath"] . '/index.xml.new';
                if (file_exists($destName)) {
                    //add component to existing index file
                    $resultDoc = $xslt->transformToDoc($doc);
                    $componentNode = $resultDoc->childNodes->item(0)->childNodes->item(0); //component node
                    $indexDoc = new DOMDocument();
                    $indexDoc->load($destName);
                    $componentNode = $indexDoc->importNode($componentNode, true);
                    $indexNode = $indexDoc->childNodes->item(0);
                    $indexNode->appendChild($componentNode);
                    $indexDoc->save($destName);
                } else {
                    $resultDoc = $xslt->transformToURI($doc, 'file://' . $destName);
                }
            }
        } catch (Exception $e) {
            echo $e->getMessage();
            $this->logger->trace(LEVEL_ERROR, $e->getMessage());
        }
    }

    function removeIndexFiles($comps) {
        foreach ($comps as $cc) {
            $indexPath = $cc['absolutePath'] . '/index.xml.new';
            if (file_exists($indexPath)) {
                unlink($indexPath);
            }
        }
    }

    function commitChanges($comps, $repo) {
        foreach ($comps as $cc) {
            $indexPath = $cc['absolutePath'] . '/index.xml.new';
            $newName = $cc['absolutePath'] . '/index.xml';
            if (file_exists($indexPath)) {
                rename($indexPath, $newName);
            }
        }
        $fname = $repo['basePath'] . 'leerlijnen/components.xml.new';
        $fnameNew = $repo['basePath'] . 'leerlijnen/components.xml';
        rename($fname, $fnameNew);
    }

    function createComponentsFile($comps, $repo) {
        $doc = new SimpleXMLElement('<?xml version="1.0" encoding="UTF-8" ?><mathunited></mathunited>');
        $methodsNode = $doc->addChild('methods');

        $methodNode = $methodsNode->addChild('method');
        $methodNode->addAttribute("id", '');
        $methodNode->addChild('title', '');
        $componentsNode = $methodNode->addChild('components');
        foreach ($comps as $cc) {
            $this->addComponent($cc, $componentsNode, $repo);
        }

        $fname = $repo['basePath'] . 'leerlijnen/components.xml.new';
//        $fname = '/var/www/html/index/studiovo/components.xml.new';
        $this->logger->trace(LEVEL_INFO, "createComponentsFile $fname ".$fname);
        $doc->asXML($fname);
    }

    function addComponent($cc, $parent, $repo) {
        $compDoc = $this->openFile($cc["fullname"]);
        $metaDoc = $compDoc->metadata;
        $componentNode = $parent->addChild('component');
        $componentNode->addAttribute('id', $compDoc['id']);
        $componentNode->addAttribute('basePath', $repo['basePath']);
        $componentNode->addAttribute('file', $cc["relativePath"] . $cc["file"]);
        $componentNode->addChild('year', $metaDoc->year);
        if (strlen($compDoc->description->title) > 0) {
            $componentNode->addChild('title', $compDoc->description->title);
            $componentNode->addChild('subtitle', $compDoc->description->subtitle);
        } else {
            $componentNode->addChild('title', $compDoc->metadata->title);
            $componentNode->addChild('subtitle', $compDoc->metadata->subtitle);
        }
        if ($compDoc->description->number != null) {
            $componentNode->addAttribute('number', $compDoc->description->number);
        }
        $componentNode->addChild('schooltype', $metaDoc->schooltype);
        $stateNode = $componentNode->addChild('state');
        $stateNode->addAttribute('type', (string) $metaDoc->state['type']);
        $subNode = $componentNode->addChild('subcomponents');
        $subDoc = $compDoc->subcomponents;
        for ($kk = 0; $kk < count($subDoc->subcomponent); $kk++) {
             $s = $subDoc->subcomponent[$kk];
            $fname = (string)$s->file;
            //instaptoets, uitstaptoets en context mogen alleen voor Malmberg gepubliceerd worden
            if($repo['name']==="malmberg" || 
               (strpos($fname,"test")===FALSE && strpos($fname,"context")===FALSE)){
                $sc = $subNode->addChild('subcomponent');
                $sc->addAttribute('number', $s['number']);
                $sc->addAttribute('id', $s['id']);
                $sc->addChild('title', $s->title);
                $sc->addChild('file', $cc["relativePath"] . (string) $s->file);
            }
       }
    }

    function isAcceptedComponent($cc, $repoFilter, $yearFilter) {
        $isAccepted = count($repoFilter) == 0;
        for ($kk = 0; $kk < count($repoFilter); $kk++) {
            if (strcmp($cc["repo"], $repoFilter[$kk]) == 0) {
                $isAccepted = true;
                break;
            }
        }
        if (!$isAccepted)
            return false;

        $isAccepted = count($yearFilter) == 0;
        for ($kk = 0; $kk < count($yearFilter); $kk++) {
            if (strpos($cc["year"], $yearFilter[$kk]) !== false) {
                $isAccepted = true;
                break;
            }
        }
        return $isAccepted;
    }

    function findComponents($basePath, $subFolder, $iter) {
        $comps = array();
        $xmlFound = false;
        $path = $basePath . $subFolder;
        $folderArr = scandir($path);
        for ($jj = 0; $jj < count($folderArr); $jj++) {
            $file = $folderArr[$jj];
            $ii = strpos($file, ".xml");
            if ($ii > 0 && $ii == strlen($file) - 4 && $file != 'index.xml' && $file != 'entities.xml') {
                $xmlFound = true;
                $fullName = $path . $file;
                try {
                    $doc = $this->openFile($fullName);
                    $id = $doc->xpath("/component/@id");
                    $schooltype = $doc->xpath("/component/metadata/schooltype");
                    $year = $doc->xpath("/component/metadata/year");
                    $state = $doc->xpath("/component/metadata/state/@type");
                    $isValid = true;
                    //check if this is a component file
                    if (count($id) != 1) {
                        $isValid = false;
                    } else {
                        $id = (string) ($id[0]);
                    }
                    if (count($schooltype) != 1) {
                        $isValid = false;
                    } else {
                        $schooltype = (string) ($schooltype[0]);
                    }
                    if (count($year) != 1) {
                        $isValid = false;
                    } else {
                        $year = (string) ($year[0]);
                    }
                    if (count($state) != 1) {
                        $isValid = false;
                    } else {
                        $state = (string) ($state[0]);
                    }

                    $ii = strrpos($fullName, '/');
                    $parent = substr($fullName, 0, $ii);

                    if ($isValid) {
                        if (strcmp($state, "live") == 0) {
                            $cc = array(
                                "id" => $id,
                                "file" => $file,
                                "fullname" => $fullName,
                                "absolutePath" => $parent . '/',
                                "relativePath" => $subFolder,
                                "schooltype" => $schooltype,
                            );
                            array_push($comps, $cc);
                            echo "<li>$id</li>";
                            $this->logger->trace(LEVEL_INFO, "found component " . print_r($cc, true));
                        } else {
                            $this->logger->trace(LEVEL_INFO, "skipping $fullName because state is not 'live', but set to $state");
                        }
                    } else {
                        $this->logger->trace(LEVEL_ERROR, "Invalid component: $fullName");
                    }
                } catch (Exception $e) {
                    $this->logger->trace(LEVEL_ERROR, "When analyzing $fullName: " . $e->getMessage());
                }
            }
        }
        //no xml-file found, recurse into subdirectories
        if (!$xmlFound && $iter < 3) {
            for ($jj = 0; $jj < count($folderArr); $jj++) {
                $file = $folderArr[$jj];
                if ($file[0] != '.' && $file[0] != '_' && strcmp($file, 'leerlijnen') != 0) {
                    $fullName = $path . $file;
                    if (is_dir($fullName)) {
                        $cc = $this->findComponents($basePath, $subFolder . $file . '/', $iter + 1);
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