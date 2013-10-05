<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:exsl="http://exslt.org/common"
xmlns:m="http://www.w3.org/1998/Math/MathML"
extension-element-prefixes="exsl">
<xsl:param name="item"/>
<xsl:param name="num"/>
<xsl:param name="ref"/> <!-- eg.: content-ma/concept/hv/me7/hv-me72/hv-me72.xml -->
<xsl:param name="refparent"/> <!-- eg.: content-ma/concept/hv/me7/hv-me72 -->
<xsl:param name="parent"/> <!-- eg.: mathunited.nl/wiskundemenu/WM_overview.html -->
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
        <xsl:when test="string-length($id) gt 0"><xsl:value-of select="name(subcomponent/componentcontent/*[descendant::include[@filename=concat($id,'.xml')]])"/></xsl:when>
        <xsl:when test="$item=''"><xsl:value-of select="name(subcomponent/componentcontent/*[1])"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="$item"/></xsl:otherwise>
    </xsl:choose>
</xsl:variable>
<xsl:variable name="cm2px" select="number(50)"/>
<!--  for GAE -->
<xsl:variable name="refbase"/>
<xsl:variable name="variant">basis</xsl:variable>
<xsl:variable name="intraLinkPrefix">
    <xsl:choose>
       <xsl:when test="$parent">
            <xsl:value-of select="concat('/',$viewer,'?parent=',$parent,'&amp;comp=',$comp,'&amp;subcomp=',$subcomp,'&amp;variant=',$variant,'&amp;item=')"/>
       </xsl:when>
       <xsl:otherwise>
            <xsl:value-of select="concat('/',$viewer,'?comp=',$comp,'&amp;subcomp=',$subcomp,'&amp;variant=',$variant,'&amp;item=')"/>
       </xsl:otherwise>
    </xsl:choose>
</xsl:variable>
<xsl:variable name="URLbase"></xsl:variable>
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

<xsl:output method="html" doctype-system="http://www.w3.org/TR/html4/strict.dtd" doctype-public="-//W3C//DTD HTML 4.01//EN"
indent="yes" encoding="utf-8"/>

<!--   **************** -->
<!--   START PROCESSING -->
<!--   **************** -->
<xsl:template match="/">
<html  xmlns:m="http://www.w3.org/1998/Math/MathML">
<head>
   <link type="text/css" href="/javascript/jquery-ui-1.8.15.custom/css/ui-lightness/jquery-ui-1.8.15.custom.css" rel="Stylesheet" />
   <script type="text/javascript" src="/javascript/jquery-ui-1.8.15.custom/js/jquery-1.6.2.min.js"></script>
   <script type="text/javascript" src="/javascript/jquery-ui-1.8.15.custom/js/jquery-ui-1.8.15.custom.min.js"></script>
   <script type="text/javascript" src="/javascript/jquery.simplemodal.1.4.4.min.js"></script>
   <script type="text/javascript" src="/javascript/prikbord.js"></script>
   <link rel="stylesheet" href="/css/grid.css" type="text/css"/>
   <link rel="stylesheet" href="/css/prikbord.css" type="text/css"/>
   <title>Prikbord: <xsl:value-of select="$component_title"/></title>
</head>

<!--   **************** -->
<!--        BODY        -->
<!--   **************** -->
<body>
<div class="shadow-ul"/>
<div class="pageDiv">
<div class="headingDiv container_12 clearfix">
    <div class="headingContentDiv grid_10">
        <img class="logo" src="sources_ma/LogoM4Ainvlak.gif" align="middle"  height="33" border="0"/>
        <xsl:value-of select="$component_title"/> &gt; <xsl:value-of select="$subcomponent_title"/>
    </div>
    <div class="overzichtDiv grid_2">
        <a>
              <xsl:attribute name="href"><xsl:value-of select="$overviewRef"/></xsl:attribute>Overzicht
        </a>
    </div>
</div>
<div class="sectionDiv container_12">
   <div class="balk grid_12">
       <span class="subcomponent-title"><xsl:value-of select="$subcomponent_title"/></span>
       
   </div>
</div>
<div class="contentDiv container_12 clearfix">
<div class="grid_10">
	<div id='contents' comp="{$comp}" subcomp="{$subcomp}">
	   <div class="prikbord-header">
	      <div class="item-name">Bestand</div>
	      <div class="item-type">Type</div>
	      <div class="item-user">Toegevoegd door</div>
	      <div style="clear:both"/>
	   </div>
	</div>
	<div class="voeg-toe-button" onclick="javascript:showNewItemDialog()">
	  Voeg iets toe
	</div>
</div>
</div>
</div>
<div class="shadow-lr"/>
</body>
</html>
</xsl:template>

<xsl:template match="*"/>

</xsl:stylesheet>
