<?php
$repoID = 'generic';
if( isset($_GET['repo']) ) {
    $repoID = $_GET['repo'];
}
$fp = fopen("../logs/log_$repoID.txt","w");
fclose($fp);


?>