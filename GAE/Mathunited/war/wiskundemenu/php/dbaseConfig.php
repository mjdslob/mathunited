<?
function connect_to_db($fp) {
    $dburl="127.0.0.1";
    $dbuser="ackznebd";
    $dbpass="PlafonD";
    $dbtable="ackznebd_wismenu";

    $link = new mysqli("$dburl","$dbuser","$dbpass","$dbtable");
    if(mysqli_connect_errno())
    {
        frwite($fp,'Fout bij verbinding: '.$mysqli->error);
    }
   return $link;
}


?>
