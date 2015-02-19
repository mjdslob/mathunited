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
    <xsl:param name="lock_owner"/>
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
    <xsl:param name="refbase"/> <!-- used for includes: base path. Includes final / -->

    <xsl:include href="mathml/to-asciimathml.xslt"/>

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

    <xsl:variable name="item-list">
        <xsl:choose>
            <xsl:when test="subcomponent/componentcontent/summary">
                <item-list>
                    <summary name="Samenvatten" optional="true"/>
                    <background name="Achtergronden" optional="true"/>
                    <test name="Testen" multiplicity="multiple" min="1" max="3"/>
                    <application name="Toepassen" optional="true"/>
                    <exam name="Examenopgaven" optional="true"/>
                </item-list>
            </xsl:when>
            <xsl:otherwise>
                <item-list>
                    <introduction name="Inleiding" optional="true"/>
                    <explore name="Verkennen" optional="true"/>
                    <explanation name="Uitleg" multiplicity="multiple" min="1" max="3"/>
                    <theory name="Theorie"/>
                    <digest name="Verwerken"/>
                    <application name="Toepassen" optional="true"/>
                    <extra name="Practicum" multiplicity="multiple"/>
                    <test name="Test jezelf" multiplicity="option"/>
                </item-list>
            </xsl:otherwise>
        </xsl:choose>
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
        <xsl:choose>
            <xsl:when test="$option='editor-process-item'">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="main-page"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="main-page">
        <html  xmlns:m="http://www.w3.org/1998/Math/MathML" xmlns:xhtml="http://www.w3.org/1999/xhtml">
            <head>
                <link type="text/css" href="javascript/jquery-ui-1.8.15.custom/css/ui-lightness/jquery-ui-1.8.15.custom.css" rel="Stylesheet" />
                <script data-main="javascript/editor.js" src="javascript/require.js"></script>
<!--                
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
                <script type="text/javascript" src="javascript/MathUnited.js"></script>
-->                
<!--                <script type="text/javascript" src="javascript/MathUnited_m4a.js"></script>-->
                <link rel="stylesheet" href="css/content.css" type="text/css"/>
                <link rel="stylesheet" href="css/exercises.css" type="text/css"/>
                <link rel="stylesheet" href="css/M4AStijl2.css" type="text/css"/>
                <link rel="stylesheet" href="css/editor.css" type="text/css"/>
                <style>
                    .am {
                        border:1px solid blue;
                        display:inline-block;
                        margin: 0px 10px;
                        padding:2px;
                    }
                    .ml {
                        border:1px solid gray;
                        display:inline-block;
                        margin: 0px 10px;
                        padding:2px;
                    }
                </style>
            </head>
            <body>
                 <xsl:apply-templates select="*"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="node() | @*">
        <xsl:apply-templates select="*"/>
    </xsl:template>
    <xsl:template match="node() | @*" mode="copy">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="copy"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="am" mode="paragraph">
         `<xsl:value-of select='.'/>`
    </xsl:template>

    <xsl:template match="m:math" priority="20">
        <div class="ml">
            <xsl:apply-templates select="." mode="copy"/>
        </div>
        <div class="am">
            <xsl:variable name="am">
                <xsl:apply-templates select="." mode="convert-to-asciimathml"/>
            </xsl:variable>
            <xsl:variable name="am2">
                <xsl:apply-templates select="$am" mode="paragraph"/>
            </xsl:variable>
            <xsl:apply-templates select="$am2" mode="copy"/>
        </div>
        <br/>
    </xsl:template>
    <xsl:template match="include" priority="20">
            <xsl:variable name="content" select="document(concat($docbase,@filename))"/>
            <xsl:apply-templates select="$content"/>
    </xsl:template>

</xsl:stylesheet>
