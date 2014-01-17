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
    <xsl:include href="editor/content.xsl"/>
    <xsl:include href="editor/figure.xslt"/>
    <xsl:include href="editor/paragraph.xslt"/>

    <xsl:variable name="item-list">
        <item-list>
            <introduction name="Inleiding" optional="true"/>
            <explore name="Verkennen" optional="true"/>
            <explanation name="Uitleg" multiplicity="multiple" min="1" max="3"/>
            <theory name="Theorie" optional="true"/>
            <digest name="Verwerken"/>
            <application name="Toepassen" optional="true"/>
            <extra name="Practicum" multiplicity="multiple"/>
            <test name="Test jezelf" multiplicity="multiple"/>
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
                <script type="text/javascript" src="javascript/editor/editor.js"></script>
                <script type="text/javascript" src="javascript/editor/menu.js"></script>
                <script type="text/javascript" src="javascript/editor/contextmenu.js"></script>
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
                        </div>
                    </div>
                    <div class="contentDiv">
                        <div class="contentDiv-content">
                            <xsl:apply-templates select="*"/>
                        </div>
                        <div style="clear:both"/>
                    </div>
                    <xsl:variable name="commitfunc">javascript:submitDocument('<xsl:value-of select="$repo"/>','<xsl:value-of select="$comp"/>','<xsl:value-of select="$subcomp"/>')</xsl:variable>
                    <div class="commit-button" onclick="{$commitfunc}"></div>
                </div>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="subcomponent">
        <div tag="subcomponent">
            <xsl:apply-templates select="@*" mode="editor"/>
            <xsl:apply-templates select="metadata" mode="editor"/>
            <xsl:apply-templates select="description" mode="editor"/>
            <div tag="componentcontent">
                <xsl:call-template name="display-items-template"/>
            </div>
        </div>
    </xsl:template>
    
    <xsl:template name="display-items-template">
        <xsl:variable name="this" select="componentcontent"/>
        <xsl:for-each select="$item-list/item-list/*">
            <xsl:variable name="item" select="."/>
            <xsl:choose>
                <xsl:when test="$this/*[name()=$item/name()]">
                    <!-- item exists -->
                    <xsl:for-each select="$this/*[name()=$item/name()]">
                        <div class="_editor_context_base">
                            <xsl:choose>
                                <xsl:when test="$item/@multiplicity='multiple'">
                                    <div class="_editor_option" type="repeat" function="optionalContentItem" item="{name($item)}" name="{$item/@name}">
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
                                        <div tag="{name()}">
                                            <div class="menu-button-div section-button">
                                                <span class="menu-button"></span>
                                            </div>
                                            <xsl:apply-templates select="."/>
                                        </div>
                                    </div>
                                </xsl:when>
                                <xsl:when test="$item/@optional='true'">
                                    <div class="_editor_option" type="optional" function="optionalContentItem" item="{name($item)}" name="{$item/@name}">
                                        <div tag="{name()}">
                                            <div class="menu-button-div section-button">
                                                <span class="menu-button"></span>
                                            </div>
                                            <xsl:apply-templates select="."/>
                                        </div>
                                    </div>
                                </xsl:when>
                                <xsl:otherwise>
                                    <div tag="{name()}">
                                        <div class="menu-button-div section-button">
                                            <span class="menu-button"></span>
                                        </div>
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </xsl:otherwise>
                            </xsl:choose>
                            <div class="m4a-editor-item nonexistent">
                                <div class="menu-button-div section-button">
                                    <span class="menu-button"></span>
                                </div>
                                <div class="m4a-editor-item-title nonexistent">
                                    <xsl:value-of select="$item/@name"/>
                                </div>
                            </div>
                        </div>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <!-- item does not exist yet -->
                    <div class="_editor_context_base">
                        <div class="_editor_option" type="optional" function="optionalContentItem" item="{name($item)}" name="{$item/@name}"/>
                        <div class="m4a-editor-item nonexistent visible">
                            <div class="menu-button-div section-button">
                                <span class="menu-button"></span>
                            </div>
                            <div class="m4a-editor-item-title nonexistent">
                                <xsl:value-of select="$item/@name"/>
                            </div>
                        </div>
                    </div>                                    
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>


    <xsl:template match="include">
        <xsl:apply-templates select="." mode="editor"/>
    </xsl:template>

    <xsl:template match="explore">
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Verkennen<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <div class="item-container shift-item-anchor"/> <!-- dummy shift-container that marks beginning of 'exercises' section. Should not move -->
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
    </xsl:template>
    <xsl:template match="introduction">
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Inleiding<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
    </xsl:template>
    <xsl:template match="explanation">
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Uitleg<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
    </xsl:template>
    <xsl:template match="context">
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Context<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
    </xsl:template>
    <xsl:template match="theory">
            <xsl:if test="include">
                <div class="m4a-editor-item-container">
                    <div class="m4a-editor-item-title">Theorie<div class="item-label-button"/></div>
                    <div class="m4a-editor-item-content">
                        <xsl:apply-templates mode="editor"/>
                    </div>
                    <div style="clear:both"/>
                </div>
            </xsl:if>
            <xsl:for-each select="examples">
                <xsl:variable name="num" select="count(preceding-sibling::examples)+1"/>
                <div class="_editor_context_base">
                    <div class="_editor_option" type="repeat" function="optionalMenuItem" item="examples" name="Voorbeeld">
                        <div class="m4a-editor-item-container">
                            <div class="m4a-editor-item-title">Voorbeeld <xsl:value-of select="$num"/><div class="item-label-button"/></div>
                            <div class="m4a-editor-item-content">
                            <div class="menu-button-div section-button">
                                <span class="menu-button"></span>
                            </div>
                                <div tag="{name()}">
                                    <xsl:apply-templates mode="editor"/>
                                </div>
                                <xsl:apply-templates select="../exercises[position()=$num]" mode="editor"/>
                            </div>
                        </div>
                    </div>
                </div>
            </xsl:for-each>
            <div class="m4a-editor-item nonexistent">
                <div class="menu-button-div section-button">
                    <span class="menu-button"></span>
                </div>
                <div class="m4a-editor-item-title nonexistent">
                    <xsl:value-of select="Voorbeeld"/>
                </div>
            </div>
    </xsl:template>
    <xsl:template match="digest">
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Verwerken<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
    </xsl:template>
    <xsl:template match="application">
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Toepassing<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
    </xsl:template>
    <xsl:template match="extra">
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Practicum<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
    </xsl:template>
    <xsl:template match="test">
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">Toets<div class="item-label-button"/></div>
                <div class="m4a-editor-item-content">
                    <xsl:apply-templates mode="editor"/>
                </div>
                <div style="clear:both"/>
            </div>
    </xsl:template>

    <xsl:template match="examples">
            <div class="m4a-editor-item-container">
                <div class="m4a-editor-item-title">
                    <xsl:choose>
                        <xsl:when test="count(preceding-sibling::examples)+count(following-sibling::examples)>0">
                            Voorbeeld <xsl:value-of select="1+count(preceding-sibling::examples)"/><div class="item-label-button"/>
                        </xsl:when>
                        <xsl:otherwise>
                            Voorbeeld <div class="item-label-button"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
                <div class="m4a-editor-item-content">
                    <xsl:apply-templates select="include" mode="editor"/>
                </div>
            </div>
            <div style="clear:both"/>
    </xsl:template>
    
    <xsl:template match="examplesolution[not(normalize-space()='')]" mode="editor">
        <div tag="examplesolution" class="m4a-example">
            <div onclick="javascript:M4A_ShowExampleAnswer(this)" class="example-answer-button">&gt; antwoord</div>
            <div class="m4a-answer">
                <xsl:apply-templates mode="editor"/>
                <div  onclick="javascript:M4A_ShowExampleAnswer(this)" class="answerCloseButton"/>
            </div>
        </div>
        <div style="clear:both"/>
    </xsl:template>



</xsl:stylesheet>
