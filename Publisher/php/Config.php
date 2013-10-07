<?php
$config_contentRoot = '/data/';
$config_repos = array(
    'm4a' => array(
        'id'=>'m4a',
        'basePath'=>'content-ma/concept/',
        'paths'=>array(
            'vb/','va/','v3/',
            'hv/',
            'h3/',
            'ha/',
            'hb/'
            ),
        'index_xsl'=>'../xslt/generate-index-ma.xslt',
        'get_QTI_url' => 'http://localhost:8080/MathUnited/view?repo=m4a&variant=m4a_view_pulseon&comp={#COMP}&subcomp={#SUBCOMP}'
    ),
    'm4a_en' => array(
        'id'=>'m4a_en',
        'basePath'=>'content-ma/saba/',
        'paths'=>array(
            'ha/',
            'hb/'
            ),
        'index_xsl'=>'../xslt/generate-index-ma_en.xslt'
    ),
    'wm' => array(
        'id'=>'wm',
        'basePath'=>'content-wm/concept/',
        'paths'=>array(
            'lj1-hv/',
            'lj2-h/',
            'lj2-v/',
            'lj3-h/',
            'lj3-v/'
            ),
        'index_xsl'=>'../xslt/generate-index-wm.xslt'
    ),
    'studiovo' => array(
        'id'=>'studiovo',
        'basePath'=>'content-studiovo/concept/',
        'paths'=>array(
            ''
            ),
        'index_xsl'=>false
    )
);


?>