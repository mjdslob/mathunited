<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:exsl="http://exslt.org/common"
xmlns:saxon="http://saxon.sf.net/"
xmlns:cals="http://www.someplace.org/cals"
exclude-result-prefixes="saxon cals"
extension-element-prefixes="exsl">
<xsl:param name="item"/>
<xsl:param name="num"/>
<xsl:param name="refbase"/> <!-- used for includes: base path. Includes final / -->
<xsl:param name="ws_id"/>
<xsl:param name="comp"/>
<xsl:param name="option"/>
<xsl:param name="component"/>
<xsl:param name="subcomp"/>
<xsl:param name="is_mobile"/>
<xsl:param name="id"/>
<xsl:variable name="host_type">auteur</xsl:variable>
<xsl:variable name="cm2px" select="number(50)"/>
<xsl:variable name="parsed_component" select="saxon:parse($component)"/>
<xsl:variable name="subcomponent" select="$parsed_component/component/subcomponents/subcomponent[@id=$subcomp]"/>
<xsl:variable name="variant">studiovo_pulseon</xsl:variable>
<xsl:variable name="intraLinkPrefix">
   <xsl:value-of select="concat('view?repo=studiovo&amp;comp=',$comp,'&amp;variant=pulseon_studiovo_item','&amp;subcomp=',$subcomp,'&amp;fragment=')"/>
</xsl:variable>
<xsl:variable name="overviewRef"><xsl:value-of select="string('/auteur/math4all.html')"/></xsl:variable>
<xsl:variable name="urlbase"><xsl:value-of select="concat('/data/',$refbase)"/></xsl:variable>
<xsl:variable name="docbase" select="$refbase"></xsl:variable>
<xsl:variable name="_cross_ref_as_links_" select="true()"/>
<xsl:variable name="_sheetref_as_links_" select="true()"/>
<xsl:variable name="lang">nl</xsl:variable>

<xsl:output method="html" doctype-system="http://www.w3.org/TR/html4/strict.dtd" doctype-public="-//W3C//DTD HTML 4.01//EN"
indent="yes" encoding="utf-8"/>

<!--   **************** -->
<!--   START PROCESSING -->
<!--   **************** -->
<xsl:template match="/">
<html>
<head>
</head>

<!--   **************** -->
<!--        BODY        -->
<!--   **************** -->

<body>
    <div id="meta">
        <h1>Component: <xsl:value-of select="$parsed_component/component/title"/></h1>
        <h2>Subcomponent: <xsl:value-of select="$subcomponent/title"/></h2>
    </div>
    <div id="links">
        <xsl:apply-templates select="subcomponent/componentcontent/*"/>
    </div>
</body>
</html>
</xsl:template>


<!--  ******************* -->
<!--   CONTENT STRUCTURE  -->
<!--  ******************* -->
<xsl:template match="fragment">
    <xsl:apply-templates select="*">
        <xsl:with-param name="fragment" select="1+count(preceding-sibling::fragment)"/>
    </xsl:apply-templates>
</xsl:template>
<xsl:template match="block">
    <xsl:param name="fragment"/>
    <a href="{concat($intraLinkPrefix,$fragment,'&amp;block=',1+count(preceding-sibling::block))}"><xsl:value-of select="title"/></a><br/>
</xsl:template>


<xsl:template match="*"/>
<xsl:template match="*" mode="navigation"/>
</xsl:stylesheet>
