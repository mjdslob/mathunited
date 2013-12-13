<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:saxon="http://saxon.sf.net/"
xmlns:exsl="http://exslt.org/common"
xmlns:m="http://www.w3.org/1998/Math/MathML"
xmlns:cals="http://www.someplace.org/cals"
exclude-result-prefixes="saxon cals"
extension-element-prefixes="exsl">

<xsl:param name="item"/>
<xsl:param name="num"/>
<xsl:param name="ws_id"/>   <!-- is of worksheet, if applicable -->
<xsl:param name="comp"/>    <!-- id of component. Not needed as complete xml of component is given in $component-->
<xsl:param name="subcomp"/> <!-- id of subcomponent, eg hv-me11 -->
<xsl:param name="option"/>
<xsl:param name="parent"/>  <!-- eg.: mathunited.nl/wiskundemenu/WM_overview.html -->
<xsl:param name="is_mobile"/>
<xsl:param name="id"/>
<xsl:param name="component"/>
<xsl:variable name="parsed_component" select="saxon:parse($component)"/>
<xsl:variable name="subcomponent" select="$parsed_component/component/subcomponents/subcomponent[@id=$subcomp]"/>
<xsl:param name="refbase"/> <!-- used for includes: base path. Includes final / -->
<xsl:variable name="lang">nl</xsl:variable>

<!--   /////////////////////////////////////////////   -->
<!--  Specific for auteurssite (do not copy from GAE): -->
<!--   /////////////////////////////////////////////   -->
<xsl:param name="repo"/>
<xsl:variable name="host_type">auteur</xsl:variable>
<xsl:variable name="docbase" select="$refbase"></xsl:variable>
<xsl:variable name="urlbase"><xsl:value-of select="concat('../data/',$refbase)"/></xsl:variable>
<xsl:variable name="indexDoc" select="document(concat($refbase,'../index.xml'))"/>
<xsl:template match="subcomponent" mode="numbering">
    <xsl:copy>
        <xsl:apply-templates select="@*" mode="numbering"/>
        <internal-meta>
            <subcomponents>
                <xsl:for-each select="$indexDoc/index/component[@id=$comp]/subcomponent">
                    <subcomponent id="{@id}" _nr="{@_nr}"/>
                </xsl:for-each>
            </subcomponents>
        </internal-meta>
        <xsl:apply-templates mode="numbering"/>
    </xsl:copy>
</xsl:template>
<xsl:template match="textref" mode="content">
    <xsl:variable name="ref">
        <xsl:choose>
            <xsl:when test="@ref"><xsl:value-of select="@ref"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="@item"/></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:choose>
        <xsl:when test="$indexDoc/index/component[@id=$parsed_component/component/@id]//*[@id=$ref]">
            <span class="textref">
                <xsl:value-of select="."/>&#160;<xsl:value-of select="$indexDoc/index/component[@id=$parsed_component/component/@id]//*[@id=$ref]/@_nr"/>
            </span>
        </xsl:when>
        <xsl:otherwise>
            <span class="textref">
                <xsl:apply-templates select="@*|node()" mode="content"/>
            </span>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!--   /////////////////////////////////////////////   -->
<!--   /////////////////////////////////////////////   -->

<xsl:variable name="itemInner">
    <xsl:choose>
        <xsl:when test="string-length($id) > 0"><xsl:value-of select="name(subcomponent/componentcontent/*[descendant::include[@filename=concat($id,'.xml')]])"/></xsl:when>
        <xsl:when test="$item=''"><xsl:value-of select="name(subcomponent/componentcontent/*[1])"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="$item"/></xsl:otherwise>
    </xsl:choose>
</xsl:variable>
<xsl:variable name="cm2px" select="number(50)"/>
<xsl:variable name="variant">m4a_view</xsl:variable>
<xsl:variable name="arg_option">
    <xsl:choose>
        <xsl:when test="$option">&amp;option=<xsl:value-of select="$option"/></xsl:when>
        <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
</xsl:variable>
<xsl:variable name="arg_parent">
    <xsl:choose>
        <xsl:when test="$parent">&amp;parent=<xsl:value-of select="$parent"/></xsl:when>
        <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
</xsl:variable>
<xsl:variable name="arg_repo">
    <xsl:choose>
        <xsl:when test="$repo">&amp;repo=<xsl:value-of select="$repo"/></xsl:when>
        <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
</xsl:variable>
<xsl:variable name="intraLinkPrefix">
    <xsl:value-of select="concat('view?comp=',$comp,'&amp;subcomp=',$subcomp,'&amp;variant=',$variant,$arg_option,$arg_parent,$arg_repo,'&amp;item=')"/>
</xsl:variable>
<xsl:variable name="overviewRef">
    <xsl:choose>
       <xsl:when test="$parent">
	    <xsl:value-of select="concat('http://',replace($parent,'\^','&amp;'))"/>
       </xsl:when>
       <xsl:otherwise>
	    <xsl:value-of select="string('/wiskundemenu/WM_overview.html?tab=TabLeerlijn')"/>
       </xsl:otherwise>
    </xsl:choose>
</xsl:variable>
<xsl:variable name="_cross_ref_as_links_" select="true()"/>
<xsl:variable name="_sheetref_as_links_" select="true()"/>

<xsl:output method="html" doctype-system="http://www.w3.org/TR/html4/strict.dtd" doctype-public="-//W3C//DTD HTML 4.01//EN"
indent="yes" encoding="utf-8"/>

<xsl:include href="tabulate.xslt"/>
<xsl:include href="calstable.xslt"/>
<xsl:include href="exercises.xslt"/>
<xsl:include href="content.xslt"/>
<xsl:include href="worksheet.xslt"/>

<!--   **************** -->
<!--   PRE PROCESS      -->
<!--   **************** -->
<xsl:template match="/">
    <xsl:variable name="xml">
        <xsl:apply-templates mode="numbering"/>
    </xsl:variable>
    <xsl:apply-templates select="$xml" mode="process"/>
</xsl:template>
<xsl:template match="exercises/include" mode="numbering">
    <include>
        <xsl:attribute name="filename" select="@filename"/>
        <xsl:attribute name="num" select="1+count(preceding::explore/include)+count(preceding-sibling::include)+count(preceding::exercises/include)+count(preceding::exercises/block[@medium='web']/include)"/>
    </include>
</xsl:template>
<xsl:template match="exercises/block[@medium='web']/include" mode="numbering">
    <include>
        <xsl:attribute name="filename" select="@filename"/>
        <xsl:attribute name="num" select="1+count(preceding-sibling::include)+count(preceding::explore/include)+count(preceding::exercises/block[@medium='web']/include)"/>
    </include>
</xsl:template>
<xsl:template match="examples/include" mode="numbering">
    <include>
        <xsl:attribute name="filename" select="@filename"/>
        <xsl:attribute name="num" select="1+count(preceding::examples/include)"/>
    </include>
</xsl:template>


<xsl:template match="@*|node()" mode="numbering">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="numbering"/>
    </xsl:copy>
</xsl:template>

<!--   **************** -->
<!--   START PROCESSING -->
<!--   **************** -->
<xsl:template match="/" mode="process" >
<html  xmlns:m="http://www.w3.org/1998/Math/MathML">
<head>
   <xsl:choose>
      <!--  subtitle difference in references: leading slash or not -->
      <xsl:when test="$host_type='GAE'">
		   <link type="text/css" href="/javascript/jquery-ui-1.8.15.custom/css/ui-lightness/jquery-ui-1.8.15.custom.css" rel="Stylesheet" />
		   <script type="text/javascript" src="/javascript/jquery-ui-1.8.15.custom/js/jquery-1.6.2.min.js"></script>
		   <script type="text/javascript" src="/javascript/jquery-ui-1.8.15.custom/js/jquery-ui-1.8.15.custom.min.js"></script>
		   <script type="text/x-mathjax-config">
		      MathJax.Hub.Config({
		           extensions: ["mml2jax.js","asciimath2jax.js"],
		           config : ["MMLorHTML.js" ],
		           AsciiMath: {
		                decimal: ","
		           },
		           jax: ["input/MathML","input/AsciiMath"],
                           "HTML-CSS": {
                                availableFonts: [],
                                preferredFont: "TeX",
                                webFont: "",
                                imageFont: "",
                                undefinedFamily: "'Arial Unicode MS','sans-serif'",
                                scale: 80
                           }
		      });
                   </script>
		   <script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js">
		   </script>
		   <script type="text/javascript" src="/javascript/MathUnited.js"/>
		   <script type="text/javascript" src="/javascript/MathUnited_m4a.js"/>
		   <link rel="stylesheet" href="/css/content.css" type="text/css"/>
		   <link rel="stylesheet" href="/css/exercises.css" type="text/css"/>
		   <link rel="stylesheet" href="/css/M4AStijl2.css" type="text/css"/>
      </xsl:when>
      <xsl:otherwise>
		   <link type="text/css" href="javascript/jquery-ui-1.8.15.custom/css/ui-lightness/jquery-ui-1.8.15.custom.css" rel="Stylesheet" />
		   <script type="text/javascript" src="javascript/jquery-ui-1.8.15.custom/js/jquery-1.6.2.min.js"></script>
		   <script type="text/javascript" src="javascript/jquery-ui-1.8.15.custom/js/jquery-ui-1.8.15.custom.min.js"></script>
		   <script type="text/x-mathjax-config">
		      MathJax.Hub.Config({
		           extensions: ["mml2jax.js","asciimath2jax.js"],
		           config : ["MMLorHTML.js" ],
		           AsciiMath: {
		                decimal: ","
		           },
		           jax: ["input/MathML","input/AsciiMath"],
                           "HTML-CSS": {
                                scale: 90
                           }
		      });
		   </script>
		   <script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js">
		   </script>
		   <script type="text/javascript" src="javascript/MathUnited.js"/>
		   <script type="text/javascript" src="javascript/MathUnited_m4a.js"/>
		   <link rel="stylesheet" href="css/content.css" type="text/css"/>
		   <link rel="stylesheet" href="css/exercises.css" type="text/css"/>
		   <link rel="stylesheet" href="css/M4AStijl2.css" type="text/css"/>
		   <link rel="stylesheet" href="/AlgebraKIT/css/StepPanel.css" type="text/css"/>
		   <link rel="stylesheet" href="/AlgebraKIT/css/AKIT-Exercise.css" type="text/css"/>
                   <script data-main="/AlgebraKIT/js/main.js" src="/AlgebraKIT/js/require.js"></script>
      </xsl:otherwise>
   </xsl:choose>

   <title><xsl:value-of select="$parsed_component/component/title"/></title>
</head>

<!--   **************** -->
<!--        BODY        -->
<!--   **************** -->
<body>
<!-- 
<xsl:if test="$host_type='GAE'">
<div id="prikbord-div">
	<a>
	   <xsl:attribute name="href"><xsl:value-of select="$prikbord-url"/></xsl:attribute>
	   Prikbord
	</a>
</div>
</xsl:if>
-->
<div class="pageDiv">
    <xsl:choose>
        <xsl:when test="contains($option,'slechtziend')">
            <xsl:attribute name="class">pageDiv sizeB</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
            <xsl:attribute name="class">pageDiv</xsl:attribute>
        </xsl:otherwise>            
    </xsl:choose>
<div class="headingDiv">
    <div class="headingContentDiv">
        <img class="logo" src="sources_ma/LogoM4Ainvlak.gif" align="middle"  height="33" border="0"/>
        <xsl:if test="$is_mobile='true'">
            (m)
        </xsl:if>
        <xsl:value-of select="$parsed_component/component/title"/> &gt; <xsl:value-of select="$subcomponent/title"/>
    </div>
    <div class="overzichtDiv">
        <a>
              <xsl:attribute name="href"><xsl:value-of select="$overviewRef"/></xsl:attribute>Overzicht
        </a>
    </div>
    <div style="clear:both"/>
</div>
<div class="sectionDiv">
   <div class="balk">
       <xsl:call-template name="list-section-nrs">
           <xsl:with-param name="i"><xsl:value-of select="number(1)"/></xsl:with-param>
           <xsl:with-param name="count"><xsl:value-of select="count($parsed_component/component/subcomponents/subcomponent)"/></xsl:with-param>
           <xsl:with-param name="highlight"><xsl:value-of select="1+count($subcomponent/preceding-sibling::subcomponent)"/></xsl:with-param>
           <xsl:with-param name="subcomponents" select="subcomponent/internal-meta/subcomponents"/>
       </xsl:call-template>
       <span class="subcomponent-title"><xsl:value-of select="$subcomponent/title"/></span>
       <xsl:if test="contains($option, 'slechtziend')">
           <span class="font-selector"><span class="sizeA" onclick="javascript:MU_fontSelect(1)">A</span><span class="sizeB" onclick="javascript:MU_fontSelect(2)">A</span><span class="sizeC" onclick="javascript:MU_fontSelect(3)">A</span></span>
       </xsl:if>
   </div>
</div>
<div class="contentDiv">
<div class="contentDiv-content">
    <xsl:choose>
        <xsl:when test="string-length($ws_id) > 0">
            <xsl:choose>
                <xsl:when test="$itemInner='example' or $itemInner='theory'">
                    <xsl:apply-templates select="subcomponent/componentcontent/theory/examples[position()=number($num)]"  mode="worksheet"/>
                    <xsl:apply-templates select="subcomponent/componentcontent/theory/exercises[position()=number($num)]"  mode="worksheet"/>
                </xsl:when>
                <xsl:when test="$itemInner='explanation'">
                    <xsl:choose>
                        <xsl:when test="number($num) > 1">
                            <xsl:apply-templates select="subcomponent/componentcontent/explanation[count(preceding-sibling::explanation)=number($num)-1]"  mode="worksheet"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="subcomponent/componentcontent/explanation[count(preceding-sibling::explanation)=0]"  mode="worksheet"/>
                        </xsl:otherwise>

                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="subcomponent/componentcontent/*[name()=$itemInner]" mode="worksheet"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:when test="($itemInner='example' or $itemInner='theory') and $num">
            <xsl:apply-templates select="subcomponent/componentcontent/theory/examples[position()=number($num)]"/>
            <xsl:apply-templates select="subcomponent/componentcontent/theory/exercises[position()=number($num)]"/>
        </xsl:when>
        <xsl:when test="$itemInner='explanation'">
            <xsl:choose>
                <xsl:when test="number($num) > 1">
                    <xsl:apply-templates select="subcomponent/componentcontent/explanation[count(preceding-sibling::explanation)=number($num)-1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="subcomponent/componentcontent/explanation[count(preceding-sibling::explanation)=0]"/>
                </xsl:otherwise>

            </xsl:choose>
        </xsl:when>
        <xsl:when test="$itemInner='extra'">
            <xsl:choose>
                <xsl:when test="number($num) > 1">
                    <xsl:apply-templates select="subcomponent/componentcontent/extra[count(preceding-sibling::extra)=number($num)-1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="subcomponent/componentcontent/extra[count(preceding-sibling::extra)=0]"/>
                </xsl:otherwise>

            </xsl:choose>
        </xsl:when>
        <xsl:when test="$itemInner='answers'">
            <h2>Antwoorden van de opgaven</h2>
            <xsl:apply-templates select="subcomponent/componentcontent/explore | subcomponent/componentcontent//exercises">
                <xsl:with-param name="options">
                    <options>
                       <mode type="answers"/>
                    </options>
                </xsl:with-param>
            </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
           <xsl:apply-templates select="subcomponent/componentcontent/*[name()=$itemInner]" />
        </xsl:otherwise>
    </xsl:choose>
</div>
<div>
    <xsl:if test="not( string-length($ws_id) > 0 )">
        <xsl:choose>
            <xsl:when test="$is_mobile='true'">
                <xsl:attribute name="class">menuDiv mobile</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="class">menuDiv</xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
        <div class="menuDiv-shadow"/>
        <div class="menuDiv-inner">
            <div class="menu-item-padding"/>
            <xsl:apply-templates select="subcomponent/componentcontent/*" mode="navigation"/>
            <div class="menu-item-div menu-item-answer" item="answers">
            <a>
                <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'answers')"/></xsl:attribute>
                <xsl:choose>
                    <xsl:when test="$itemInner='answers'">
                         <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                         <div class="menu-item-dot-wrapper"><div class="menu-item-dot"/></div>
                     </xsl:when><xsl:otherwise>
                         <xsl:attribute name="class">navigatie</xsl:attribute>
                     </xsl:otherwise>
                </xsl:choose>
                Antwoorden</a>
            </div>
            <div class="menu-item-padding"/>
        </div>
        
    </xsl:if>
    <!--
    <embed class="audio" src="http://www.basiswiskunde.nl/Vocal/ha-b11-ep1.mp3" autoplay="false" width="70" height="26" volume="80" align="right"></embed>
    -->
</div>
<div style="clear:both"/>
</div>
<div class="terug-verder">
        <span class="verder-span" id='verder-button'><a href="javascript:MU_verder()">
            verder
        </a></span>
        <span class="terug-verder-separator">|</span>
        <span class="terug-span" id='terug-button'><a href="javascript:MU_terug()">
            terug
        </a></span>
</div>
</div>
</body>
</html>
</xsl:template>

<xsl:template name="list-section-nrs">
    <xsl:param name="i"/>
    <xsl:param name="count"/>
    <xsl:param name="highlight"/>
    <xsl:param name="subcomponents"/>
    <xsl:choose>
        <xsl:when test="number($i) = number($highlight)">
            <span class="list-section-nr highlight"><xsl:value-of select="$i"/></span>
        </xsl:when>
        <xsl:otherwise>
            <span class="list-section-nr">
                <a>
                    <xsl:attribute name="href">
                                <xsl:value-of select="concat('view?comp=',$comp,'&amp;subcomp=',$subcomponents/subcomponent[number(@_nr)=$i]/@id,'&amp;variant=basis',$arg_parent,$arg_repo)"/>
                    </xsl:attribute>
                    <xsl:value-of select="$i"/>
                </a>
            </span>
        </xsl:otherwise>
    </xsl:choose>
    
    <xsl:if test="number($count) > number($i)">
        <xsl:call-template name="list-section-nrs">
           <xsl:with-param name="i"><xsl:value-of select="$i+1"/></xsl:with-param>
           <xsl:with-param name="count"><xsl:value-of select="$count"/></xsl:with-param>
           <xsl:with-param name="highlight"><xsl:value-of select="$highlight"/></xsl:with-param>
           <xsl:with-param name="subcomponents" select="$subcomponents"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>


<!--   **************** -->
<!--    CONTENT TYPES   -->
<!--   **************** -->
<xsl:template match="explore">
    <xsl:param name="options"/>
    <xsl:if test="not($options and $options/options/mode[@type='answers'])">
        <h2 class="section-title">Verkennen</h2>
    </xsl:if>
    <xsl:for-each select="include">
        <xsl:apply-templates select="document(concat($docbase,@filename))/exercise">
            <xsl:with-param name="options" select="$options"/>
            <xsl:with-param name="number" select="position()"/>
            <xsl:with-param name="is-open">true</xsl:with-param>
        </xsl:apply-templates>
    </xsl:for-each>
</xsl:template>

<xsl:template match="introduction">
    <h2 class="section-title">Inleiding</h2>
    <xsl:apply-templates/>
</xsl:template>
<xsl:template match="explanation">
    <h2 class="section-title">Uitleg</h2>
    <div class="explanation">
        <xsl:apply-templates/>
    </div>
</xsl:template>

<xsl:template match="theory">
    <xsl:param name="options"/>
    <xsl:if test="not($options and $options/options/mode[@type='answers'])">
        <h2 class="section-title">Theorie</h2>
    </xsl:if>
    <xsl:apply-templates select="include"/>
</xsl:template>

<xsl:template match="componentcontent/examples">
    <h2 class="section-title">Voorbeeld <xsl:value-of select="$num"/></h2>
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="componentcontent/theory/examples">
    <h2 class="section-title">Voorbeeld <xsl:value-of select="$num"/></h2>
    <xsl:variable name="cont" select = "document(concat($docbase,include/@filename))"/>
    <xsl:apply-templates select="$cont" mode="content"/>
</xsl:template>

<xsl:template match="digest">
    <h2 class="section-title">Verwerken</h2>
    <xsl:apply-templates/>
</xsl:template>
<xsl:template match="application">
    <h2 class="section-title">Toepassen</h2>
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="extra">
    <h2 class="section-title">Practicum</h2>
        <xsl:apply-templates/>
</xsl:template>

<xsl:template match="summary">
    <h2 class="section-title">Samenvatten</h2>
    <xsl:apply-templates mode="content"/>
</xsl:template>
<xsl:template match="test">
    <h2 class="section-title">Testen</h2>
    <xsl:apply-templates/>
</xsl:template>
<xsl:template match="background">
    <h2 class="section-title">Achtergronden</h2>
    <xsl:variable name="cont" select = "document(concat($docbase,include/@filename))"/>
    <xsl:apply-templates select="$cont" mode="content"/>
</xsl:template>
<xsl:template match="exam">
    <h2 class="section-title">Examenopgaven</h2>
    <xsl:apply-templates/>
</xsl:template>


<xsl:template match="include">
    <xsl:param name="options"/>
    <xsl:apply-templates select="document(concat($docbase,@filename))" mode="content">
        <xsl:with-param name="options" select="$options"/>
    </xsl:apply-templates>
        
</xsl:template>
<xsl:template match="exercises" mode="content">
    <xsl:apply-templates select="."/>
</xsl:template>
<xsl:template match="exercises">
    <xsl:param name="options"/>
    <div class="exercises-container">
        <xsl:choose>
            <xsl:when test="not(ancestor::explore)">
                <xsl:for-each select="include | block[@medium='web']/include">
                    <xsl:apply-templates select="document(concat($docbase,@filename))/exercise">
                        <xsl:with-param name="is-open">
                            <xsl:choose>
                                <xsl:when test="((exists(ancestor::digest) or exists(ancestor::test)) and (not(preceding-sibling::include))) or ($options and $options/options/mode[@type='answers']) or (concat($id,'.xml') = @filename)"
                                >true</xsl:when>
                                <xsl:otherwise>false</xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                        <xsl:with-param name="options" select="$options"/>
                        <xsl:with-param name="number" select="@num"/>
                    </xsl:apply-templates>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="include">
                    <xsl:apply-templates select="document(concat($docbase,@filename))/exercise">
                        <xsl:with-param name="options" select="$options"/>
                        <xsl:with-param name="number" select="@num"/>
                    </xsl:apply-templates>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </div>
</xsl:template>
<xsl:template match="exercise">
    <xsl:param name="options"/>
    <xsl:param name="is-open"/>
    <xsl:param name="number"/>
    <div>
        <xsl:choose>
            <xsl:when test="$is-open='true'">
                <xsl:attribute name="class">exercise-with-heading open</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="class">exercise-with-heading</xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
        <div class="exercise-heading">
            Opgave <xsl:value-of select="$number"/> <span class="opgave-title-span"><xsl:value-of select="title"/></span> <div class="opgave-label-button"/>
        </div>
        <div class="exercise-contents">
            <xsl:apply-templates mode="content">
                <xsl:with-param name="options" select="$options"/>
            </xsl:apply-templates>
        </div>
    </div>
</xsl:template>

<xsl:template match="title" mode="content-title"><xsl:apply-templates mode="content"/></xsl:template>

<xsl:template match="p">
    <xsl:apply-templates mode="content"/>
</xsl:template>
<!--   **************** -->
<!--     NAVIGATION     -->
<!--   **************** -->
<xsl:template match="explore" mode="navigation">
   <div class="menu-item-div" item="explore">
       <a>
            <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'explore')"/></xsl:attribute>
            <xsl:choose>
                <xsl:when test="$itemInner='explore'">
                    <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                    <div class="menu-item-dot-wrapper"><div class="menu-item-dot"/></div>
                </xsl:when><xsl:otherwise>
                    <xsl:attribute name="class">navigatie</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            Verkennen</a>
   </div>
</xsl:template>
<xsl:template match="introduction" mode="navigation">
   <div class="menu-item-div" item="introduction">
       <a>
            <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'introduction')"/></xsl:attribute>
            <xsl:choose>
                <xsl:when test="$itemInner='introduction'">
                    <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                    <div class="menu-item-dot-wrapper"><div class="menu-item-dot"/></div>
                </xsl:when><xsl:otherwise>
                    <xsl:attribute name="class">navigatie</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            Inleiding</a>
   </div>
</xsl:template>
<xsl:template match="explanation" mode="navigation">
    <xsl:variable name="explnum" select="count(preceding-sibling::explanation)+1"/>
    <xsl:choose>
        <xsl:when test="count(preceding-sibling::explanation)+count(following-sibling::explanation) > 0">
           <div class="menu-item-div" item="explanation">
               <a>
                    <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'explanation&amp;num=',$explnum)"/></xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="$itemInner='explanation' and $explnum=number($num)">
                            <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                            <div class="menu-item-dot-wrapper"><div class="menu-item-dot"/></div>
                        </xsl:when><xsl:otherwise>
                            <xsl:attribute name="class">navigatie</xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                   Uitleg <xsl:value-of select="$explnum"/></a>
           </div>
        </xsl:when>
        <xsl:otherwise>
           <div class="menu-item-div" item="explanation">
               <a>
                    <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'explanation')"/></xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="$itemInner='explanation' and not(number($num) > 1)">
                            <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                            <div class="menu-item-dot-wrapper"><div class="menu-item-dot"/></div>
                        </xsl:when><xsl:otherwise>
                            <xsl:attribute name="class">navigatie</xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                   Uitleg</a>
           </div>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
<xsl:template match="theory" mode="navigation">
   <xsl:if test="include">
       <div class="menu-item-div" item="theory">
           <a>
                <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'theory')"/></xsl:attribute>
                <xsl:choose>
                    <xsl:when test="$itemInner='theory'">
                       <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                       <div class="menu-item-dot-wrapper"><div class="menu-item-dot"/></div>
                    </xsl:when><xsl:otherwise>
                    <xsl:attribute name="class">navigatie</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
               Theorie</a>
        </div>
   </xsl:if>
   <xsl:for-each select="examples">
       <div class="menu-item-div" item="example">
           <xsl:attribute name="num"><xsl:value-of select="position()"/></xsl:attribute>
           <a>
                <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'example&amp;num=',position())"/></xsl:attribute>
                <xsl:choose>
                    <xsl:when test="($itemInner='example' or $itemInner='theory') and position()=number($num)">
                    <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                    <div class="menu-item-dot-wrapper"><div class="menu-item-dot"/></div>
                </xsl:when><xsl:otherwise>
                    <xsl:attribute name="class">navigatie</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
               Voorbeeld <xsl:value-of select="position()"/></a>
        </div>
   </xsl:for-each>
</xsl:template>
<!--
<xsl:template match="componentcontent/examples" mode="navigation">
   <xsl:for-each select="include">
       <div class="menu-item-div">
           <a>
                <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'example&amp;num=',position())"/></xsl:attribute>
                <xsl:choose>
                    <xsl:when test="$item='example' and position()=number($num)">
                        <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                    </xsl:when><xsl:otherwise>
                        <xsl:attribute name="class">navigatie</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                </xsl:choose>
               Voorbeeld <xsl:value-of select="position()"/></a>
        </div>
    </xsl:for-each>
</xsl:template>
-->
<xsl:template match="digest" mode="navigation">
   <div class="menu-item-div" item="digest">
       <a>
            <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'digest')"/></xsl:attribute>
            <xsl:choose>
                <xsl:when test="$itemInner='digest'">
                    <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                    <div class="menu-item-dot-wrapper"><div class="menu-item-dot"/></div>
                </xsl:when><xsl:otherwise>
                    <xsl:attribute name="class">navigatie</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
           Verwerken</a>
    </div>
</xsl:template>

<xsl:template match="application" mode="navigation">
   <div class="menu-item-div" item="application">
       <a>
            <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'application')"/></xsl:attribute>
            <xsl:choose>
                <xsl:when test="$itemInner='application'">
                    <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                    <div class="menu-item-dot-wrapper"><div class="menu-item-dot"/></div>
                </xsl:when><xsl:otherwise>
                    <xsl:attribute name="class">navigatie</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
           Toepassen</a>
   </div>
</xsl:template>


<xsl:template match="extra" mode="navigation">
    <xsl:variable name="explnum" select="count(preceding-sibling::extra)+1"/>
    <xsl:choose>
        <xsl:when test="count(preceding-sibling::extra)+count(following-sibling::extra) > 0">
           <div class="menu-item-div" item="extra">
               <a>
                    <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'extra&amp;num=',$explnum)"/></xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="$itemInner='extra' and $explnum=number($num)">
                            <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                            <div class="menu-item-dot-wrapper"><div class="menu-item-dot"/></div>
                        </xsl:when><xsl:otherwise>
                            <xsl:attribute name="class">navigatie</xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                   Practicum <xsl:value-of select="$explnum"/></a>
           </div>
        </xsl:when>
        <xsl:otherwise>
           <div class="menu-item-div" item="extra">
               <a>
                    <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'extra')"/></xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="$itemInner='extra' and not(number($num) > 1)">
                            <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                            <div class="menu-item-dot-wrapper"><div class="menu-item-dot"/></div>
                        </xsl:when><xsl:otherwise>
                            <xsl:attribute name="class">navigatie</xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                   Practicum</a>
           </div>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="exam" mode="navigation">
   <div class="menu-item-div" item="digest">
       <a>
            <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'exam')"/></xsl:attribute>
            <xsl:choose>
                <xsl:when test="$itemInner='exam'">
                    <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                    <div class="menu-item-dot-wrapper"><div class="menu-item-dot"/></div>
                </xsl:when><xsl:otherwise>
                    <xsl:attribute name="class">navigatie</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
           Examenopgaven</a>
    </div>
</xsl:template>

<xsl:template match="summary" mode="navigation">
   <div class="menu-item-div" item="summary">
       <a>
            <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'summary')"/></xsl:attribute>
            <xsl:choose>
                <xsl:when test="$itemInner='summary'">
                    <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                    <div class="menu-item-dot-wrapper"><div class="menu-item-dot"/></div>
                </xsl:when><xsl:otherwise>
                    <xsl:attribute name="class">navigatie</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
           Samenvatten</a>
   </div>
</xsl:template>
<xsl:template match="test" mode="navigation">
   <div class="menu-item-div" item="test">
       <a>
            <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'test')"/></xsl:attribute>
            <xsl:choose>
                <xsl:when test="$itemInner='test'">
                    <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                    <div class="menu-item-dot-wrapper"><div class="menu-item-dot"/></div>
                </xsl:when><xsl:otherwise>
                    <xsl:attribute name="class">navigatie</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
           Testen</a>
   </div>
</xsl:template>

<xsl:template match="background" mode="navigation">
   <div class="menu-item-div" item="background">
       <a>
            <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'background')"/></xsl:attribute>
            <xsl:choose>
                <xsl:when test="$itemInner='background'">
                    <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                    <div class="menu-item-dot-wrapper"><div class="menu-item-dot"/></div>
                </xsl:when><xsl:otherwise>
                    <xsl:attribute name="class">navigatie</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
           Achtergronden</a>
   </div>
   <xsl:apply-templates select="examples" mode="navigation"/>
</xsl:template>

<xsl:template match="exercise" mode="content">
    <xsl:param name="options"/>
    <div class="exercise">
        <xsl:apply-templates mode="content">
            <xsl:with-param name="options" select="$options"/>
        </xsl:apply-templates>
    </div>
</xsl:template>

<!--
    Introduction
-->
<xsl:template match="learningaspects" mode="content">
 <p>
    <b>Je leert in dit onderwerp:</b>
    <ul><xsl:for-each select="aspect">
       <li><xsl:apply-templates mode="content"/></li>
       </xsl:for-each>
    </ul>
 </p>
</xsl:template>

<xsl:template match="knownaspects" mode="content">
 <p>
    <b>Voorkennis:</b>
    <ul><xsl:for-each select="aspect">
       <li><xsl:apply-templates mode="content"/></li>
        </xsl:for-each>
    </ul>
 </p>
</xsl:template>

<xsl:template match="definitions" mode="content">
    <div class="definitions">
        Begrippenlijst
    </div>
    <xsl:apply-templates mode="content"/>
</xsl:template>

<xsl:template match="definition" mode="content">
   <div class="definition">
       <a>
           <xsl:attribute name="href"><xsl:value-of select="concat('view?comp=',$comp,'&amp;subcomp=',@id,'&amp;variant=',$variant,'&amp;item=theory')"/></xsl:attribute>
           <xsl:apply-templates mode="content"/>
       </a>
   </div>
</xsl:template>

<xsl:template match="activities" mode="content">
    <div class="definitions">
        Activiteitenlijst
    </div>
    <xsl:apply-templates mode="content"/>
</xsl:template>

<xsl:template match="activity" mode="content">
   <div class="definition">
       <a>
           <xsl:attribute name="href"><xsl:value-of select="concat('view?comp=',$comp,'&amp;subcomp=',@id,'&amp;variant=',$variant,'&amp;item=theory')"/></xsl:attribute>
           <xsl:apply-templates mode="content"/>
       </a>
   </div>
</xsl:template>

<xsl:template match="proof" mode="content">
   <div class="m4a-example">
        <div onclick="javascript:M4A_ShowExampleAnswer(this)" class="example-answer-button">&gt; bewijs</div>
        <div class="m4a-answer">
            <xsl:apply-templates mode="content"/>
            <div  onclick="javascript:M4A_ShowExampleAnswer(this)" class="answerCloseButton"/>
        </div>
   </div>
</xsl:template>

<xsl:template match='block[@medium="web"]'><xsl:apply-templates/></xsl:template>

<xsl:template match="*"/>
<xsl:template match="*" mode="navigation"/>
</xsl:stylesheet>
