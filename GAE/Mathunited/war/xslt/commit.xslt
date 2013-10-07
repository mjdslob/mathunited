<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:exsl="http://exslt.org/common"
xmlns:m="http://www.w3.org/1998/Math/MathML"
extension-element-prefixes="exsl">
<xsl:param name="item"/>
<xsl:param name="num"/>
<xsl:param name="ref"/>
<xsl:param name="comp"/>
<xsl:param name="component_title"/>
<xsl:param name="subcomponent_title"/>
<xsl:param name="subcomponent_next_id"/>
<xsl:param name="subcomponent_prev_id"/>
<xsl:param name="subcomp"/>
<xsl:param name="viewer"/>
<xsl:param name="id"/>
<xsl:variable name="itemInner">
    <xsl:choose>
        <xsl:when test="string-length($id) gt 0"><xsl:value-of select="name(subcomponent/componentcontent/*[include[@filename=concat($id,'.xml')]])"/></xsl:when>
        <xsl:when test="$item=''"><xsl:value-of select="name(subcomponent/componentcontent/*[1])"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="$item"/></xsl:otherwise>
    </xsl:choose>
</xsl:variable>
<xsl:variable name="cm2px" select="number(50)"/>
<xsl:variable name="refbase" select="concat('m4a/xml/',substring-before(substring-after($ref,'m4a/xml/'),'/'),'/')"/>
<xsl:variable name="variant">basis</xsl:variable>
<xsl:variable name="intraLinkPrefix" select="concat($viewer,'?comp=',$comp,'&amp;subcomp=',$subcomp,'&amp;variant=',$variant,'&amp;item=')"/>
<xsl:variable name="URLbase">
    <xsl:choose>
        <xsl:when test="$viewer='viewtest'"><xsl:value-of select="string('../testcontent/m4a/')"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="string('../content/m4a/')"/></xsl:otherwise>
    </xsl:choose>
</xsl:variable>
<xsl:variable name="overviewRef">
    <xsl:choose>
        <xsl:when test="$viewer='viewtest'"><xsl:value-of select="string('/testcontent/math4all.html')"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="string('/wiskundemenu/WM_overview.html')"/></xsl:otherwise>
    </xsl:choose>
</xsl:variable>

<xsl:output method="html" doctype-system="http://www.w3.org/TR/html4/strict.dtd" doctype-public="-//W3C//DTD HTML 4.01//EN"
indent="yes" encoding="utf-8"/>

<xsl:include href="calstable.xslt"/>
<xsl:include href="exercises.xslt"/>
<xsl:include href="content.xslt"/>

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
   <link type="text/css" href="javascript/jquery-ui-1.8.15.custom/css/ui-lightness/jquery-ui-1.8.15.custom.css" rel="Stylesheet" />
   <script type="text/javascript" src="javascript/jquery-ui-1.8.15.custom/js/jquery-1.6.2.min.js"></script>
   <script type="text/javascript" src="javascript/jquery-ui-1.8.15.custom/js/jquery-ui-1.8.15.custom.min.js"></script>
   <link rel="stylesheet" href="css/grid.css" type="text/css"/>
<!--
   <script type="text/javascript" src="http://www.math4all.nl/MathJax/MathJax.js"></script>
-->
<!--
   <script type="text/javascript"
      src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=MML_HTMLorMML-full&amp;delayStartupUntil=configured">
   </script>
-->
   <script type="text/javascript"
      src="http://localhost/MathJax/MathJax.js?config=MML_HTMLorMML-full&amp;delayStartupUntil=configured">
   </script>
   <script type="text/javascript" src="javascript/MathUnited_m4a.js"/>
   <link rel="stylesheet" href="css/M4AStijl2.css" type="text/css"/>
   <script type="text/javascript" src="javascript/ASCIIMathML.js"></script>
   <title><xsl:value-of select="$component_title"/></title>
</head>

<!--   **************** -->
<!--        BODY        -->
<!--   **************** -->
<body>
<div class="shadow-ul"/>
<div class="pageDiv ui-corner-all">
<div class="headingDiv container_12 clearfix">
    <div class="headingContentDiv grid_10">
        <img class="logo" src="sources_ma/LogoM4Ainvlak.gif" align="middle"  height="33" border="0"/>
        <xsl:value-of select="$component_title"/> &gt; <xsl:value-of select="$subcomponent_title"/>
    </div>
    <div class="overzichtDiv grid_2">
        <a>
              <xsl:attribute name="href"><xsl:value-of select="$overviewRef"/></xsl:attribute>> Overzicht
        </a>
    </div>
</div>
<div class="sectionDiv container_12">
   <div class="balk grid_12">
       <xsl:if test="string-length($subcomponent_prev_id) gt 0">
           <div class="prev-subcomponent">
               <a>
                   <xsl:attribute name="href" select="concat($viewer,'?comp=',$comp,'&amp;subcomp=',$subcomponent_prev_id,'&amp;variant=basis')"/>
                   &lt;
               </a>
           </div>
       </xsl:if>
       <xsl:value-of select="$subcomponent_title"/>
       <xsl:if test="string-length($subcomponent_next_id) gt 0">
           <div class="next-subcomponent">
               <a>
                   <xsl:attribute name="href" select="concat($viewer,'?comp=',$comp,'&amp;subcomp=',$subcomponent_next_id,'&amp;variant=basis')"/>
                   &gt;
               </a>
           </div>
       </xsl:if>
   </div>
</div>
<div class="contentDiv container_12 clearfix">
<div class="grid_10">
    <xsl:choose>
        <xsl:when test="$itemInner='example'">
            <xsl:apply-templates select="subcomponent/componentcontent/theory/examples[position()=number($num)]"/>
            <xsl:apply-templates select="subcomponent/componentcontent/theory/exercises[position()=number($num)]"/>
        </xsl:when>
        <xsl:otherwise>
           <xsl:apply-templates select="subcomponent/componentcontent/*[name()=$itemInner]" />
        </xsl:otherwise>
    </xsl:choose>
    <div class="commit-container">
        <div class="commit-button" onclick="javascript: MU_commit()"/>
    </div>
</div>
<div class="menuDiv grid_2">
    <div class="menuDiv-shadow"/>
    <div class="menuDiv-inner">
    <xsl:apply-templates select="subcomponent/componentcontent/*" mode="navigation"/></div>
    <!--
    <embed class="audio" src="http://www.basiswiskunde.nl/Vocal/ha-b11-ep1.mp3" autoplay="false" width="70" height="26" volume="80" align="right"></embed>
    -->
</div>
</div>
</div>
<div class="shadow-lr"/>
</body>
</html>
</xsl:template>

<!--   **************** -->
<!--    CONTENT TYPES   -->
<!--   **************** -->
<xsl:template match="explore">
    <h2 class="section-title">Verkennen</h2>
    <xsl:for-each select="include">
       <div class="exercise-with-heading">
           <div class="exercise-heading">
               Opgave <xsl:value-of select="position()"/>
           </div>
           <xsl:apply-templates select="document(concat($refbase,@filename))" mode="content"/>
       </div>
    </xsl:for-each>
</xsl:template>
<xsl:template match="introduction">
    <h2 class="section-title">Inleiding</h2>
    <xsl:apply-templates/>
</xsl:template>
<xsl:template match="explanation">
    <h2 class="section-title">Uitleg</h2>
    <div class="explanation" contenteditable="true">
        <xsl:apply-templates/>
    </div>
</xsl:template>
<!--
<xsl:template match="theory">
    <h3 class="section-title">Theorie</h3>
    <xsl:for-each select="examples">
       <div class="example-with-heading">
           <div class="example-heading">
               Voorbeeld <xsl:value-of select="position()"/>
           </div>
           <xsl:apply-templates select="document(concat($refbase,include/@filename))" mode="content"/>
       </div>
       <xsl:for-each select="exercises/include">
            <div class="exercise-with-heading">
                <div class="exercise-heading">Opgave <xsl:value-of select="@num"/></div>
                <xsl:apply-templates select="document(concat($refbase,@filename))" mode="content"/>
            </div>
       </xsl:for-each>
    </xsl:for-each>
</xsl:template>
-->
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
    <xsl:apply-templates/>
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
    <xsl:apply-templates select="document(concat($refbase,@filename))" mode="content"/>
</xsl:template>
<xsl:template match="exercises">
    <xsl:choose>
        <xsl:when test="not(ancestor::explore)">
        <!--
        <xsl:when test="ancestor::explanation | ancestor::theory | ancestor::digest | ancestor::application">
        -->
            <div class="exercise-buttons-container ui-corner-right" contenteditable="false">
                <xsl:attribute name="class">exercise-buttons-container ui-corner-right nbuttons<xsl:value-of select="count(include)"/></xsl:attribute>
                <xsl:attribute name="openFirst"><xsl:value-of select="exists(ancestor::digest)"/></xsl:attribute>
                <div class="exercise-button-heading">Opgaven</div>
                <xsl:for-each select="include | block[@medium='web']/include">
                    <div class="exercises-collapse-menu ui-corner-all">
                        <xsl:attribute name="num"><xsl:value-of select="@num"/></xsl:attribute>
                        <xsl:value-of select="@num"/>
                    </div>
                    <div class="exercises-collapse-menu-active ui-corner-all">
                        <xsl:attribute name="num"><xsl:value-of select="@num"/></xsl:attribute>
                        <xsl:value-of select="@num"/>
                    </div>
                </xsl:for-each>
                <div style="clear:both"></div>
            </div>
            <xsl:for-each select="include | block[@medium='web']/include">
                <div class="exercises-collapse-item">
                    <xsl:attribute name="num"><xsl:value-of select="@num"/></xsl:attribute>
                    <xsl:variable name="excont" select="document(concat($refbase,@filename))"/>
                    <div class="exercise-with-heading">
                        <div class="exercise-heading">Opgave <xsl:value-of select="@num"/>
                           <xsl:apply-templates select="$excont/exercise/title" mode="content-title"/>
                        </div>
                        <xsl:apply-templates select="$excont" mode="content"/>
                    </div>
                </div>
            </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
            <xsl:for-each select="include">
                <div class="exercise-with-heading">
                    <xsl:variable name="excont" select="document(concat($refbase,@filename))"/>
                    <div class="exercise-heading">Opgave <xsl:value-of select="@num"/>
                           <xsl:apply-templates select="$excont/exercise/title" mode="content-title"/>
                    </div>
                    <xsl:apply-templates select="$excont" mode="content"/>
                </div>
            </xsl:for-each>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
<xsl:template match="exercise/title" mode="content"></xsl:template>
<xsl:template match="title" mode="content-title">: <xsl:apply-templates mode="content"/></xsl:template>

<xsl:template match="p">
    <xsl:apply-templates mode="content"/>
</xsl:template>
<!--   **************** -->
<!--     NAVIGATION     -->
<!--   **************** -->
<xsl:template match="explore" mode="navigation">
   <div class="menu-item-div">
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
   <div class="menu-item-div">
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
   <div class="menu-item-div">
       <a>
            <xsl:attribute name="href"><xsl:value-of select="concat($intraLinkPrefix,'explanation')"/></xsl:attribute>
            <xsl:choose>
                <xsl:when test="$itemInner='explanation'">
                    <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                    <div class="menu-item-dot-wrapper"><div class="menu-item-dot"/></div>
                </xsl:when><xsl:otherwise>
                    <xsl:attribute name="class">navigatie</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
           Uitleg</a>
   </div>
</xsl:template>
<xsl:template match="theory" mode="navigation">
   <xsl:for-each select="examples">
       <div class="menu-item-div">
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
   <div class="menu-item-div">
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
   <div class="menu-item-div">
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
               <div class="menu-item-div">
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
           <div class="menu-item-div">
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
   <div class="menu-item-div">
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
   <div class="menu-item-div">
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
   <div class="menu-item-div">
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
    <div class="exercise">
        <xsl:apply-templates mode="content"/>
    </div>
</xsl:template>

<!--
    Introduction
-->
<xsl:template match="learningaspects">
 <p>
    <b>Je leert nu:</b>
    <ul><xsl:for-each select="aspect">
       <li><xsl:apply-templates mode="content"/></li>
       </xsl:for-each>
    </ul>
 </p>
</xsl:template>

<xsl:template match="knownaspects">
 <p>
    <b>Je kunt al:</b>
    <ul><xsl:for-each select="aspect">
       <li><xsl:apply-templates mode="content"/></li>
        </xsl:for-each>
    </ul>
 </p>
</xsl:template>


<xsl:template match='block[@medium="web"]'><xsl:apply-templates/></xsl:template>

<xsl:template match="*"/>
<xsl:template match="*" mode="navigation"/>
</xsl:stylesheet>
