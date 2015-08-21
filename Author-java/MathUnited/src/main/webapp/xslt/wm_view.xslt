<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:saxon="http://saxon.sf.net/"
xmlns:exsl="http://exslt.org/common"
xmlns:m="http://www.w3.org/1998/Math/MathML"
exclude-result-prefixes="saxon"
extension-element-prefixes="exsl">
<xsl:param name="item"/>
<xsl:param name="num"/>
<xsl:param name="refbase"/> <!-- used for includes: base path. Includes final / -->
<xsl:param name="ws_id"/>   <!-- is of worksheet, if applicable -->
<xsl:param name="comp"/>    <!-- id of component. Not needed as complete xml of component is given in $component-->
<xsl:param name="subcomp"/> <!-- id of subcomponent, eg hv-me11 -->
<xsl:param name="option"/>
<xsl:param name="parent"/> <!-- eg.: mathunited.nl/wiskundemenu/WM_overview.html -->
<xsl:param name="is_mobile"/>
<xsl:param name="level"/>
    <xsl:param name="component_id"/>
    <xsl:param name="component_number"/>
    <xsl:param name="component_file"/>
    <xsl:param name="component_title"/>
    <xsl:param name="component_subtitle"/>
    <xsl:param name="subcomponent_number"/>
    <xsl:param name="subcomponent_title"/>
    <xsl:param name="subcomponent_index"/>
    <xsl:param name="subcomponent_count"/>
    <xsl:param name="subcomponent_id"/>
    <xsl:param name="subcomponent_preceding_id"/>
    <xsl:param name="subcomponent_following_id"/>

<xsl:param name="repo"/>
<xsl:param name="repo-path"/>
<xsl:param name="baserepo-path"/>

<!--   /////////////////////////////////////////////   -->
<!--  Specific for auteurssite (do not copy from GAE): -->
<!--   note: there is another such section below       -->
<!--   /////////////////////////////////////////////   -->
<xsl:variable name="host_type">auteur</xsl:variable>
<xsl:variable name="docbase"></xsl:variable>
<xsl:variable name="urlbase"><xsl:value-of select="concat('../data/',$refbase)"/></xsl:variable>
<xsl:variable name="prikbord-url" select="concat('/view?comp=',$comp,'&amp;subcomp=',$subcomp,'&amp;variant=prikbord-m4a')"/>
<xsl:variable name="overviewRef">
    <xsl:choose>
       <xsl:when test="$parent">
	   <xsl:value-of select="concat('http://',$parent)"/>
       </xsl:when>
       <xsl:otherwise>
	   <xsl:value-of select="string('/Publisher/html/publisher-wm.html')"/>
       </xsl:otherwise>
    </xsl:choose>
</xsl:variable>

<xsl:variable name="indexDoc" select="document(concat($refbase,'../index.xml'))"/>

<!--   /////////////////////////////////////////////   -->
<!--   /////////////////////////////////////////////   -->

<xsl:variable name="cm2px" select="number(45)"/>
<xsl:variable name="title" select="chapter/description/title"/>
<xsl:variable name="parentPrefix"/>
<xsl:variable name="variant">wm_view</xsl:variable>
<xsl:variable name="_cross_ref_as_links_" select="true()"/>
<xsl:variable name="_sheetref_as_links_" select="true()"/>
<xsl:variable name="arg_parent">
    <xsl:choose>
        <xsl:when test="$parent">&amp;parent=<xsl:value-of select="$parent"/></xsl:when>
        <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
</xsl:variable>

<xsl:output method="html" doctype-system="http://www.w3.org/TR/html4/strict.dtd" doctype-public="-//W3C//DTD HTML 4.01//EN"
indent="yes" encoding="utf-8" />

<xsl:include href="tabulate.xslt"/>
<xsl:include href="calstable.xslt"/>
<xsl:include href="exercises.xslt"/>
<xsl:include href="content.xslt"/>
<xsl:include href="wm_worksheet.xslt"/>

<!--   **************** -->
<!--   PRE PROCESS      -->
<!--   **************** -->
<xsl:template match="/">
    <xsl:variable name="xml">
        <xsl:apply-templates mode="numbering"/>
    </xsl:variable>
    <xsl:apply-templates select="$xml" mode="process"/>
</xsl:template>
<xsl:template match="subcomponent" mode="numbering">
    <xsl:copy>
        <xsl:apply-templates select="@*" mode="numbering"/>
        <xsl:attribute name="_base"><xsl:value-of select="$indexDoc//subcomponent[@id=$subcomp]/@_base"/></xsl:attribute>
        <xsl:apply-templates mode="numbering"/>
    </xsl:copy>
</xsl:template>
<xsl:template match="exercise" mode="numbering">
    <xsl:copy>
        <xsl:attribute name="num"><xsl:value-of select="1+count(preceding::exercise)"/></xsl:attribute>
        <xsl:apply-templates select="@*" mode="numbering"/>
        <xsl:apply-templates mode="numbering"/>
    </xsl:copy>
</xsl:template>

<!--   /////////////////////////////////////////////   -->
<!--  Specific for auteurstool (do not copy to GAE): -->
<!--   /////////////////////////////////////////////   -->
<xsl:template match="textref" mode="numbering">
    <xsl:variable name="ref" select="@ref"/>
    <xsl:choose>
        <xsl:when test="@ref">
            <xsl:choose>
                <xsl:when test="$indexDoc//*[@id=$ref]">
                    <xsl:copy>
                        <xsl:apply-templates select="@*" mode="numbering"/>
                        <xsl:value-of select="."/>&#160;<xsl:value-of select="$indexDoc//*[@id=$ref]/@_nr"/>
                    </xsl:copy>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:apply-templates select="@*|node()" mode="numbering"/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:copy>
                <xsl:apply-templates select="@*|node()" mode="numbering"/>
            </xsl:copy>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
<!--   /////////////////////////////////////////////   -->
<!--   /////////////////////////////////////////////   -->

<xsl:template match="@*|node()" mode="numbering">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="numbering"/>
    </xsl:copy>
</xsl:template>
<!--   **************** -->
<!--   START PROCESSING -->
<!--   **************** -->
<xsl:template match="/" mode="process">
<html  xmlns:m="http://www.w3.org/1998/Math/MathML">
  <xsl:if test="not(string-length($ws_id) gt 0)">
      <xsl:attribute name="style">background-color:#a7a69a;</xsl:attribute>     
   </xsl:if>

<head>    
   <xsl:choose>
      <!--  subtitle difference in references: leading slash or not -->
      <xsl:when test="$host_type='GAE'">
		   <link type="text/css" href="/javascript/jquery-ui-1.8.15.custom/css/ui-lightness/jquery-ui-1.8.15.custom.css" rel="Stylesheet" />
		   <script type="text/javascript" src="/javascript/jquery-ui-1.8.15.custom/js/jquery-1.6.2.min.js"></script>
		   <script type="text/javascript" src="/javascript/jquery-ui-1.8.15.custom/js/jquery-ui-1.8.15.custom.min.js"></script>
		   <script type="text/javascript" src="javascript/jquery.ui.touch-punch.min.js"/>
		   <link rel="stylesheet" href="/css/grid.css" type="text/css"/>
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
		   <script type="text/javascript"
		      src="http://cdn.mathjax.org/mathjax/latest/MathJax.js">
		   </script>
		   <link rel="stylesheet" href="/css/basis_wm.css" type="text/css"/>
		   <link rel="stylesheet" href="/css/content.css" type="text/css"/>
		   <link rel="stylesheet" href="/css/exercises.css" type="text/css"/>
		   <script type="text/javascript" src="/javascript/MathUnited_wm.js"/>
      </xsl:when>
      <xsl:otherwise>
		   <link type="text/css" href="javascript/jquery-ui-1.8.15.custom/css/ui-lightness/jquery-ui-1.8.15.custom.css" rel="Stylesheet" />
		   <script type="text/javascript" src="javascript/jquery-ui-1.8.15.custom/js/jquery-1.6.2.min.js"></script>
		   <script type="text/javascript" src="javascript/jquery-ui-1.8.15.custom/js/jquery-ui-1.8.15.custom.min.js"></script>
		   <script type="text/javascript" src="javascript/jquery.ui.touch-punch.min.js"/>
		   <link rel="stylesheet" href="css/grid.css" type="text/css"/>
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
		   <script type="text/javascript"
		      src="http://cdn.mathjax.org/mathjax/latest/MathJax.js">
		   </script>
		   <link rel="stylesheet" href="css/basis_wm.css" type="text/css"/>
		   <link rel="stylesheet" href="css/content.css" type="text/css"/>
		   <link rel="stylesheet" href="css/exercises.css" type="text/css"/>
		   <script type="text/javascript" src="javascript/MathUnited_wm.js"/>
      </xsl:otherwise>
   </xsl:choose>
   <title><xsl:value-of select="component/description/subdomain"/></title>
</head>
 
<!--   **************** -->
<!--        BODY        -->
<!--   **************** -->
<body>
    <xsl:choose>
        <xsl:when test="string-length($ws_id) gt 0">
            <div class="pageDiv-for-worksheet">
                <div class="worksheet-title">Werkblad bij <xsl:value-of select="$component_title"/> &gt; <xsl:value-of select="$subcomponent_title"/></div>
                <xsl:apply-templates select="subcomponent//exercise[@num=$ws_id]" mode="worksheet"/>    
            </div>
        </xsl:when>
        <xsl:otherwise>
            <div class="pageDiv">
                <div id="fixed-heading-container">
                    <div class="headingDiv container_12 clearfix">
                        <div class="grid_1">
                            <div class="logo-header-div"/>
                            <div class="prev-subcomponent">
                                <xsl:if test="number($subcomponent_index) gt 0">
                                    <a>
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="concat('/MathUnited/view?comp=',$comp,'&amp;subcomp=',$subcomponent_preceding_id,$arg_parent,'&amp;variant=basis_wm&amp;item=1')"/>
                                        </xsl:attribute>
                                        &lt;
                                    </a>
                                </xsl:if>
                            </div>
                        </div>
                        <div class="headingContentDiv grid_6">
                            <span class="headingDiv-content">
                                <xsl:value-of select="$component_number"/>.<xsl:value-of select="$subcomponent_number"/>&#160;
                                <xsl:value-of select="$subcomponent_title"/>
                            </span>
                            <xsl:if test="number($subcomponent_index) lt (number($subcomponent_count)-1)">
                                <span id="next-subcomponent">
                                    <a>
                                        <xsl:attribute name="href" select="concat('/MathUnited/view?comp=',$comp,'&amp;subcomp=',$subcomponent_following_id,$arg_parent,'&amp;variant=basis_wm&amp;item=1')"/>
                                        &gt;
                                    </a>
                                </span>
                            </xsl:if>
                        </div>
                        <div class="overzichtDiv grid_5">
                            <a class="navigatie">
                                <xsl:attribute name="href"><xsl:value-of select="$overviewRef"/></xsl:attribute>
                                Hoofdstukken
                            </a> > 
                            <a class="navigatie">
                                <xsl:attribute name="href"><xsl:value-of select="$overviewRef"/></xsl:attribute>
                                <xsl:value-of select="$component_title"/>
                            </a>
                        </div>
                    </div>
                </div>
                <div class="section-container">
                   <xsl:attribute name="_base"><xsl:value-of select="subcomponent/@_base"/></xsl:attribute>
                   <xsl:apply-templates select="subcomponent/section"/>
                </div>
<!--                
                <div id="vo-content-logo-container"><img src="sources_wm/vo-content_logo_stercollectie_small.jpg"/></div>
-->                
            </div>
            <xsl:if test="count(subcomponent//exercise)>0">
                <div class="menuDiv">
                    <div class="menuDiv-inner active">
                        <div class="gripdingetje"/>
                        <xsl:apply-templates select="subcomponent/section/*" mode="navigation"/>
                        <div class="menu-item-div">
                            <xsl:choose>
                                <xsl:when test="$item='answers'">
                                     <a>
				       	<xsl:attribute name="href">
		                           <xsl:value-of select="concat('/MathUnited/view?comp=',$comp,'&amp;subcomp=',$subcomp,'&amp;variant=basis_wm')"/>
		                        </xsl:attribute>
		                        <img src="sources_wm/Vraagteken.png" class="menu-vraagteken active" border="0"/>
				     </a>
                                </xsl:when>
                                <xsl:otherwise>
				     <a>
				      	<xsl:attribute name="href">
		                            <xsl:value-of select="concat('/MathUnited/view?comp=',$comp,'&amp;subcomp=',$subcomp,'&amp;variant=basis_wm&amp;item=answers')"/>
		                        </xsl:attribute>
		                        <img src="sources_wm/Vraagteken.png" class="menu-vraagteken" border="0"/>
				     </a>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                        <div style="clear:both"/>
                        <div class="gripdingetje"/>
                    </div>
                </div>
            </xsl:if>
            
        </xsl:otherwise>

    </xsl:choose>

</body>
</html>
</xsl:template>

<!--   **************** -->
<!--    CONTENT TYPES   -->
<!--   **************** -->
<xsl:template match="section">
   <xsl:apply-templates select="*[name()!='title']" mode="content"/>
</xsl:template>

<xsl:template match="subsection" mode="content">
  <div class="section-container container_12 clearfix">
     <div class="margin-left-1"/>
     <div class="subsection-title grid_11 prefix_1"><xsl:apply-templates select="title" mode="content"/></div>
  </div>
  <xsl:apply-templates select="*[name()!='title']" mode="content"/>
</xsl:template>

<xsl:template match="p">
    <xsl:apply-templates mode="content"/>
</xsl:template>

<xsl:template match="title" mode="content">
    <xsl:apply-templates mode="content"/>
</xsl:template>

<xsl:template match="theory[not(@type) or not(@type='important' or @type='important-no-icon')]" mode="content">
    <xsl:if test="$item!='answers'">
        <div class="container_12 clearfix theory">
            <div class="margin-left-1"/>
            <div class="grid_11 prefix_1">
                <xsl:apply-templates select="*" mode="content"/>
            </div>
        </div>
    </xsl:if>
</xsl:template>
<xsl:template match="theory[@type='important' or @type='important-no-icon']" mode="content">
    <xsl:if test="$item!='answers'">
        <div class="container_12 clearfix theory-important">
            <div class="margin-left-1"><xsl:if test="@type='important'">
                    <div class="theory-icon"/> 
                </xsl:if></div>
            <div class="grid_11 prefix_1">
                <xsl:apply-templates select="*" mode="content"/>
            </div>
        </div>
    </xsl:if>
</xsl:template>
<xsl:template match="linkingtext" mode="content">
    <xsl:if test="$item!='answers'">
        <div class="container_12 clearfix theory">
            <div class="margin-left-1"/>
            <div class="grid_11 prefix_1">
                <xsl:apply-templates select="*" mode="content"/>
            </div>
        </div>
    </xsl:if>
</xsl:template>

<xsl:template match="example" mode="content">
    <xsl:if test="$item!='answers'">
        <div class="container_12 clearfix example">
            <div class="margin-left-1">
                <div class="example-icon"/> 
            </div>
            <div class="prefix_1 grid_11">
                <b>Voorbeeld:</b><br/>
                <xsl:apply-templates select="*" mode="content"/>
            </div>
        </div>
    </xsl:if>
</xsl:template>
<xsl:template match="remark" mode="content">
    <xsl:if test="$item!='answers'">
        <div class="container_12 clearfix remark">
            <div class="margin-left-1">
                <div class="remark-icon"/> 
            </div>
            <div class="grid_11 prefix_1">
                <b>Opmerking:</b><br/>
                <xsl:apply-templates select="*" mode="content"/>
            </div>
        </div>
    </xsl:if>
</xsl:template>
<xsl:template match="intermezzo" mode="content">
    <xsl:if test="$item!='answers'">
        <div class="container_12 clearfix intermezzo">
            <div class="margin-left-1">
                <xsl:choose>
                    <xsl:when test="@type='history'">
                        <div class="history-icon"/> 
                    </xsl:when>
                    <xsl:when test="@type='nicetoknow'">
                        <div class="nicetoknow-icon"/> 
                    </xsl:when>
                </xsl:choose>
            </div>
            <div class="prefix_1 grid_11">
                <xsl:apply-templates select="*" mode="content"/>
            </div>        
        </div>
    </xsl:if>
</xsl:template>

<xsl:template match="exercisechoice" mode="content">
    <xsl:variable name="choiceXML">
        <xsl:copy-of select="."/>
    </xsl:variable>
    <div class="exercisechoice container_12 clearfix">
        <xsl:apply-templates select="exercisegroup" mode="content">
            <xsl:with-param name="choiceXML" select="$choiceXML"/>
        </xsl:apply-templates>
    </div>
</xsl:template>

<xsl:template match="exercisegroup" mode="content">
    <xsl:param name="choiceXML"/>
    <div level="{@level}">
        <xsl:choose>
            <xsl:when test="@level='normal'">
                <xsl:attribute name="class">exercisegroup normal active</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="class">exercisegroup <xsl:value-of select="@level"/></xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="exercise" mode="content">
            <xsl:with-param name="type" select="@level"/>
            <xsl:with-param name="choiceXML" select="$choiceXML"/>
        </xsl:apply-templates>
    </div>
</xsl:template>

<xsl:template match="exercise" mode="content">
    <xsl:param name="type"/>
    <xsl:param name="choiceXML" xs:type="node" />
    <xsl:variable name="currentPos" select="position()"/>
    <div id="ex-{@num}" num="{@num}" refid="{@id}">
        <xsl:choose><xsl:when test="@wm_show='disablefalse'">
            <xsl:attribute name="class">exercise container_12 clearfix</xsl:attribute>
        </xsl:when><xsl:otherwise>
            <xsl:attribute name="class">exercise container_12 clearfix active</xsl:attribute>
        </xsl:otherwise></xsl:choose>
        
        <div class="margin-left-1{$type}">
            <xsl:choose>
                <xsl:when test="$choiceXML">
                    <xsl:for-each select="$choiceXML/exercisechoice/exercisegroup[count(exercise)>=$currentPos]">
                        <div class="exercise-heading-wrapper {exercise[position()=$currentPos]/@level}">
                            <div onclick="WM_toggleExerciseGroup(this)">
                                <xsl:choose>
                                    <xsl:when test="@level=$type">
                                        <xsl:attribute name="id">ex-head-<xsl:value-of select="exercise[position()=$currentPos]/@num"/></xsl:attribute>
                                        <xsl:attribute name="class">exercise-heading active</xsl:attribute>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="class">exercise-heading</xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:attribute name="num" select="exercise[position()=$currentPos]/@num"/>
                                <xsl:value-of select="exercise[position()=$currentPos]/@num"/>
                                <xsl:if test="$type='difficult'">s</xsl:if>
                            </div>
                            <div class="icon-container">
                                <xsl:choose>
                                    <xsl:when test="@level=$type">
                                        <xsl:attribute name="class">icon-container active</xsl:attribute>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="class">icon-container</xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:if test="exercise[position()=$currentPos]/worksheets/worksheet">
                                    <a target="_blank">
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="concat('view?comp=',$comp,'&amp;subcomp=',$subcomp,'&amp;variant=',$variant,'&amp;ws_id=', exercise[position()=$currentPos]/@num)"/>
                                        </xsl:attribute>
                                        <div class="worksheet-icon"/>
                                    </a>
                                </xsl:if>
                                <xsl:if test="exercise[position()=$currentPos]/@icon='pepper'">
                                    <div class="pepper-icon"/> 
                                </xsl:if>
                                <xsl:if test="exercise[position()=$currentPos]/@icon='puzzle'">
                                    <div class="puzzle-icon"/> 
                                </xsl:if>
                                <xsl:if test="exercise[position()=$currentPos]/@icon='calculator'">
                                    <div class="calculator-icon"/> 
                                </xsl:if>
                                <xsl:if test="exercise[position()=$currentPos]/@icon='exclamation'">
                                    <div class="exclamation-icon"/> 
                                </xsl:if>
                                <xsl:if test="exercise[position()=$currentPos]/@icon='geen C'">
                                    <div class="geen-C-icon"/> 
                                </xsl:if>
                                <xsl:if test="exercise[position()=$currentPos]/@icon='optional'">
                                    <div class="optional-icon"/> 
                                </xsl:if>
                                <xsl:if test="exercise[position()=$currentPos]/@icon='computer'">
                                    <div class="calculator-icon"/> 
                                </xsl:if>
                            </div>
                        </div>    
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <div class="exercise-heading-wrapper">
                        <div id="ex-head-{@num}" class="exercise-heading">
                            <xsl:value-of select="@num"/>
                            <xsl:if test="@level='difficult'">s</xsl:if>
                        </div>
                    </div>
                    <div class="icon-container active">
                        <xsl:if test="worksheets/worksheet">
                        <a target="_blank">
                            <xsl:attribute name="href">
                                <xsl:value-of select="concat('view?comp=',$comp,'&amp;subcomp=',$subcomp,'&amp;variant=',$variant,'&amp;item=', $item,'&amp;ws_id=', @num)"/>
                            </xsl:attribute>
                            <div class="worksheet-icon"/>
                        </a>
                        </xsl:if>
                        <xsl:if test="@icon='pepper'">
                            <div class="pepper-icon"/> 
                        </xsl:if>
                        <xsl:if test="@icon='puzzle'">
                            <div class="puzzle-icon"/> 
                        </xsl:if>
                        <xsl:if test="@icon='calculator'">
                            <div class="calculator-icon"/> 
                        </xsl:if>
                        <xsl:if test="@icon='exclamation'">
                            <div class="exclamation-icon"/> 
                        </xsl:if>
                        <xsl:if test="@icon='geen C'">
                            <div class="geen-C-icon"/> 
                        </xsl:if>
                        <xsl:if test="@icon='optional'">
                            <div class="optional-icon"/> 
                        </xsl:if>
                        <xsl:if test="@icon='computer'">
                            <div class="calculator-icon"/> 
                        </xsl:if>
                    </div>
                </xsl:otherwise>
            </xsl:choose>
        </div>
        <xsl:choose>
           <xsl:when test="$item='answers'">
		        <div class="exercise-body grid_11 prefix_1">
		            <xsl:apply-templates mode="content">
		                <xsl:with-param name="options">
		                    <options>
		                       <mode type="answers"/>
		                    </options>
		                </xsl:with-param>
		            </xsl:apply-templates>
		        </div>
           </xsl:when>
           <xsl:otherwise>
		        <div class="exercise-body grid_11 prefix_1">
		            <xsl:apply-templates mode="content"/>
		        </div>
           </xsl:otherwise>
        </xsl:choose>
    </div>
</xsl:template>


<xsl:template match="exercisechoice" mode="navigation">
   <div class="menu-item-div">
        <div class="exercisegroup-wrapper active" style="clear:left;z-index:13">
            <div class="exercisegroup-normal">
            <xsl:for-each select="exercisegroup[@level='normal']/exercise">
                <div id="nav-ex-but-{@num}" num="{@num}" onclick="WM_toggleMenuExerciseGroup(this)">
                    <xsl:attribute name="class">menu-assignment-number active</xsl:attribute>
                    <xsl:value-of select="@num"/>
                </div>
            </xsl:for-each>
            </div>
        </div>

        <xsl:if test="exercisegroup[@level='difficult']">
            <xsl:variable name="num-difficult-exercises" select="count(exercisegroup[@level='difficult']/exercise)"/>
            <div class="exercisegroup-wrapper" style="z-index:12">
                <div class="exercisegroup-difficult">
                    <xsl:for-each select="exercisegroup[@level='difficult']/exercise">
                        <div id="nav-ex-but-{@num}" num="{@num}" onclick="WM_toggleMenuExerciseGroup(this)">
                            <xsl:attribute name="class">menu-assignment-number</xsl:attribute>
                            <xsl:value-of select="@num"/>s
                        </div>
                    </xsl:for-each>
                    <xsl:for-each select="exercisegroup[@level='normal']/exercise[position() gt $num-difficult-exercises]">
                        <div class="menu-assignment-dots"/>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>

        <xsl:if test="exercisegroup[@level='ict']">
            <div class="exercisegroup-wrapper" style="z-index:11">
                <div class="exercisegroup-ict">
                <xsl:for-each select="exercisegroup[@level='ict']/exercise">
                    <div id="nav-ex-but-{@num}" num="{@num}" onclick="WM_toggleMenuExerciseGroup(this)">
                        <xsl:attribute name="class">menu-assignment-number</xsl:attribute>
                        <xsl:value-of select="@num"/>
                    </div>
                </xsl:for-each>
                </div>
            </div>
        </xsl:if>
        <div style="clear:both"/>
   </div>
</xsl:template>

<xsl:template match="exercise" mode="navigation">
   <xsl:param name="type"/>
   <div class="menu-item-div">
       <div id="nav-ex-but-{@num}" num="{@num}" onclick="WM_toggleMenuExerciseGroup(this)">
           <xsl:attribute name="class">menu-assignment-number</xsl:attribute>
           <xsl:value-of select="@num"/>
           <xsl:if test="$type='difficult'">s</xsl:if>
       </div>
   </div>
   <div style="clear:both"/>
</xsl:template>

<xsl:template match="summary" mode="content">
    <div class="container_12 clearfix">
        <div class="summary-title grid_11 prefix_1">
            <xsl:apply-templates select="title" mode="content"/>
        </div>
    </div>
    <div class="container_12 clearfix summary-section">
        <div class="margin-left-1"/>
        <div class="prefix_1 grid_11">
             <xsl:apply-templates select="*[name()!='title']" mode="content"/>
        </div>
    </div>
</xsl:template>

<xsl:template match="textref" mode="content">
    <xsl:variable name="ref" select="@ref"/>
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
                        <xsl:attribute name="href"><xsl:value-of select="concat('view?comp=',$_comp,'&amp;subcomp=',$_subcomp,'&amp;variant=',$variant,'&amp;id=', @item)"/></xsl:attribute>
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

<xsl:template match="hint" mode="content">
    <div class="hint-container">
        <div class="hint-button">
            <div class="hint-button-ref" onclick="javascript:WM_toggleHint(this)">(hint)</div>
        </div>
        <div class="hint-content">
            <xsl:apply-templates mode="content"/>
        </div>
    </div>
</xsl:template>
<xsl:template match="summary/title" mode="content">
    <xsl:apply-templates mode="content"/>
</xsl:template>

<xsl:template match="*" mode="navigation">
    <xsl:apply-templates select="*" mode="navigation"/>
</xsl:template>
<xsl:template match="*"/>
</xsl:stylesheet>
