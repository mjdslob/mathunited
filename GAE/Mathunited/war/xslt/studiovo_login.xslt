<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:exsl="http://exslt.org/common"
xmlns:mulom="http://www.mathunited.nl/nl-lom"
xmlns:saxon="http://saxon.sf.net/"
exclude-result-prefixes="saxon"
extension-element-prefixes="exsl">
<xsl:param name="item"/>
<xsl:param name="num"/>
<xsl:param name="refbase"/> <!-- used for includes: base path. Includes final / -->
<xsl:param name="ws_id"/>
<xsl:param name="option"/>
<xsl:param name="is_mobile"/>
<xsl:param name="id"/>
<xsl:param name="repo"/>
<xsl:param name="repo-path"/>
<xsl:param name="baserepo-path"/>
<xsl:param name="registered" />
<xsl:param name="viewid"/>
<xsl:param name="threadid"/>
<xsl:param name="itemid" /> <!-- id of assignment to open automatically when returning from assignment popup -->
    
<xsl:variable name="cm2px" select="number(50)"/>
<xsl:variable name="menu_color" select="assignments/meta/param[@name='menu-color']"/>
<xsl:variable name="cssfile">basis_studiovo.css?v=37</xsl:variable>
<xsl:variable name="overviewRef"><xsl:value-of select="string('/auteur/math4all.html')"/></xsl:variable>
<xsl:variable name="_cross_ref_as_links_" select="true()"/>
<xsl:variable name="_sheetref_as_links_" select="true()"/>
<xsl:variable name="lang">nl</xsl:variable>

<!--   /////////////////////////////////////////////   -->
<!--  Specific for GAE (do not copy from auteurssite): -->
<!--   /////////////////////////////////////////////   -->
<xsl:variable name="host_type">GAE</xsl:variable>
<xsl:variable name="docbase"></xsl:variable>
<xsl:variable name="urlbase"><xsl:value-of select="concat('http://mathunited.pragma-ade.nl:41080/data/',$refbase)"/></xsl:variable>
<xsl:variable name="urlprefix">/</xsl:variable>
<!--   /////////////////////////////////////////////   -->
<!--   /////////////////////////////////////////////   -->

<xsl:output method="html" indent="yes" encoding="utf-8"/>

<xsl:template match="/">
<html>
<head>
   <xsl:choose>
      <!--  subtitle difference in references: leading slash or not -->
      <xsl:when test="$host_type='GAE'">
        <link type="text/css" href="/javascript/jquery-ui-1.8.15.custom/css/ui-lightness/jquery-ui-1.8.15.custom.css" rel="Stylesheet" />
        <script type="text/javascript" src="/javascript/jquery-ui-1.8.15.custom/js/jquery-1.6.2.min.js" />
        <script type="text/javascript" src="/javascript/jquery-ui-1.8.15.custom/js/jquery-ui-1.8.15.custom.min.js" />
        <script type="text/javascript" src="/javascript/MathUnited.js"/>
        <script type="text/javascript" src="/javascript/MathUnited_studiovo.js?v=10"/>
		<script type="text/javascript" src="/javascript/jquery.ba-postmessage.js"/>
        <link rel="stylesheet" href="/css/content.css" type="text/css"/>
        <link rel="stylesheet" type="text/css">
	        <xsl:attribute name="href">/css/<xsl:value-of select="$cssfile"/></xsl:attribute>
        </link>
      </xsl:when>
      <xsl:otherwise>
        <link type="text/css" href="javascript/jquery-ui-1.8.15.custom/css/ui-lightness/jquery-ui-1.8.15.custom.css" rel="Stylesheet" />
        <script type="text/javascript" src="javascript/jquery-ui-1.8.15.custom/js/jquery-1.6.2.min.js" />
        <script type="text/javascript" src="javascript/jquery-ui-1.8.15.custom/js/jquery-ui-1.8.15.custom.min.js" />
        <script type="text/javascript" src="javascript/MathUnited.js"/>
        <script type="text/javascript" src="javascript/MathUnited_studiovo.js?v=10"/>
		<script type="text/javascript" src="javascript/jquery.ba-postmessage.js"/>
        <link rel="stylesheet" href="css/content.css" type="text/css"/>
		<link rel="stylesheet" type="text/css">
			<xsl:attribute name="href">css/<xsl:value-of select="$cssfile"/></xsl:attribute>
		</link>
      </xsl:otherwise>
   </xsl:choose>
</head>
<body class="login-page">
	<h2>Niet ingelogd</h2>
	<xsl:copy-of select="/result/loginmessage/*"/>
</body>
</html>	
</xsl:template>

<xsl:template match="*"/>
<xsl:template match="*" mode="navigation"/>
</xsl:stylesheet>
