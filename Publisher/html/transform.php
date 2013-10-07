<html>
<head></head>
<body>
<div style="background-color:rgb(240,230,230);font-weight:bold;margin:10px 0px 10px 0px;">
<a href="../index.html">Terug naar auteurssite</a>
</div>
<h1>Beschikbare content</h1>
<?php
function writeComponents($fp, $basePath, $subFolder, $iter){
   $xmlFound = false;
   echo "<p>scanning: ".$basePath.$subFolder."</p><ul>";
   $path = $basePath.$subFolder;
   $folderArr = scandir($path);
   for($jj=0; $jj<count($folderArr);$jj++) {
      $file = $folderArr[$jj];
      if(strpos($file,".xml")==strlen($file)-4) {
         $xmlFound = true;
         $fullName = $path.$file;
         $ff = fopen($fullName,'r');
         $conts = fread($ff, filesize($fullName));
         fclose($ff);
         
         $indStart = strpos($conts, "<component")+10;
         $indEnd = strpos($conts, "</component>")+12;
         if($indStart>0 && $indEnd-$indStart>10){
             fwrite($fp, "<component basePath='$basePath' relativePath='$subFolder'".substr($conts, $indStart, $indEnd-$indStart));
             echo "<li>".$file."</li>";
         } else {
             echo "<li>".$file.": Kan begin-eind tag <component> niet vinden ($indStart, $indEnd)</li>";
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
                    writeComponents($fp, $basePath, $subFolder.$file.'/', $iter+1);
                }            
            }
        }       
   }
   echo "</ul>";
}
function createOverview($paths_ma, $paths_wm, $fname) {
  $fp = fopen('../tmp/comps-assembled.xml','w');
  fwrite($fp, '<?xml version="1.0" encoding="UTF-8" ?>');
  fwrite($fp, '<!DOCTYPE entities SYSTEM "../entities.xml">');
  fwrite($fp, '<mathunited><methods><method id="ma"><title>Math4All</title><components>');
  for($kk=0; $kk<count($paths_ma); $kk++) {
     writeComponents($fp, '/data/', $paths_ma[$kk], 0);  
  }
  fwrite($fp, '</components></method>');
  fwrite($fp, '<method id="wm"><title>Wageningse Methode</title><components>');
  for($kk=0; $kk<count($paths_wm); $kk++) {
     writeComponents($fp, '/data/', $paths_wm[$kk], 0);  
  }
  fwrite($fp, '</components></method>');
  fwrite($fp, '</methods></mathunited>');
  fclose($fp);

  echo "<h2>Begin xslt</h2>";
  $cmp='java -cp saxon9he.jar net.sf.saxon.Transform -t -s:../tmp/comps-assembled.xml -xsl:transform.xslt -o:/data/content-overview/'.$fname.' 2>&1';
  exec($cmp,$outp);
  for($ii=0;$ii<count($outp);$ii++){
     echo "$outp[$ii]<br/>";
  }
}

$paths_ma = array(
  'content-ma/concept/ha/',
  'content-ma/concept/hv/',
  'content-ma/concept/h3/',
  'content-ma/concept/v3/',
  'content-ma/concept/vb/vb-bb1/',
  'content-ma/concept/vb/vb-bb2'
);
$paths_wm = array(
  'content-wm/concept/lj1-hv/',
  'content-wm/concept/lj2-h/',
  'content-wm/concept/lj2-v/',
  'content-wm/concept/lj3-h/',
  'content-wm/concept/lj3-v/'
);
createOverview($paths_ma, $paths_wm, 'components.xml');
createOverview($paths_ma, array(), 'components-ma.xml');
createOverview(array(), $paths_wm, 'components-wm.xml');
$paths_ma = array(
  'content-ma/concept/hv/',
);
$paths_wm = array(
  'content-wm/concept/lj1-hv/',
);
createOverview($paths_ma, $paths_wm, 'components-jaar1.xml');
$paths_ma = array(
  'content-ma/concept/hv/',
);
$paths_wm = array(
  'content-wm/concept/lj2-h/',
  'content-wm/concept/lj2-v/',
);
createOverview($paths_ma, $paths_wm, 'components-jaar2.xml');

?>

</body>
</html>