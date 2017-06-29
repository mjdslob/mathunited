<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:exsl="http://exslt.org/common"
xmlns:m="http://www.w3.org/1998/Math/MathML"
extension-element-prefixes="exsl">
<xsl:param name="item"/>
<xsl:param name="num"/>
<xsl:param name="refbase"/> <!-- used for includes: base path. Includes final / -->
<xsl:param name="ws_id"/>
<xsl:param name="comp"/>
<xsl:param name="component_title"/>
<xsl:param name="subcomponent_title"/>
<xsl:param name="subcomponent_next_id"/>
<xsl:param name="subcomponent_prev_id"/>
<xsl:param name="subcomponent_index"/>
<xsl:param name="num_of_subcomponents"/>
<xsl:param name="subcomp"/>
<xsl:param name="is_mobile"/>
<xsl:param name="viewer"/>
<xsl:param name="id"/>
<xsl:variable name="itemInner">
    <xsl:choose>
        <xsl:when test="string-length($id) gt 0"><xsl:value-of select="name(subcomponent/componentcontent/*[child::include[@filename=concat($id,'.xml')]][1])"/></xsl:when>
        <xsl:when test="$item=''"><xsl:value-of select="name(subcomponent/componentcontent/*[1])"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="$item"/></xsl:otherwise>
    </xsl:choose>
</xsl:variable>
<xsl:variable name="cm2px" select="number(50)"/>
<xsl:variable name="variant">basis</xsl:variable>
<xsl:variable name="intraLinkPrefix" select="concat($viewer,'?comp=',$comp,'&amp;subcomp=',$subcomp,'&amp;variant=',$variant,'&amp;item=')"/>
<xsl:variable name="overviewRef"><xsl:value-of select="string('/auteur/math4all.html')"/></xsl:variable>
<xsl:variable name="urlbase"><xsl:value-of select="concat('http://mathunited.pragma-ade.nl:41080/data/',$refbase)"/></xsl:variable>
<xsl:variable name="_cross_ref_as_links_" select="false()"/>
<xsl:variable name="_sheetref_as_links_" select="false()"/>

<xsl:output method="html" doctype-system="http://www.w3.org/TR/html4/strict.dtd" doctype-public="-//W3C//DTD HTML 4.01//EN"
indent="yes" encoding="utf-8"/>

<xsl:include href="calstable.xslt"/>
<xsl:include href="exercises_LOM.xslt"/>
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
        <xsl:attribute name="num" select="1+count(preceding::explore/include)+count(preceding-sibling::include)+count(preceding::exercises/include)"/>
    </include>
</xsl:template>
<xsl:template match="exercises/block[@medium='web']/include" mode="numbering">
    <include>
        <xsl:attribute name="filename" select="@filename"/>
        <xsl:attribute name="num" select="1+count(preceding-sibling::include)"/>
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
   <link type="text/css" href="http://mathunited.pragma-ade.nl:41080/MathUnited/javascript/jquery-ui-1.8.15.custom/css/ui-lightness/jquery-ui-1.8.15.custom.css" rel="Stylesheet" />
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.2/jquery-ui.min.js"></script>
<!--
   <script type="text/javascript" src="http://mathunited.pragma-ade.nl:41080/MathUnited/javascript/jquery-ui-1.8.15.custom/js/jquery-1.6.2.min.js"></script>
   <script type="text/javascript" src="http://mathunited.pragma-ade.nl:41080/MathUnited/javascript/jquery-ui-1.8.15.custom/js/jquery-ui-1.8.15.custom.min.js"></script>
-->
   <link rel="stylesheet" href="http://mathunited.pragma-ade.nl:41080/MathUnited/css/grid.css" type="text/css"/>
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
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-AMS_CHTML&amp;delayStartupUntil=configured" />
    <script type="text/javascript" src="http://mathunited.pragma-ade.nl:41080/MathUnited/javascript/MathUnited.js"/>
   <script type="text/javascript" src="http://mathunited.pragma-ade.nl:41080/MathUnited/javascript/MathUnited_LOM.js"/>
   <link rel="stylesheet" href="http://mathunited.pragma-ade.nl:41080/MathUnited/css/content.css" type="text/css"/>
   <link rel="stylesheet" href="http://mathunited.pragma-ade.nl:41080/MathUnited/css/LerenOpMaat_HTML.css" type="text/css"/>
<link type="text/css" href="http://lopexs.s3.amazonaws.com/lom/api/0.9/scoring.css" rel="Stylesheet"/>   
    <script type="text/javascript" src="http://lopexs.s3.amazonaws.com/lom/api/0.9/scoring.js"></script>
<!--
    <script type="text/javascript" src="http://lopexs.s3.amazonaws.com/lom/api/0.9/jquery.scoring.widget.js"></script>
-->    
   <title><xsl:value-of select="$component_title"/></title>
</head>

<!--   **************** -->
<!--        BODY        -->
<!--   **************** -->
<body>
<div class="shadow-ul"/>
<div class="pageDiv">
    Op deze pagina is de feedback widget uitgeschakeld.
<div class="headingDiv container_12 clearfix">
    <div class="headingContentDiv grid_10">
        <img class="logo" src="sources_ma/LogoM4Ainvlak.gif" align="middle"  height="33" border="0"/>
        <xsl:if test="$is_mobile='true'">
            (m)
        </xsl:if>
        <xsl:value-of select="$component_title"/> &gt; <xsl:value-of select="$subcomponent_title"/>
    </div>
</div>
<div class="sectionDiv container_12">
   <div class="balk grid_12">
       <span class="subcomponent-title"><xsl:value-of select="$subcomponent_title"/></span>
       
   </div>
</div>
<div class="contentDiv container_12 clearfix">
<div class="grid_10">
    <xsl:choose>
        <xsl:when test="string-length($ws_id) gt 0">
            <xsl:choose>
                <xsl:when test="$itemInner='example'">
                    <xsl:apply-templates select="subcomponent/componentcontent/theory/examples[position()=number($num)]"  mode="worksheet"/>
                    <xsl:apply-templates select="subcomponent/componentcontent/theory/exercises[position()=number($num)]"  mode="worksheet"/>
                </xsl:when>
                <xsl:when test="$itemInner='explanation'">
                    <xsl:choose>
                        <xsl:when test="number($num) gt 1">
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
        <xsl:when test="$itemInner='example'">
            <xsl:apply-templates select="subcomponent/componentcontent/theory/examples[position()=number($num)]"/>
            <xsl:apply-templates select="subcomponent/componentcontent/theory/exercises[position()=number($num)]"/>
            <div class="LOM-rating-widget"/>
        </xsl:when>
        <xsl:when test="$itemInner='explanation'">
            <xsl:choose>
                <xsl:when test="number($num) gt 1">
                    <xsl:apply-templates select="subcomponent/componentcontent/explanation[count(preceding-sibling::explanation)=number($num)-1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="subcomponent/componentcontent/explanation[count(preceding-sibling::explanation)=0]"/>
                </xsl:otherwise>
            </xsl:choose>
            <div class="LOM-rating-widget"/>

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
            <div class="LOM-rating-widget"/>
        </xsl:otherwise>

    </xsl:choose>
</div>
</div>
</div>
<div class="shadow-lr"/>
</body>
</html>
</xsl:template>

<xsl:template name="list-section-nrs">
    <xsl:param name="i"/>
    <xsl:param name="count"/>
    <xsl:param name="highlight"/>
    
    <xsl:choose>
        <xsl:when test="number($i) eq number($highlight)">
            <span class="list-section-nr highlight"><xsl:value-of select="$i"/></span>
        </xsl:when>
        <xsl:otherwise>
            <span class="list-section-nr">
                <a>
                    <xsl:attribute name="href" select="concat($viewer,'?comp=',$comp,'&amp;subcomp=',$i,'&amp;variant=basis')"/>
                    <xsl:value-of select="$i"/>
                </a>
            </span>
        </xsl:otherwise>
    </xsl:choose>
    
    <xsl:if test="number($i) lt number($count)">
        <xsl:call-template name="list-section-nrs">
           <xsl:with-param name="i"><xsl:value-of select="$i+1"/></xsl:with-param>
           <xsl:with-param name="count"><xsl:value-of select="$count"/></xsl:with-param>
           <xsl:with-param name="highlight"><xsl:value-of select="$highlight"/></xsl:with-param>
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
        <xsl:apply-templates select="document(concat($refbase,@filename))/exercise">
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
    <xsl:variable name="cont" select = "document(concat($refbase,include/@filename))"/>
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
    <xsl:choose>
        <xsl:when test="$num">
            <h2 class="section-title">Practicum <xsl:value-of select='$num'/></h2>
            <xsl:variable name="cont" select = "document(concat($refbase,include[position()=number($num)]/@filename))"/>
            <xsl:apply-templates select="$cont" mode="content"/>
        </xsl:when>
        <xsl:otherwise>
            <h2 class="section-title">Practicum</h2>
            <xsl:apply-templates/>
        </xsl:otherwise>
    </xsl:choose>
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
    <xsl:variable name="cont" select = "document(concat($refbase,include/@filename))"/>
    <xsl:apply-templates select="$cont" mode="content"/>
</xsl:template>

<xsl:template match="include">
    <xsl:param name="options"/>
    <xsl:apply-templates select="document(concat($refbase,@filename))" mode="content">
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
                    <xsl:apply-templates select="document(concat($refbase,@filename))/exercise">
                        <xsl:with-param name="is-open">
                            <xsl:choose>
                                <xsl:when test="((exists(ancestor::digest) or exists(ancestor::test)) and (not(preceding-sibling::include))) or ($options and $options/options/mode[@type='answers'])"
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
                    <xsl:apply-templates select="document(concat($refbase,@filename))/exercise">
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
    <div class="exercise-with-heading open">
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
        <xsl:when test="count(preceding-sibling::explanation) gt 0">
           <div class="menu-item-div" item="explanation">
               <a>
                    <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'explanation&amp;num=',$explnum)"/></xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="$itemInner='explanation' and $explnum=$num">
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
                        <xsl:when test="$itemInner='explanation' and not(number($num) gt 1)">
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
                    <xsl:when test="$itemInner='example' and position()=number($num)">
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
   <xsl:choose>
       <xsl:when test="count(include) gt 1">
           <xsl:for-each select="include">
               <div class="menu-item-div" item="extra">
                   <a>
                        <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'extra&amp;num=',position())"/></xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="$itemInner='extra' and position()=number($num)">
                            <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                            <div class="menu-item-dot-wrapper"><div class="menu-item-dot"/></div>
                        </xsl:when><xsl:otherwise>
                            <xsl:attribute name="class">navigatie</xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                       Practicum <xsl:value-of select="position()"/></a>
               </div>
           </xsl:for-each>
       </xsl:when>
       <xsl:otherwise>
           <div class="menu-item-div" item="extra">
               <a>
                    <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'extra')"/></xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="$itemInner='extra'">
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
                <xsl:when test="$itemInner='theory'">
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
                    <a>
                        <xsl:attribute name="href"><xsl:value-of select="concat($viewer,'?comp=',$_comp,'&amp;subcomp=',$_subcomp,'&amp;variant=',$variant,'&amp;id=', @item)"/></xsl:attribute>
                        <xsl:value-of select="."/>

                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <span class="textref">
                        <xsl:value-of select="."/>
                    </span>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match='block[@medium="web"]'><xsl:apply-templates/></xsl:template>

<xsl:template match="*"/>
<xsl:template match="*" mode="navigation"/>
</xsl:stylesheet>
