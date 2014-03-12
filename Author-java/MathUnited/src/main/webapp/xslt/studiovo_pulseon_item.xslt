<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:exsl="http://exslt.org/common"
xmlns:saxon="http://saxon.sf.net/"
xmlns:mulom="http://www.mathunited.nl/nl-lom"
xmlns:cals="http://www.someplace.org/cals"
exclude-result-prefixes="saxon cals"
extension-element-prefixes="exsl">
<xsl:param name="item"/>
<xsl:param name="block"/>
<xsl:param name="fragment"/>
<xsl:param name="num"/>
<xsl:param name="refbase"/> <!-- used for includes: base path. Includes final / -->
<xsl:param name="ws_id"/>
<xsl:param name="comp"/>
<xsl:param name="option"/>
<xsl:param name="component"/>
<xsl:param name="subcomp"/>
<xsl:param name="is_mobile"/>
<xsl:param name="id"/>
<xsl:variable name="cm2px" select="number(50)"/>
<xsl:variable name="parsed_component" select="saxon:parse($component)"/>
<xsl:variable name="subcomponent" select="$parsed_component/component/subcomponents/subcomponent[@id=$subcomp]"/>
<xsl:variable name="variant">studiovo_pulseon_item</xsl:variable>
<xsl:variable name="intraLinkPrefix">
    <xsl:choose>
        <xsl:when test="$option">
            <xsl:value-of select="concat('view?repo=studiovo&amp;comp=',$comp,'&amp;variant=',$variant,'&amp;option=',$option,'&amp;subcomp=')"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="concat('view?repo=studiovo&amp;comp=',$comp,'&amp;variant=',$variant,'&amp;subcomp=')"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:variable>
<xsl:variable name="overviewRef"><xsl:value-of select="string('/auteur/math4all.html')"/></xsl:variable>

<!--   /////////////////////////////////////////////   -->
<!--  Specific for auteurssite:                        -->
<!--   /////////////////////////////////////////////   -->
<xsl:variable name="host_type">auteur</xsl:variable>
<xsl:variable name="docbase" select="$refbase"></xsl:variable>
<xsl:variable name="urlbase"><xsl:value-of select="concat('/data/',$refbase)"/></xsl:variable>
<!--   /////////////////////////////////////////////   -->
<!--   /////////////////////////////////////////////   -->

<xsl:variable name="_cross_ref_as_links_" select="true()"/>
<xsl:variable name="_sheetref_as_links_" select="true()"/>
<xsl:variable name="lang">nl</xsl:variable>

<xsl:output method="html" doctype-system="http://www.w3.org/TR/html4/strict.dtd" doctype-public="-//W3C//DTD HTML 4.01//EN"
indent="yes" encoding="utf-8"/>

<xsl:include href="calstable.xslt"/>
<xsl:include href="content.xslt"/>
<xsl:include href="exercises_qti_identity.xslt"/>

<!--   **************** -->
<!--   START PROCESSING -->
<!--   **************** -->
<xsl:template match="/">
<html>
<head>
   <link type="text/css" href="javascript/jquery-ui-1.8.15.custom/css/ui-lightness/jquery-ui-1.8.15.custom.css" rel="Stylesheet" />
   <script type="text/javascript" src="javascript/jquery-ui-1.8.15.custom/js/jquery-1.6.2.min.js"></script>
   <script type="text/javascript" src="javascript/jquery-ui-1.8.15.custom/js/jquery-ui-1.8.15.custom.min.js"></script>
   <script type="text/javascript" src="javascript/MathUnited.js"/>
   <script type="text/javascript" src="javascript/MathUnited_studiovo.js"/>
   <script type="text/javascript" src="javascript/jquery.ui.touch-punch.min.js"/>
   <script type="text/javascript" src="javascript/jquery.jplayer.min.js"/>
   <link rel="stylesheet" href="css/pulseon_studiovo.css" type="text/css"/>
   <link rel="stylesheet" href="css/content.css" type="text/css"/>
   <title><xsl:value-of select="$parsed_component/component/title"/></title>
   
   <link href="https://vjs.zencdn.net/c/video-js.css" rel="stylesheet"/>
   <script src="https://vjs.zencdn.net/c/video.js"></script>	

    <script type="text/x-mathjax-config">
        MathJax.Hub.Config({
            extensions: ["mml2jax.js","asciimath2jax.js"],
            config : ["MMLorHTML.js" ],
            AsciiMath: {
                decimal: ","
            },
            jax: ["input/MathML","input/AsciiMath"]
        });
    </script>
    <script type="text/javascript" src="https://c328740.ssl.cf1.rackcdn.com/mathjax/latest/MathJax.js">
    </script>

</head>

<!--   **************** -->
<!--        BODY        -->
<!--   **************** -->

    <xsl:variable name="phase1">
        <div id="content">
            <xsl:apply-templates select="subcomponent/componentcontent/*"/>
        </div>
    </xsl:variable>
    <xsl:variable name="lom-set">
        <lom-set>
            <xsl:copy-of select="document(concat($docbase, '../../../',$parsed_component/component/@file))/component/mulom:lom"/>
            <xsl:copy-of select="subcomponent/mulom:lom"/>
            <xsl:for-each select="$phase1//mulom:lom">
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </lom-set>
    </xsl:variable>

<body>
    <xsl:apply-templates select="$lom-set" mode="metadata"/>
    <xsl:apply-templates select="$phase1" mode="postprocess"/>
</body>
</html>
</xsl:template>


<!--  ******************* -->
<!--   metadata           -->
<!--  ******************* -->
<xsl:template match="lom-set" mode="metadata">
    <div class='lommetadata'>
        <xsl:variable name="description">
            <set>
                <xsl:for-each select="mulom:lom/mulom:educational/mulom:description[string-length()>0]">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </set>
        </xsl:variable>
        <xsl:variable name="difficulty">
            <set>
                <xsl:for-each select="mulom:lom/mulom:educational/mulom:difficulty[string-length()>0]">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </set>
        </xsl:variable>
        <xsl:variable name="learningResourceType">
            <set>
                <xsl:for-each select="mulom:lom/mulom:educational/mulom:learningResourceType[string-length()>0]">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </set>
        </xsl:variable>
        <xsl:variable name="interactivityLevel">
            <set>
                <xsl:for-each select="mulom:lom/mulom:educational/mulom:interactivityLevel[string-length()>0]">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </set>
        </xsl:variable>
        <xsl:variable name="semanticDensity">
            <set>
                <xsl:for-each select="mulom:lom/mulom:educational/mulom:semanticDensity[string-length()>0]">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </set>
        </xsl:variable>
        <xsl:variable name="typicallearningtime">
            <set>
                <xsl:for-each select="mulom:lom/mulom:educational/mulom:typicallearningtime[string-length()>0]">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </set>
        </xsl:variable>
        <xsl:variable name="language">
            <set>
                <xsl:for-each select="mulom:lom/mulom:educational/mulom:language[string-length()>0]">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </set>
        </xsl:variable>
        <xsl:variable name="intendedenduserrole">
            <set>
                <xsl:for-each select="mulom:lom/mulom:educational/mulom:intendedenduserrole[string-length()>0]">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </set>
        </xsl:variable>
        <xsl:variable name="context">
            <set>
                <xsl:for-each select="mulom:lom/mulom:educational/mulom:context[string-length()>0]">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </set>
        </xsl:variable>
        <xsl:variable name="keywords">
            <keywords>
                <xsl:for-each select="mulom:lom/mulom:general/mulom:keyword/mulom:langstring[string-length()>0]">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </keywords>
        </xsl:variable>
        <span class='description'><xsl:value-of select="$description/set/mulom:description[position()=last()]/text()"/></span>
        <span class='learningresourcetype'><xsl:value-of select="$learningResourceType/set/mulom:learningResourceType[position()=last()]/text()"/></span>
        <span class='difficulty'><xsl:value-of select="$difficulty/set/mulom:difficulty[position()=last()]/text()"/></span>
        <span class='interactivitylevel'><xsl:value-of select="$interactivityLevel/set/mulom:interactivityLevel[position()=last()]/text()"/></span>
        <span class='semanticdensity'><xsl:value-of select="$semanticDensity/set/mulom:semanticDensity[position()=last()]/text()"/></span>
        <span class='typicallearningtime'><xsl:value-of select="$typicallearningtime/set/mulom:typicallearningtime[position()=last()]/text()"/></span>
        <span class='intendedenduserrole'><xsl:value-of select="$intendedenduserrole/set/mulom:intendedenduserrole[position()=last()]/text()"/></span>
        <span class='language'><xsl:value-of select="$language/set/mulom:language[position()=last()]/text()"/></span>
        <span class='context'><xsl:value-of select="$context/set/mulom:context[position()=last()]/text()"/></span>
        <span class='keyword'>
            <xsl:for-each select="$keywords/keywords/mulom:langstring">
                <span class="langstring"><xsl:value-of select="text()"/></span>
            </xsl:for-each>
            <xsl:value-of select="$description/set/mulom:interactivityLevel[position()=last()]/text()"/>
        </span>
    </div>
    <div class="learningobjectives">
        <ul>
            <xsl:for-each select="mulom:lom/mulom:objectives/mulom:objective[string-length()>0]">
                <xsl:choose>
                    <xsl:when test="@type='obk'">
                        <li class="obkobjective"><xsl:value-of select="."/></li>
                    </xsl:when>
                    <xsl:otherwise>
                        <li class="objective"><xsl:value-of select="."/></li>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </ul>
    </div>
</xsl:template>
<!--  ******************* -->
<!--   remove lom data    -->
<!--  ******************* -->
<xsl:template match="node()|@*" mode="postprocess">
    <xsl:copy>
        <xsl:apply-templates select="node()|@*" mode="postprocess"/>
    </xsl:copy>
</xsl:template>
<xsl:template match="mulom:lom" mode="postprocess" priority="2"/>

<!--  ******************* -->
<!--   CONTENT STRUCTURE  -->
<!--  ******************* -->
<xsl:template match="fragment">
    <xsl:if test="1+count(preceding-sibling::fragment)=number($fragment)">
        <xsl:apply-templates select="*"/>
    </xsl:if>
</xsl:template>

<xsl:template match="block" priority="2">
    <xsl:if test="1+count(preceding-sibling::block)=number($block)">
        <div class="content-tab">
            <div class="header">
				<img>
			       <xsl:choose>
			          <xsl:when test="$host_type='GAE'">
			             <xsl:attribute name="src"><xsl:value-of select="/subcomponent/meta/param[@name='banner-image']"/></xsl:attribute>
			          </xsl:when>
			          <xsl:otherwise>
			             <xsl:attribute name="src"><xsl:value-of select="concat($urlbase, /subcomponent/meta/param[@name='banner-image']/resource/name)"/></xsl:attribute>
			          </xsl:otherwise>
			       </xsl:choose>
			   </img>
            </div>
            <div class="ribbon">
                <div class="left-title">
                <span class="subcomponent-title"><xsl:value-of select="$subcomponent/title"/></span>
                |
                <span class="fragment-title"><xsl:value-of select="title"/></span>
                </div>
                <span class="component-title"><xsl:value-of select="$parsed_component/component/title"/></span>
            </div>

            <xsl:apply-templates mode="content"/>
        </div>
    </xsl:if>
</xsl:template>

<xsl:template match="block/title" mode="content" priority="2"></xsl:template>
<xsl:template match="include" mode="content">
    <xsl:apply-templates select="document(concat($docbase,@filename))" mode="content"/>
</xsl:template>



<xsl:template match="p">
    <xsl:apply-templates mode="content"/>
</xsl:template>

<xsl:template match="textref" mode="content">
    <xsl:choose>
        <xsl:when test="@ref">
            <span class="textref" ref="{@ref}"><xsl:value-of select="."/></span>
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="_comp">
                <xsl:choose>
                    <xsl:when test="@comp"><xsl:value-of select="@comp"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="$comp"/></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="_subcomp">
                <xsl:choose>
                    <xsl:when test="@subcomp"><xsl:value-of select="@subcomp"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="$subcomp"/></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <xsl:choose>
                <xsl:when test="$_cross_ref_as_links_">
                    <a class="textref" item="{@item}">
                        <xsl:attribute name="href"><xsl:value-of select="concat('view?repo=studiovo&amp;comp=',$_comp,'&amp;subcomp=',$_subcomp,'&amp;variant=studiovo_pulseon')"/></xsl:attribute>
                        <xsl:value-of select="."/>

                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <span class="textref" item="{@item}">
                        <xsl:value-of select="."/>
                    </span>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
<xsl:template match="pages" mode="content">
    <xsl:apply-templates select="page" mode="content"/>
<!--    
    <div class="pages-container">
        <xsl:apply-templates select="page" mode="content"/>
    </div>
-->    
</xsl:template>
<xsl:template match="page" mode="content">
    <div class="page">
        <xsl:apply-templates mode="content"/>
    </div>
<!--
    <xsl:variable name="pos" select="position()"/>
    <div num="{$pos}">
        <xsl:choose>
            <xsl:when test="$pos=1">
                <xsl:attribute name="class">page selected</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="class">page</xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates mode="content"/>
        <div class="page-navigator">
            <xsl:for-each select="preceding-sibling::page">
                <div class="page-navigator-ref" onclick="javascript:togglePage(this)"><xsl:value-of select="position()"/></div>
            </xsl:for-each>
            <div class="page-navigator-ref selected"><xsl:value-of select="$pos"/></div>
            <xsl:for-each select="following-sibling::page">
                <div class="page-navigator-ref" onclick="javascript:togglePage(this)"><xsl:value-of select="$pos+position()"/></div>
            </xsl:for-each>
            <div style="clear:both"/>
        </div>
    </div>
-->    
</xsl:template>
<xsl:template match='block[@medium="web"]'><xsl:apply-templates/></xsl:template>

<!--  ******************** -->
<!--   EXERCISES (NON-QTI  -->
<!--  ******************** -->
<xsl:template match="exercise">
    <xsl:param name="menuref"/>
<!--    
    <div class="content-tab" id="{concat('tab-',$menuref,'-',position())}">
        <xsl:apply-templates select="." mode="content"/>
    </div>
-->
        <xsl:apply-templates select="." mode="content"/>

</xsl:template>
<xsl:template match="exercise-sequence" mode="content">
    <div class="exercise-sequence">
        <xsl:for-each select="*">
            <xsl:variable name="pos" select="position()"/>
            <div nr="{position()}">
                <xsl:choose>
                    <xsl:when test="$pos=1">
                        <xsl:attribute name="class">exercise-seq-item selected</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="class">exercise-seq-item</xsl:attribute>                        
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="." mode="content"/>
            </div>
        </xsl:for-each>
    </div>
</xsl:template>
<xsl:template match="exercise" mode="content">
    <div class="exercise">
        <xsl:if test="@width">
            <xsl:attribute name="style">width:<xsl:value-of select="@width"/>px</xsl:attribute>
        </xsl:if>
        <xsl:apply-templates mode="content"/>
        <div class="exercise-completed">klaar!</div>
    </div>
</xsl:template>

<xsl:template match="multi-item" mode="content">
    <div class="exercise-multi-item">
        <xsl:apply-templates select="items/item" mode="content"/>
    </div>
</xsl:template>

<xsl:template match="item" mode="content">
    <xsl:variable name="pos" select="position()"/>
    <div>
        <xsl:choose>
            <xsl:when test="$pos=1">
                <xsl:attribute name="class">exercise-item selected</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="class">exercise-item</xsl:attribute>                        
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="." mode="exercise-item"/>
    </div>
</xsl:template>
<xsl:template match="item[@type='closed']" mode="exercise-item">
    <div class="choice-exercise-question">
        <xsl:apply-templates select="itemcontent/itemintro/*" mode="content"/>
    </div>
    <xsl:for-each select="alternatives/alternative">
        <div class="choice-exercise-option">
            <xsl:if test="@state='yes'">
                <xsl:attribute name="state">yes</xsl:attribute>
            </xsl:if>
            <div class="choise-exercise-label" onclick="javascript:choiceLabelClick(this)"/>
            <xsl:apply-templates select="*" mode="content"/>
        </div>
    </xsl:for-each>
    <div style="clear:left"/>
    <div class="item-completed" onclick="javascript:nextItem(this)"></div>
</xsl:template>

<xsl:template match="item[@type='dragtexttotext']" mode="exercise-item">
    <div class="exercise-item-drop">
        <xsl:if test="itemcontent/intro">
            <div class="exercise-drop-intro">
                <xsl:apply-templates select="itemcontent/intro" mode="content"/>
            </div>
        </xsl:if>
        <div class="exercise-drop-text">
           <xsl:apply-templates select="itemcontent/question" mode="content"/>
        </div>
        <div class="exercise-drop-cells">
            <xsl:for-each select="itemcontent/question//drop-item">
                <xsl:sort select="."/>
                <div class="exercise-drop-cell" nr="{count(preceding-sibling::drop-item)+1}">
                    <xsl:value-of select="."/>
                </div>
            </xsl:for-each>
        </div>
    </div>
</xsl:template>
<xsl:template match="drop-item" mode="content">
    <span class="drop-item" nr="{count(preceding-sibling::drop-item)+1}"></span>
</xsl:template>


<!-- overrule default in content.xslt: images are in folder of xml content -->
<xsl:template match="resource" mode="content" priority="2">
   <xsl:variable name="width" select="number(substring-before(width,'cm'))*$cm2px"/>
   <img>
       <xsl:choose>
          <xsl:when test="$host_type='GAE'">
             <xsl:attribute name="src"><xsl:value-of select="name"/></xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
             <xsl:attribute name="src"><xsl:value-of select="concat($urlbase,name)"/></xsl:attribute>
          </xsl:otherwise>
       </xsl:choose>
       <xsl:if test="$width>0">
           <xsl:attribute name="style">width:<xsl:value-of select="$width"/>px</xsl:attribute>
       </xsl:if>
   </img>
</xsl:template>

<!--  ******************** -->
<!--   EXERCISES (QTI)     -->
<!--  ******************** -->
<xsl:template match="assessment" mode="content">
    <iframe>
        <xsl:choose>
            <xsl:when test="@width"><xsl:attribute name="width" select="@width"/></xsl:when>
            <xsl:otherwise><xsl:attribute name="width" select="495"/></xsl:otherwise>
        </xsl:choose>    
        <xsl:choose>
            <xsl:when test="@height"><xsl:attribute name="height" select="@height"/></xsl:when>
            <xsl:otherwise><xsl:attribute name="height" select="300"/></xsl:otherwise>
        </xsl:choose>
        <xsl:variable name="dowindow"><xsl:choose>
                <xsl:when test="@display='popup'">true</xsl:when>
                <xsl:otherwise>false</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:attribute name="src" select="concat('https://demo.pulseon.nl/qt/player.html?testId=',@src,'&amp;lang=nl-NL&amp;window=',$dowindow)"/>
        <xsl:apply-templates mode="content"/>
    </iframe>
</xsl:template>
  
<xsl:template match="movie" mode="content" priority="2">
    <div class="movie-wrapper">
        <xsl:if test="@optional='true'">
            <img src="/MathUnited/sources/movie_icon_60.gif" class="studiovo-movie-icon" style="height:1.5em;position:relative;top:5px;cursor:pointer;" onclick="javascript:toggleMovie(this)"/>
            <span class="movie-title" style="padding:0px 0px 0px 10px;"><xsl:value-of select="@title"/></span>
        </xsl:if>
        <div>
            <xsl:choose>
                <xsl:when test="@optional='true'">
                    <xsl:attribute name="class">movie optional</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">movie</xsl:attribute>                    
                </xsl:otherwise>
            </xsl:choose>
            <xsl:attribute name="style">width:<xsl:value-of select="@width"/>px;height:<xsl:value-of select="@height"/>px;</xsl:attribute>
            <xsl:choose>
                <xsl:when test="substring(@href,1,18) = 'http://www.youtube' or substring(@href,1,14) = 'http://youtube' or substring(@href,1,19) = 'https://www.youtube' or substring(@href,1,15) = 'https://youtube'">
                    <iframe frameborder="0" allowfullscreen="true">
                        <xsl:attribute name="height"><xsl:value-of select="@height"/></xsl:attribute>
                        <xsl:attribute name="width"><xsl:value-of select="@width"/></xsl:attribute>
                        <xsl:attribute name="src"><xsl:value-of select="@href"/></xsl:attribute>
                    </iframe>
                </xsl:when>
                <xsl:otherwise>
                    <video id="{generate-id()}" class="video-js vjs-default-skin" 
                            width="{@width}" height="{@height}"
                            controls="true">
                            <source src="{concat($urlbase,@href)}" type='video/mp4'/>
                    </video>
                    <div style="clear:both"/>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </div>
</xsl:template>

<xsl:template match="audio" mode="content" priority="2">
    <div class="movie">
        <audio id="{generate-id()}" class="video-js vjs-default-skin" 
                width="{@width}" height="{@height}"
                controls="true">
                <source src="{concat($urlbase,@href)}" type='audio/mp3'/>
        </audio>
    </div>
</xsl:template>

<xsl:template match="a" mode="content">
    <a>
        <xsl:for-each select="@*[name()!='target']"><xsl:copy/></xsl:for-each>
        <xsl:apply-templates mode="content"/>
    </a>
</xsl:template>
  
<xsl:template match="iframe" mode="content" priority="1">
    <iframe scrolling="no">
        <xsl:choose>
            <xsl:when test="starts-with(@src,'http://') or starts-with(@src,'https://')">
                <xsl:copy-of select="@*[name()!='src']"/>
                <xsl:attribute name="src" select="replace(@src, 'http://', 'https://')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="@*[name()!='src']"/>
                <xsl:attribute name="src" select="concat($urlbase, '../html/', @src)"/>
            </xsl:otherwise>
        </xsl:choose>
    </iframe>
</xsl:template>

<xsl:template match="*"/>
<xsl:template match="*" mode="navigation"/>
</xsl:stylesheet>
