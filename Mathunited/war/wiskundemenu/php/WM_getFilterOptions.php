<?php
require("WM_base.php");

class GetFilterOptions extends Server {
    function GetFilterOptions() {
       $this->Server();
    }

    function executeImpl() {
        $error = false;

        //get parameters
        //---------------
        if($this->loglevel<=LEVEL_TRACE) {
           $this->trace(LEVEL_TRACE, "Entering getFilterOptions");
        }

        //get all possibilities for leerjaar
        if(!$error) {
            $query = "SELECT DISTINCT leerjaar FROM module";
            $sql = $this->mysql->query($query);
            if (!$sql) {
                $this->trace(LEVEL_ERROR, "Could not successfully run query ($sql) from DB: " . $this->mysql->error);
                $error = true;
            }
        }
        if(!$error) {
            $nbrows = $sql->num_rows;
            if($nbrows>0){
                while($rec = $sql->fetch_assoc()){
                    $jaar[] = $rec;
                }
            } else {
                $this->trace(LEVEL_ERROR, "No records returned from database while processing query:",$query);
            }
        }
        if($sql) $sql->free();

        //get all possibilities for niveau
        if(!$error) {
            $query = "SELECT * FROM niveau";
            $sql = $this->mysql->query($query);
            if (!$sql) {
                $this->trace(LEVEL_ERROR, "Could not successfully run query ($sql) from DB: " . $this->mysql->error);
                $error = true;
            }
        }
        if(!$error) {
            $nbrows = $sql->num_rows;
            if($nbrows>0){
                while($rec = $sql->fetch_assoc()){
                    $niveau[] = $rec;
                }
            } else {
                $this->trace(LEVEL_ERROR, "No records returned from database while processing query:",$query);
            }
        }
        if($sql) $sql->free();

        //get all possibilities for collections
        if(!$error) {
            $query = "SELECT * FROM collection";
            $sql = $this->mysql->query($query);
            if (!$sql) {
                $this->trace(LEVEL_ERROR, "Could not successfully run query ($sql) from DB: " . $this->mysql->error);
                $error = true;
            }
        }
        if(!$error) {
            $nbrows = $sql->num_rows;
            if($nbrows>0){
                while($rec = $sql->fetch_assoc()){
                    $collection[] = $rec;
                }
            } else {
                $this->trace(LEVEL_ERROR, "No records returned from database while processing query:",$query);
            }
        }
        if($sql) $sql->free();


        if(!$error) {
            $res=array('jaar'=>$jaar, 'niveau'=>$niveau, 'collectie'=>$collection);
        }

        if($error) {
             return null;
        }
        return json_encode($res);

    }

}


$serv = new GetFilterOptions();
$serv->execute();

?>

