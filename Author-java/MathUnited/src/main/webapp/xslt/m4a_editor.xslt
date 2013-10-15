<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:exsl="http://exslt.org/common"
                xmlns:m="http://www.w3.org/1998/Math/MathML"
                xmlns:cals="http://www.someplace.org/cals"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="saxon"
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
    <xsl:param name="repo"/>
    <xsl:param name="repo-path"/>
    <xsl:param name="baserepo-path"/>
    <xsl:param name="component"/>
    <xsl:variable name="parsed_component" select="saxon:parse($component)"/>
    <xsl:variable name="subcomponent" select="$parsed_component/component/subcomponents/subcomponent[@id=$subcomp]"/>
    <xsl:param name="refbase"/> <!-- used for includes: base path. Includes final / -->

<!--   /////////////////////////////////////////////   -->
<!--  Specific for auteurssite (do not copy from GAE): -->
<!--   /////////////////////////////////////////////   -->
    <xsl:variable name="host_type">auteur</xsl:variable>
    <xsl:variable name="docbase" select="$refbase"></xsl:variable>
    <xsl:variable name="urlbase">
        <xsl:value-of select="concat('../data/',$refbase)"/>
    </xsl:variable>
    <xsl:variable name="indexDoc" select="document(concat($refbase,'../index.xml'))"/>
<!--   /////////////////////////////////////////////   -->
<!--   /////////////////////////////////////////////   -->

    <xsl:include href="editor/main.xslt"/>
    <xsl:include href="editor/exercise.xslt"/>
    <xsl:include href="editor/figure.xslt"/>
    <xsl:include href="editor/paragraph.xslt"/>

    <xsl:variable name="item-list">
        <item-list>
            <introduction name="Inleiding" optional="true"/>
            <explore name="Verkennen" optional="true"/>
            <explanation name="Uitleg" multiplicity="multiple" min="1" max="3"/>
            <theory name="Theorie"/>
            <examples name="Voorbeeld"/>
            <digest name="Verwerken"/>
            <application name="Toepassen" optional="true"/>
            <extra name="Practicum" multiplicity="multiple"/>
            <test name="Testen" multiplicity="multiple"/>
        </item-list>
    </xsl:variable>

    <xsl:variable name="itemInner">
        <xsl:choose>
            <xsl:when test="string-length($id) > 0">
                <xsl:value-of select="name(subcomponent/componentcontent/*[descendant::include[@filename=concat($id,'.xml')]])"/>
            </xsl:when>
            <xsl:when test="$item=''">
                <xsl:value-of select="name(subcomponent/componentcontent/*[1])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$item"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="cm2px" select="number(50)"/>
    <xsl:variable name="variant">m4a_editor</xsl:variable>
    <xsl:variable name="arg_option">
        <xsl:choose>
            <xsl:when test="$option">&amp;option=<xsl:value-of select="$option"/></xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="arg_repo">
        <xsl:choose>
            <xsl:when test="$repo">&amp;repo=<xsl:value-of select="$repo"/></xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="arg_parent">
        <xsl:choose>
            <xsl:when test="$parent">&amp;parent=<xsl:value-of select="$parent"/></xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="intraLinkPrefix">
        <xsl:value-of select="concat('view?comp=',$comp,'&amp;subcomp=',$subcomp,'&amp;variant=',$variant,$arg_option,$arg_parent,$arg_repo,'&amp;item=')"/>
    </xsl:variable>
    <xsl:variable name="overviewRef">
        <xsl:choose>
            <xsl:when test="$parent">
                <xsl:value-of select="concat('http://',$parent)"/>
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



<!--   **************** -->
<!--   START PROCESSING -->
<!--   **************** -->
    <xsl:template match="/">
        <html  xmlns:m="http://www.w3.org/1998/Math/MathML" xmlns:xhtml="http://www.w3.org/1999/xhtml">
            <head>
                <link type="text/css" href="javascript/jquery-ui-1.8.15.custom/css/ui-lightness/jquery-ui-1.8.15.custom.css" rel="Stylesheet" />
                <script type="text/javascript" src="javascript/jquery-ui-1.8.15.custom/js/jquery-1.6.2.min.js"/>
                <script type="text/javascript" src="javascript/jquery-ui-1.8.15.custom/js/jquery-ui-1.8.15.custom.min.js"/>
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
                <script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js"></script>
                <script type="text/javascript" src="javascript/tinymce/jquery.tinymce.min.js"></script>
                <script type="text/javascript" src="javascript/editor.js"></script>
                <script type="text/javascript" src="javascript/contextmenu.js"></script>
                <script type="text/javascript" src="javascript/MathUnited.js"></script>
                <script type="text/javascript" src="javascript/MathUnited_m4a.js"></script>
                <link rel="stylesheet" href="css/content.css" type="text/css"/>
                <link rel="stylesheet" href="css/exercises.css" type="text/css"/>
                <link rel="stylesheet" href="css/M4AStijl2.css" type="text/css"/>
                <link rel="stylesheet" href="css/editor.css" type="text/css"/>
            </head>
            <body>
                <div class="hidden-templates">
                    <xsl:call-template name="exercise-templates"/>
                    <xsl:call-template name="paragraph-template"/>
                </div>
                <div id="meta-data-container" style="display:none">
                    <span id="meta-data-comp"><xsl:value-of select="$comp"/></span>
                    <span id="meta-data-refbase"><xsl:value-of select="$refbase"/></span>
                    <span id="meta-data-repo-path"><xsl:value-of select="$repo-path"/></span>
                    <span id="meta-data-baserepo-path"><xsl:value-of select="$baserepo-path"/></span>
                </div>
                <div style="display:none">
                    <div id="dialog-remove-item-confirm" title="Item verwijderen?">
                        <p>
                            <span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 20px 0;"></span>Weet u zeker dat u dit item wilt verwijderen?
                        </p>
                    </div>
        
                </div>
                <div class="pageDiv">
                    <div class="headingDiv">
                        <div class="headingContentDiv">
                            <img class="logo" src="sources_ma/LogoM4Ainvlak.gif" align="middle"  height="33" border="0"/>
                            <xsl:if test="$is_mobile='true'">
                                (m)
                            </xsl:if>
                            <xsl:value-of select="$parsed_component/component/title"/> &gt; 
                            <xsl:value-of select="$subcomponent/title"/>
                        </div>
                        <div class="overzichtDiv">
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="$overviewRef"/>
                                </xsl:attribute>Overzicht
                            </a>
                        </div>
                        <div style="clear:both"/>
                    </div>
                    <div class="sectionDiv">
                        <div class="balk">
                            <span class="subcomponent-title">
                                <xsl:value-of select="$subcomponent/title"/>
                            </span>
                            <xsl:if test="contains($option, 'slechtziend')">
                                <span class="font-selector">
                                    <span class="sizeA" onclick="javascript:MU_fontSelect(1)">A</span>
                                    <span class="sizeB" onclick="javascript:MU_fontSelect(2)">A</span>
                                    <span class="sizeC" onclick="javascript:MU_fontSelect(3)">A</span>
                                </span>
                            </xsl:if>
                        </div>
                    </div>
                    <div class="contentDiv">
                        <div class="contentDiv-content">
                            <xsl:choose>
                                <xsl:when test="($itemInner='example' or $itemInner='theory') and $num">
                                    <xsl:apply-templates select="subcomponent/componentcontent/theory/examples[position()=number($num)]"/>
                                    <xsl:apply-templates select="subcomponent/componentcontent/theory/exercises[position()=number($num)]" mode="editor"/>
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
                                <xsl:otherwise>
                                    <xsl:apply-templates select="subcomponent/componentcontent/*[name()=$itemInner]"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                        <div class="menuDiv">
                            <div class="menuDiv-shadow"/>
                            <div class="menuDiv-inner">
                                <div class="menu-item-padding"/>
                                <xsl:variable name="this" select="subcomponent/componentcontent"/>
                                <xsl:for-each select="$item-list/item-list/*">
                                    <xsl:variable name="item" select="."/>
                                    <xsl:choose>
                                        <xsl:when test="$this/*[name()=$item/name()]">
                                            <xsl:for-each select="$this/*[name()=$item/name()]">
                                                <div class="_editor_context_base">
                                                    <xsl:choose>
                                                        <xsl:when test="$item/@multiplicity='multiple'">
                                                            <div class="_editor_option" type="repeat" function="optionalMenuItem" repo="{$repo}" comp="{$comp}" subcomp="{$subcomp}" item="{name($item)}" position="{position()}" name="{$item/@name}">
                                                                <div class="menu-item-div" item="{$item/name()}">
                                                                    <xsl:if test="$item/@min">
                                                                        <xsl:attribute name="min">
                                                                            <xsl:value-of select="$item/@min"/>
                                                                        </xsl:attribute>
                                                                    </xsl:if>
                                                                    <xsl:if test="$item/@max">
                                                                        <xsl:attribute name="max">
                                                                            <xsl:value-of select="$item/@max"/>
                                                                        </xsl:attribute>
                                                                    </xsl:if>
                                                                    <xsl:apply-templates select="." mode="navigation"/>
                                                                    <div class="menu-button-div">
                                                                        <span class="menu-button">&#x2b24;</span>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </xsl:when>
                                                        <xsl:when test="$item/@optional='true'">
                                                            <div class="_editor_option" type="optional" function="optionalMenuItem" repo="{$repo}" comp="{$comp}" subcomp="{$subcomp}" item="{name($item)}" position="1" name="{$item/@name}">
                                                                <div class="menu-item-div" item="{$item/name()}">
                                                                    <xsl:apply-templates select="." mode="navigation"/>
                                                                    <div class="menu-button-div">
                                                                        <span class="menu-button">&#x2b24;</span>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <div class="menu-item-div" item="{$item/name()}">
                                                                <xsl:apply-templates select="." mode="navigation"/>
                                                            </div>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </div>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <xsl:when test="$item/name()='examples'">
                                            <xsl:for-each select="$this/theory/examples">
                                                <div class="_editor_context_base">
                                                    <div class="menu-item-div" item="{$item/name()}">
                                                        <div class="_editor_option" type="repeat" function="optionalMenuItem" repo="{$repo}" comp="{$comp}" subcomp="{$subcomp}" item="{name($item)}" position="{position()}" name="{$item/@name}">
                                                            <xsl:if test="$item/@min">
                                                                <xsl:attribute name="min">
                                                                    <xsl:value-of select="$item/@min"/>
                                                                </xsl:attribute>
                                                            </xsl:if>
                                                            <xsl:if test="$item/@max">
                                                                <xsl:attribute name="max">
                                                                    <xsl:value-of select="$item/@max"/>
                                                                </xsl:attribute>
                                                            </xsl:if>
                                                            <xsl:apply-templates select="." mode="navigation"/>
                                                        </div>
                                                        <div class="menu-button-div">
                                                            <span class="menu-button">&#x2b24;</span>
                                                        </div>
                                                    </div>
                                                </div>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <xsl:otherwise>
                                    <!-- item does not exist yet -->
                                            <div class="_editor_context_base">
                                                <div class="menu-item-div" item="{$item/name()}">
                                                    <span class="menu-nonexistent-item">
                                                        <xsl:value-of select="$item/@name"/>
                                                        <div class="_editor_option" type="optional" function="optionalMenuItem" repo="{$repo}" comp="{$comp}" subcomp="{$subcomp}" item="{name($item)}" position="{count(preceding-sibling::*)}" name="{$item/@name}"/>
                                                    </span>
                                                    <div class="menu-button-div">
                                                        <span class="menu-button">&#x2b24;</span>
                                                    </div>
                                                </div>
                                            </div>                                    
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                                <div class="menu-item-padding"/>
                            </div>
                        </div>
                        <div style="clear:both"/>
                    </div>
                    <xsl:variable name="commitfunc">javascript:submitDocument('<xsl:value-of select="$repo"/>','<xsl:value-of select="$comp"/>','<xsl:value-of select="$subcomp"/>')</xsl:variable>
                    <div class="commit-button" onclick="{$commitfunc}"></div>
                </div>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="include">
        <xsl:apply-templates select="." mode="editor"/>
    </xsl:template>

    <xsl:template match="explore">
        <h2 class="section-title">Verkennen</h2>
        <xsl:apply-templates mode="editor"/>
    </xsl:template>
    <xsl:template match="introduction">
        <h2 class="section-title">Inleiding</h2>
        <xsl:apply-templates mode="editor"/>
    </xsl:template>
    <xsl:template match="explanation">
        <h2 class="section-title">Uitleg</h2>
        <xsl:apply-templates mode="editor"/>
    </xsl:template>
    <xsl:template match="theory">
        <h2 class="section-title">Theorie</h2>
        <xsl:apply-templates select="include" mode="editor"/>
    </xsl:template>
    <xsl:template match="digest">
        <h2 class="section-title">Verwerken</h2>
        <xsl:apply-templates mode="editor"/>
    </xsl:template>
    <xsl:template match="application">
        <h2 class="section-title">Toepassen</h2>
        <xsl:apply-templates mode="editor"/>
    </xsl:template>
    <xsl:template match="examples">
        <xsl:choose>
            <xsl:when test="count(preceding-sibling::examples)+count(following-sibling::examples)>0">
                <h2 class="section-title">Voorbeeld 
                    <xsl:value-of select="1+count(preceding-sibling::examples)"/>
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h2 class="section-title">Voorbeeld</h2>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="include" mode="editor"/>
    </xsl:template>
    <xsl:template match="examplesolution[not(normalize-space()='')]" mode="editor">
        <div tag="examplesolution" class="m4a-example">
            <div onclick="javascript:M4A_ShowExampleAnswer(this)" class="example-answer-button">&gt; antwoord</div>
            <div class="m4a-answer">
                <xsl:apply-templates mode="editor"/>
                <div  onclick="javascript:M4A_ShowExampleAnswer(this)" class="answerCloseButton"/>
            </div>
        </div>
    </xsl:template>


<!--   **************** -->
<!--     NAVIGATION     -->
<!--   **************** -->
    <xsl:template match="explore" mode="navigation">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="concat($intraLinkPrefix,'explore')"/>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="$itemInner='explore'">
                    <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                    <div class="menu-item-dot-wrapper">
                        <div class="menu-item-dot"/></div>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">navigatie</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            Verkennen
        </a>
    </xsl:template>
    <xsl:template match="introduction" mode="navigation">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="concat($intraLinkPrefix,'introduction')"/>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="$itemInner='introduction'">
                    <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                    <div class="menu-item-dot-wrapper">
                        <div class="menu-item-dot"/></div>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">navigatie</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            Inleiding
        </a>
    </xsl:template>
    <xsl:template match="explanation" mode="navigation">
        <xsl:variable name="explnum" select="count(preceding-sibling::explanation)+1"/>
        <xsl:choose>
            <xsl:when test="count(preceding-sibling::explanation)+count(following-sibling::explanation) gt 0">
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="concat($intraLinkPrefix,'explanation&amp;num=',$explnum)"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="$itemInner='explanation' and $explnum=number($num)">
                            <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                            <div class="menu-item-dot-wrapper">
                                <div class="menu-item-dot"/></div>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="class">navigatie</xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    Uitleg 
                    <xsl:value-of select="$explnum"/>
                </a>

            </xsl:when>
            <xsl:otherwise>
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="concat($intraLinkPrefix,'explanation')"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="$itemInner='explanation' and not(number($num) gt 1)">
                            <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                            <div class="menu-item-dot-wrapper">
                                <div class="menu-item-dot"/></div>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="class">navigatie</xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    Uitleg
                </a>

            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="theory" mode="navigation">
        <xsl:if test="include">
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="concat($intraLinkPrefix,'theory')"/>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="$itemInner='theory'">
                        <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                        <div class="menu-item-dot-wrapper">
                            <div class="menu-item-dot"/></div>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="class">navigatie</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                Theorie
            </a>
        </xsl:if>
    </xsl:template>
    <xsl:template match="examples" mode="navigation">
        <xsl:variable name="exnum" select="1+count(preceding-sibling::examples)"/>
<!--
        <xsl:attribute name="num">
            <xsl:value-of select="position()"/>
        </xsl:attribute>
-->        
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="concat($intraLinkPrefix,'example&amp;num=',$exnum)"/>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="($itemInner='example' or $itemInner='theory') and $exnum=number($num)">
                    <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                    <div class="menu-item-dot-wrapper">
                        <div class="menu-item-dot"/></div>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">navigatie</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            Voorbeeld 
            <xsl:value-of select="$exnum"/>
        </a>
    </xsl:template>
    <xsl:template match="digest" mode="navigation">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="concat($intraLinkPrefix,'digest')"/>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="$itemInner='digest'">
                    <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                    <div class="menu-item-dot-wrapper">
                        <div class="menu-item-dot"/></div>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">navigatie</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            Verwerken
        </a>
    </xsl:template>

    <xsl:template match="application" mode="navigation">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="concat($intraLinkPrefix,'application')"/>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="$itemInner='application'">
                    <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                    <div class="menu-item-dot-wrapper">
                        <div class="menu-item-dot"/></div>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">navigatie</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            Toepassen
        </a>
    </xsl:template>

    <xsl:template match="extra" mode="navigation">
        <xsl:variable name="explnum" select="count(preceding-sibling::extra)+1"/>
        <xsl:choose>
            <xsl:when test="count(preceding-sibling::extra)+count(following-sibling::extra) gt 0">
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="concat($intraLinkPrefix,'extra&amp;num=',$explnum)"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="$itemInner='extra' and $explnum=number($num)">
                            <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                            <div class="menu-item-dot-wrapper">
                                <div class="menu-item-dot"/></div>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="class">navigatie</xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    Practicum 
                    <xsl:value-of select="$explnum"/>
                </a>

            </xsl:when>
            <xsl:otherwise>
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="concat($intraLinkPrefix,'extra')"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="$itemInner='extra' and not(number($num) gt 1)">
                            <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                            <div class="menu-item-dot-wrapper">
                                <div class="menu-item-dot"/></div>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="class">navigatie</xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    Practicum
                </a>

            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="exam" mode="navigation">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="concat($intraLinkPrefix,'exam')"/>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="$itemInner='exam'">
                    <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                    <div class="menu-item-dot-wrapper">
                        <div class="menu-item-dot"/></div>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">navigatie</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            Examenopgaven
        </a>
    </xsl:template>

    <xsl:template match="summary" mode="navigation">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="concat($intraLinkPrefix,'summary')"/>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="$itemInner='summary'">
                    <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                    <div class="menu-item-dot-wrapper">
                        <div class="menu-item-dot"/></div>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">navigatie</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            Samenvatten
        </a>
    </xsl:template>
    <xsl:template match="test" mode="navigation">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="concat($intraLinkPrefix,'test')"/>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="$itemInner='test'">
                    <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                    <div class="menu-item-dot-wrapper">
                        <div class="menu-item-dot"/></div>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">navigatie</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            Testen
        </a>
    </xsl:template>

    <xsl:template match="background" mode="navigation">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="concat($intraLinkPrefix,'background')"/>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="$itemInner='background'">
                    <xsl:attribute name="id">selected-menu-item</xsl:attribute>
                    <div class="menu-item-dot-wrapper">
                        <div class="menu-item-dot"/></div>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">navigatie</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            Achtergronden
        </a>
    </xsl:template>

</xsl:stylesheet>
