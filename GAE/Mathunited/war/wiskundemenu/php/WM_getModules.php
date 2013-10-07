<?php
require("WM_base.php");

class GetModules extends Server {
    function GetModules() {
       $this->Server();
    }

    function executeImpl() {
        $error = false;

        //get parameters
        //---------------
        $addr = $_SERVER["REMOTE_ADDR"];
        if( $addr!="195.240.1.63"  &&  $addr!="131.155.68.108" )  {
            $logline = date('l jS \of F Y h:i:s A',$_SERVER["REQUEST_TIME"]).": ".$_SERVER["REMOTE_ADDR"];
            if( isset($this->comm['referer'] )) {
                $logline = $logline."  ".$this->comm['referer'];
            }
            $this->log($logline);
        }
        if($this->loglevel<=LEVEL_TRACE) {
           $this->trace(LEVEL_TRACE, "Entering getModules");
        }

        if( isset($this->comm['jaar'] )) {
           $jaar = $this->comm['jaar'];
           if($this->loglevel<=LEVEL_TRACE) {
              $this->trace(LEVEL_TRACE, "-- leerjaar = $jaar");
           }
        } else {
           $this->trace(LEVEL_TRACE, "Geen leerjaar meegegeven in getModules()");
        }

        if( isset($this->comm['niveau'] )) {
           $niveau = $this->comm['niveau'];
           if($this->loglevel<=LEVEL_TRACE) {
              $this->trace(LEVEL_TRACE, "-- niveau = $niveau");
           }
        } else {
           $this->trace(LEVEL_TRACE, "Geen niveau meegegeven in getModules()");
        }

        if( isset($this->comm['collectie'] )) {
           $collectie = $this->comm['collectie'];
           if($this->loglevel<=LEVEL_TRACE) {
              $this->trace(LEVEL_TRACE, "-- collectie = $collectie");
           }
        } else {
           $error = true;
           $this->trace(LEVEL_ERROR, "Geen collectie meegegeven in getModules()");
        }

        //first get all modules for leerlijn and leerjaar
        //-----------------------------------------------
        if(!$error) {
            $whereStr=null;
            if($jaar) {
                $whereStr="WHERE module.leerjaar=$jaar ";
            }
            if($niveau) {
                if($whereStr==null) {
                    $whereStr="WHERE module.niveau=$niveau ";
                } else {
                    $whereStr=$whereStr."AND module.niveau=$niveau ";
                }
            }
            if($collectie) {
                $colarr = explode(',',$collectie);
                $colfilter=null;
                foreach($colarr as $col) {
                    if($collfilter==null) {
                        $collfilter="module.collectie=$col ";
                    } else{
                        $collfilter=$collfilter."OR module.collectie=$col ";
                    }
                }
                if($whereStr==null) {
                    $whereStr="WHERE $collfilter ";
                } else {
                    $whereStr=$whereStr."AND $collfilter ";
                }
            }
            $query = "SELECT module.id, module.name, module.url, module.collectie, module.leerjaar, leerlijn.name AS lijn_name, leerlijn.id AS lijn_id FROM module INNER JOIN module_leerlijn ON module.id=module_leerlijn.module INNER JOIN leerlijn ON module_leerlijn.leerlijn=leerlijn.id ".$whereStr;
            $this->trace(LEVEL_TRACE, "query: ".$query);
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
                    $mods[] = $rec;
                }
            } else {
                $this->trace(LEVEL_ERROR, "No modules found for niveau=$niveau, collectie=$collectie and leerjaar=$jaar");
            }
        }
        if($sql) $sql->free();

        //now get all preconditions
        //-----------------------------------------------
        if(!$error) {
            $query = "SELECT preconditie.module, preconditie.premodule FROM preconditie INNER JOIN module ON module.id=preconditie.module $whereStr";
            $this->trace(LEVEL_TRACE, "query: ".$query);
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
                    $preconds[] = $rec;
                }
            } else {
                $this->trace(LEVEL_ERROR, "No modules found for leerlijn=$lijn and leerjaar=$jaar");
            }
        }
        if($sql) $sql->free();



        if(!$error) {
            foreach($mods as $mod) {
                $res=array('modules'=>$mods, 'preconditions'=>$preconds);
            }
        }

        if($error) {
             return null;
        }
        return json_encode($res);

    }

}


$serv = new GetModules();
$serv->execute();

?>

