<?php
//This class retrieves the general config settings from the MathUnited application
//and adds the Publisher-specific config settings.
class Config {
    static $repo_data = array(
        'm4a' => array(
            'id'=>'m4a',
            'paths'=>array(
                'vb/','va/','v3/',
                'hv/',
                'h3/',
                'ha/',
                'hb/'
                ),
            'index_xsl'=>'../xslt/generate-index-ma.xslt',
    //        'get_QTI_url' => 'http://mathunited.nl/view?repo=m4a&variant=m4a_view_pulseon&comp={#COMP}&subcomp={#SUBCOMP}'
            'get_QTI_url' => 'http://localhost:8080/MathUnited/view?repo=m4a&variant=m4a_view_pulseon&comp={#COMP}&subcomp={#SUBCOMP}'
        ),
        'malmberg' => array(
            'id'=>'malmberg-2013-07-19',
            'paths'=>array(
                ''
                ),
            'index_xsl'=>'../xslt/generate-index-ma.xslt'
        ),
        'm4a_en' => array(
            'id'=>'m4a_en-2013-07-19',
            'paths'=>array(
                'ha/',
                'hb/'
                ),
            'index_xsl'=>'../xslt/generate-index-ma_en.xslt'
        ),
        'wm' => array(
            'id'=>'wm-2013-07-19',
            'paths'=>array(
                ''
                ),
            'index_xsl'=>'../xslt/generate-index-wm.xslt'
        ),
        'studiovo' => array(
            'id'=>'studiovo-2013-07-19',
            'paths'=>array(
                ''
                ),
            'index_xsl'=>false
        ),
        'studiovo_kennisbank' => array(
            'id'=>'studiovo-kennisbank-2013-12-29',
            'paths'=>array(
                ''
                ),
            'index_xsl'=>false
        )
    );
     

    static function getRepoConfig($repoName) {
        $conf = Config::$repo_data;  //in php this is a copy, not a reference. So save to modify
        $confXML = Config::getRepoFromMathunited($repoName);
        $conf['basePath'] = $confXML->path;
        return $conf;
    }
    static function getRepoFromMathunited($repoName) {
        //get config data from servlet
        $ch = curl_init("http://localhost/MathUnited/repoconfig?repo=$repoName");
        curl_setopt($ch, CURLOPT_HEADER, 0);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $result = curl_exec($ch);
        curl_close($ch);
        $conf = new SimpleXMLElement($result);
        return $conf;
    }
}


?>