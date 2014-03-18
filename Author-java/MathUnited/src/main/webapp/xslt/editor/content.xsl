<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:saxon="http://saxon.sf.net/"
xmlns:exsl="http://exslt.org/common"
xmlns:m="http://www.w3.org/1998/Math/MathML"
xmlns:cals="http://www.someplace.org/cals"
exclude-result-prefixes="saxon"
extension-element-prefixes="exsl">

<xsl:template match="applet[@type='ggb']" mode="content">
        <iframe style="overflow:hidden" _type='ggb'>
            <xsl:if test="@width">
                <xsl:attribute name="width"><xsl:value-of select="@width"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="@height">
                <xsl:attribute name="height"><xsl:value-of select="@height"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="@location='right'">
                <xsl:attribute name="style">float:right</xsl:attribute>
            </xsl:if>
            <xsl:attribute name="src"><xsl:value-of select="concat('http://mathunited.pragma-ade.nl:41080/MathUnited/geogebra?file=',$urlbase,replace(@filename,'GeoGebra/','../geogebra/'))"/></xsl:attribute>
        </iframe>
</xsl:template>



</xsl:stylesheet>